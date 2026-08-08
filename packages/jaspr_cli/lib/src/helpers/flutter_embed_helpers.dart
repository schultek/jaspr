import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:mason/mason.dart' hide Level;
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../commands/base_command.dart';
import '../logging.dart';
import '../migrations/migration_models.dart' show EditBuilder;
import '../project.dart';
import 'pubspec_helpers.dart';

/// helpers used to set up a project for Flutter embedding: changes to pubspec.yaml, creating the flutter_bootstrap.js
/// script, and the inclusion of its ref in the Document or index.html
mixin FlutterEmbedSetupHelper on BaseCommand, PubspecHelper {
  /// Sets the flutter mode to embedded in the pubspec.yaml file for the project
  /// if the project has jaspr.flutter set to 'plugins', we ask the user if they want to change it to embedded or not
  void setFlutterMode(Directory projectRoot) {
    FlutterMode currentFlutterMode;

    // NOTE: we re-read the pubspec file after the potential installation of packages
    final pubspecMap = readPubspec(projectRoot);

    final configYaml = pubspecMap?['jaspr'];
    if (configYaml is! YamlMap) {
      currentFlutterMode = FlutterMode.none;
    }
    final modeYaml = configYaml['flutter'];
    if (modeYaml is! String) {
      currentFlutterMode = FlutterMode.none;
    }
    currentFlutterMode = FlutterMode.values.where((v) => v.name == modeYaml).firstOrNull ?? FlutterMode.none;

    if (currentFlutterMode != FlutterMode.embedded) {
      if (pubspecMap != null) {
        logger.write(
          'Enabling Flutter embedding support in pubspec.yaml.',
          tag: Tag.cli,
          level: Level.info,
        );

        try {
          final pubspecFile = File(p.join(projectRoot.path, 'pubspec.yaml'));

          final pubspecContent = pubspecFile.readAsStringSync();
          final builder = EditBuilder(LineInfo.fromContent(pubspecContent));

          if (pubspecMap.nodes['jaspr'] case final YamlMap jasprMap) {
            // if there is already a flutter mode, then it presumably is set to "plugins", so we ask the user to confirm that they want to change it
            if (jasprMap.nodes['flutter'] case final YamlScalar flutterNode when flutterNode.value != null) {
              final bool overwritePlugins = logger.logger!.confirm(
                'This project is set with jaspr.flutter mode set to plugins. Do you want to overwrite it to "embedded" to allow Flutter embedding?',
                defaultValue: false,
              );
              if (overwritePlugins) {
                builder.replace(flutterNode.span.start.offset, flutterNode.span.length, 'embedded');
              }
            } else {
              // there was presumably no flutter mode set in the jaspr block, so we add it.
              // we need an offset to be able to add this new line with the flutter mode, and we know that there will
              // always be a mode key for the rendering mode in the jaspr map, so we can just insert the new line below that

              if (jasprMap.nodes['mode'] case final YamlScalar jasprModeNode when jasprModeNode.value != null) {
                builder.insert(jasprModeNode.span.end.offset, '\n  flutter: embedded');
              }
            }
          }

          pubspecFile.writeAsStringSync(builder.apply(pubspecContent));
        } catch (e) {
          logger.write(
            'Failed to update pubspec.yaml: $e',
            level: Level.error,
            tag: Tag.cli,
          );
        }
      } else {
        logger.write(
          'Could not find pubspec.yaml file, please run this command in the root directory of your project.',
          tag: Tag.cli,
          level: Level.error,
        );
        exit(1);
      }
    }
  }

  /// ensure that "uses-material-design: true" is set in the flutter block of pubspec.yaml
  /// it allows the embedded Flutter app to use Material icons and fonts
  void setUseMaterialDesignPubspec(Directory projectRoot) {
    final pubspecMap = readPubspec(projectRoot);
    if (pubspecMap == null) {
      logger.write(
        'Failed to find pubspec.yaml file in dir ${blue.wrap(projectRoot.path)}',
        tag: Tag.cli,
        level: Level.error,
      );
      return;
    }

    final pubspecFile = File(p.join(projectRoot.path, 'pubspec.yaml'));

    try {
      final pubspecContent = pubspecFile.readAsStringSync();
      final builder = EditBuilder(LineInfo.fromContent(pubspecContent));

      final flutterNode = pubspecMap.nodes['flutter'];

      if (flutterNode is YamlMap) {
        if (flutterNode.nodes['uses-material-design'] case final YamlScalar _) {
          // if the key is present, it might be true or false, if false we don't want to overwrite it
          return;
        } else {
          // the flutter block is present but doesn't have the uses-material-design key, so we add it as the first entry
          // reusing the indentation of the existing entries
          final indent = ''.padLeft(flutterNode.span.start.column);
          builder.insert(flutterNode.span.start.offset, 'uses-material-design: true\n$indent');
        }
      } else if (flutterNode == null) {
        // there is no flutter block, append one at the end of the file
        final trailingNewline = pubspecContent.endsWith('\n') ? '' : '\n';
        builder.insert(pubspecContent.length, '$trailingNewline\nflutter:\n  uses-material-design: true\n');
      } else {
        logger.write(
          'Could not set uses-material-design in pubspec.yaml, please add it manually in the flutter block.',
          tag: Tag.cli,
          level: Level.warning,
        );
        return;
      }

      logger.write(
        'Enabled uses-material-design in pubspec.yaml.',
        tag: Tag.cli,
        level: Level.info,
      );

      pubspecFile.writeAsStringSync(builder.apply(pubspecContent));
    } catch (e) {
      logger.write(
        'Failed to update pubspec.yaml: $e',
        level: Level.error,
        tag: Tag.cli,
      );
    }
  }

  /// Create the flutter bootstrap script in the web dir
  void createFlutterBootstrapScript(Directory projectRoot) {
    // creating the flutter_bootstrap.js file, this doesn't modify an existing file
    final bootstrapFile = File(p.join(projectRoot.path, 'web', 'flutter_bootstrap.js'));
    try {
      if (!bootstrapFile.existsSync()) {
        bootstrapFile
          ..createSync(recursive: true)
          ..writeAsStringSync('{{flutter_js}}\n{{flutter_build_config}}\n');

        logger.write(
          'Created ${blue.wrap(p.relative(bootstrapFile.path, from: projectRoot.path))}.',
          tag: Tag.cli,
          level: Level.info,
        );
      } else {
        logger.write('web/flutter_bootstrap.js already exists, leaving unchanged', level: Level.info, tag: Tag.cli);
      }
    } catch (e) {
      logger.write('Failed to open or create web/flutter_bootstrap.js: $e', level: Level.error, tag: Tag.cli);
    }
  }

  /// read the current jaspr mode in the provided pubspec yaml file
  JasprMode? readMode(YamlMap? pubspec) {
    if (pubspec?['jaspr'] case final YamlMap jaspr) {
      if (jaspr['mode'] case final String mode) {
        return JasprMode.values.where((v) => v.name == mode).firstOrNull;
      }
    }
    return null;
  }

  /// include a ref to the bootstrap script in the main document, used when jaspr.mode is either server or static
  Future<void> includeBootstrapRefInDoc(Directory projectRoot) async {
    final String? serverEntrypointPath = await getServerEntryPoint(null);
    if (serverEntrypointPath == null) {
      logger.write(
        "Couldn't find main.server.dart, You will need to add the following in the head of your Document: ${cyan.wrap('script(src: "flutter_bootstrap.js", async: true)')}",
        level: Level.warning,
        tag: Tag.cli,
      );
    } else {
      // the server entrypoint contains a document, so we'll insert the script ref in the head
      final String scriptTag = 'script(src: "flutter_bootstrap.js", async: true),';

      final File serverEntrypoint = File(serverEntrypointPath);
      final content = serverEntrypoint.readAsStringSync();

      final result = parseString(
        content: content,
        featureSet: FeatureSet.latestLanguageVersion(flags: ['dot-shorthands']),
      );
      final builder = EditBuilder(result.lineInfo);

      MethodInvocation? document;
      result.unit.visitChildren(DocumentVisitor((node) => document ??= node));

      // we didn't find the Document somehow, so warn the user that they must include the script ref themselves
      if (document == null) {
        warnManualIncludeRef();
        return;
      }

      final headArgument = document!.argumentList.arguments
          .whereType<NamedExpression>()
          .where((a) => a.name.label.name == 'head')
          .firstOrNull;

      if (headArgument == null) {
        // there was no head arg, so we add it as the first argument
        final anchor = document!.argumentList.arguments.firstOrNull;
        // we'll place the head arg right before the first existing arg, if there are none, we just place it after the left parenthesis of DOcument()
        final offset = anchor?.offset ?? document!.argumentList.leftParenthesis.end;
        builder.insert(offset, 'head: [\n        $scriptTag\n      ],\n      ');
      } else if (headArgument.expression case final ListLiteral list) {
        // if there already exists a head argument, we can add the script ref in there only if it doesn't already exist
        if (!list.toSource().contains('flutter_bootstrap.js')) {
          final indent = list.elements.isNotEmpty
              ? ''.padLeft(builder.getLineIndent(list.elements.last))
              : ''.padLeft(builder.getLineIndent(headArgument) + 2);
          builder.insert(list.rightBracket.offset, '$scriptTag\n$indent');
        }
      }

      // add an import for dom if not present
      final hasDomImport = result.unit.directives.whereType<ImportDirective>().any(
        (d) => d.uri.stringValue == 'package:jaspr/dom.dart',
      );

      // we place the import last, this gets sorted by dart format later on
      if (!hasDomImport) {
        final lastImport = result.unit.directives.whereType<ImportDirective>().lastOrNull;
        if (lastImport != null) {
          builder.insert(lastImport.end, "\nimport 'package:jaspr/dom.dart';");
        } else {
          // there were no other imports, add to the top
          builder.insert(0, "import 'package:jaspr/dom.dart';\n");
        }
      }

      serverEntrypoint.writeAsStringSync(builder.apply(content));
      Process.runSync('dart', ['format', serverEntrypoint.path, '--line-length=120']);
    }
  }

  /// include a ref to the flutter_bootstrap script in the index.html file
  /// used for client mode apps
  void includeInIndexHtml(Directory projectRoot) {
    final indexFile = File(p.join(projectRoot.path, 'web', 'index.html'));

    if (indexFile.existsSync()) {
      final html = indexFile.readAsStringSync();
      if (!html.contains('flutter_bootstrap.js')) {
        // place the script ref before the end of the head section
        final endOfHead = html.indexOf('</head>');
        indexFile.writeAsStringSync(
          html.replaceRange(endOfHead, endOfHead, '    <script src="flutter_bootstrap.js" async></script>\n'),
        );
      }
    } else {
      warnManualIncludeRef();
    }
  }

  /// warn the user if the reference to the flutter_bootstrap.js script was not automatically included
  void warnManualIncludeRef() {
    logger.write(
      'Could not automatically include the Flutter bootstrap script.\n'
      '${project.requireMode.isServerOrStatic ? 'Add this to the head of your Document:\n  ${green.wrap('script(src: "flutter_bootstrap.js", async: true),')}' : 'Add this to the head of web/index.html:\n  ${green.wrap('<script src="flutter_bootstrap.js" async></script>')}'}',
      tag: Tag.cli,
      level: Level.warning,
    );
  }
}

class DocumentVisitor extends RecursiveAstVisitor<void> {
  DocumentVisitor(this.onDocument);
  final void Function(MethodInvocation) onDocument;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name == 'Document') {
      onDocument(node);
      return;
    }
    super.visitMethodInvocation(node);
  }
}
