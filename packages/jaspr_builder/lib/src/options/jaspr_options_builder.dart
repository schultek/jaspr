import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart' as yaml;

import '../client/client_module_builder.dart';
import '../styles/styles_module_builder.dart';

/// Builds part files and web entrypoints for components annotated with @app
class JasprOptionsBuilder implements Builder {
  JasprOptionsBuilder(BuilderOptions options);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    try {
      await generateOptionsOutput(buildStep);
    } catch (e, st) {
      print('An unexpected error occurred.\n'
          'This is probably a bug in jaspr_builder.\n'
          'Please report this here: '
          'https://github.com/schultek/jaspr/issues\n\n'
          'The error was:\n$e\n\n$st');
      rethrow;
    }
  }

  @override
  Map<String, List<String>> get buildExtensions => const {
        r'lib/$lib$': ['lib/jaspr_options.dart'],
      };

  String get generationHeader => "// GENERATED FILE, DO NOT MODIFY\n"
      "// Generated with jaspr_builder\n";

  Future<void> generateOptionsOutput(BuildStep buildStep) async {
    final pubspecYaml = await buildStep.readAsString(AssetId(buildStep.inputId.package, 'pubspec.yaml'));
    final mode = yaml.loadYaml(pubspecYaml)?['jaspr']?['mode'];

    if (mode != 'static' && mode != 'server') {
      return;
    }

    final imports = ImportsWriter();

    final client = await loadClientOptions(imports, buildStep);
    final styles = await loadStylesOptions(imports, buildStep);

    final optionsId = AssetId(buildStep.inputId.package, 'lib/jaspr_options.dart');
    final optionsSource = DartFormatter(pageWidth: 120).format('''
      $generationHeader
      
      import 'package:jaspr/jaspr.dart';
      $imports
      
      /// Default [JasprOptions] for use with your jaspr project.
      ///
      /// Use this to initialize jaspr **before** calling [runApp].
      ///
      /// Example:
      /// ```dart
      /// import 'jaspr_options.dart';
      /// 
      /// void main() {
      ///   Jaspr.initializeApp(
      ///     options: defaultJasprOptions,
      ///   );
      ///   
      ///   runApp(...);
      /// }
      /// ```
      final defaultJasprOptions = JasprOptions(
        clients: {
          ${client.entries}
        },
        styles: [
          $styles
        ]
      );
      
      ${client.paramGetters}
      
    ''');

    await buildStep.writeAsString(optionsId, optionsSource);
  }

  Future<({String entries, String paramGetters})> loadClientOptions(ImportsWriter imports, BuildStep buildStep) async {
    final clients = await buildStep
        .findAssets(Glob('lib/**.client.json'))
        .asyncMap((id) => buildStep.readAsString(id))
        .map((c) => ClientModule.deserialize(jsonDecode(c)))
        .toList();

    final entries = StringBuffer();
    final paramGetters = StringBuffer();

    for (final (i, c) in clients.indexed) {
      final prefix = imports.add(c.id);

      entries.writeln('''
        $prefix.${c.name}: ClientTarget<$prefix.${c.name}>(
          '${path.url.relative(path.url.withoutExtension(c.id.path), from: 'lib')}'
          ${c.params.isNotEmpty ? ', params: _params$i${c.name}' : ''}
        ),
      ''');

      if (c.params.isNotEmpty) {
        paramGetters.writeln(
            'Map<String, dynamic> _params$i${c.name}($prefix.${c.name} c) => {${c.params.map((p) => "'${p.name}': ${p.encoder}").join(', ')}};');
      }
    }

    return (entries: entries.toString(), paramGetters: paramGetters.toString());
  }

  Future<String> loadStylesOptions(ImportsWriter imports, BuildStep buildStep) async {
    final styles = await buildStep
        .findAssets(Glob('lib/**.styles.json'))
        .asyncMap((id) => buildStep.readAsString(id))
        .map((c) => StylesModule.deserialize(jsonDecode(c)))
        .toList();

    final entries = StringBuffer();

    for (final s in styles) {
      final prefix = imports.add(s.id);

      entries.writeln(s.elements.map((e) => '...$prefix.$e,').join('\n'));
    }

    return entries.toString();
  }
}

class ImportsWriter {
  ImportsWriter();

  final List<String> imports = [];

  String add(AssetId id) {
    var url = path.url.relative(id.path, from: 'lib');
    var index = imports.indexOf(url);
    if (index == -1) {
      imports.add(url);
      return 'prefix${imports.length - 1}';
    }
    return 'prefix$index';
  }

  @override
  String toString() {
    return imports.mapIndexed((index, url) => "import '$url' as prefix$index;").join('\n');
  }
}
