import 'dart:io';

import 'package:mason/mason.dart' as m show Logger;
import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;
import 'package:pub_updater/pub_updater.dart';

import '../logging.dart';
import '../scaffold/base_bundle.dart';
import '../templates.dart';
import '../version.dart';
import 'base_command.dart';

final RegExp _packageRegExp = RegExp(r'^[a-z_][a-z0-9_]*$');

final templatesByName = {for (var t in templates) t.name: t};
final templateDescriptionByName = {for (var t in templates) t.name: t.description};

class CreateCommand extends BaseCommand {
  CreateCommand({super.logger}) {
    argParser.addOption(
      'template',
      abbr: 't',
      help: 'The template used to generate this new project.',
      allowed: templatesByName.keys,
      allowedHelp: templateDescriptionByName,
    );
    argParser.addFlag(
      'jaspr-web-compilers',
      abbr: 'c',
      help: 'Uses jaspr_web_compilers. This enables the use of flutter web plugins and direct flutter embedding.',
      defaultsTo: null,
    );
  }

  @override
  String get invocation {
    return "jaspr create [arguments] <directory>";
  }

  @override
  String get description => 'Creates a new jaspr project.';

  @override
  String get name => 'create';

  @override
  String get category => 'Project';

  @override
  bool get requiresPubspec => false;

  @override
  Future<int> run() async {
    await super.run();

    var (dir, name) = getTargetDirectory();

    var mode = getMode();
    var useHydration = mode != 'client' ? getUseHydration() : false;
    var useRouting = getUseRouting();
    var useMultiPageRouting = useRouting && mode != 'client' ? getUseMultiPageRouting() : false;
    var useFlutter = getUseFlutter();
    var useFlutterPlugins = useFlutter || getUseFlutterPlugins();
    var useBackend = mode == 'server' && getUseCustomBackend() ? getCustomBackend() : null;

    var description = 'A new jaspr project.';

    var usedPrefixes = {
      if (mode == 'server' || mode == 'static') 'server',
      if (mode == 'client') 'client',
      if (useHydration) 'hydration',
      if (useFlutter) 'flutter',
      useBackend ?? 'base',
    };

    var updater = PubUpdater();

    var webCompilersPackage = useFlutterPlugins ? 'jaspr_web_compilers' : 'build_web_compilers';

    var [
      jasprFlutterEmbedVersion,
      webCompilersVersion,
    ] = await Future.wait([
      updater.getLatestVersion('jaspr_flutter_embed'),
      updater.getLatestVersion(webCompilersPackage),
    ]);

    var progress = logger.logger.progress('Generating project...');
    var generator = await MasonGenerator.fromBundle(baseBundle);
    final files = await generator.generate(
      ScaffoldGeneratorTarget(dir, usedPrefixes),
      vars: {
        'name': name,
        'description': description,
        'mode': mode,
        'flutter': useFlutter,
        'hydration': useHydration,
        'shelf': useBackend == 'shelf',
        'jasprCoreVersion': jasprCoreVersion,
        'jasprBuilderVersion': jasprBuilderVersion,
        'jasprFlutterEmbedVersion': jasprFlutterEmbedVersion,
        'webCompilersPackage': webCompilersPackage,
        'webCompilersVersion': webCompilersVersion,
      },
      logger: logger.logger,
    );
    progress.complete('Generated ${files.length} file(s)');

    var process = await Process.start('dart', ['pub', 'get'], workingDirectory: dir.absolute.path);

    await watchProcess('pub', process,
        tag: Tag.cli, progress: 'Resolving dependencies...', hide: (s) => s == '...' || s.contains('+'));

    logger.write('\n'
        'Created project $name in $dir! In order to get started, run the following commands:\n\n'
        '  cd $dir\n'
        '  jaspr serve\n');

    return ExitCode.success.code;
  }

  (Directory, String) getTargetDirectory() {
    var targetPath = argResults!.rest.firstOrNull ?? logger.logger.prompt('Specify a target directory:');

    var directory = Directory(targetPath);
    var dir = p.basenameWithoutExtension(directory.path);
    var name = dir.replaceAll('-', '_');

    if (directory.existsSync()) {
      usageException('Directory $targetPath already exists.');
    }

    if (name.isEmpty) {
      usageException('You must specify a snake_case package name.');
    } else if (!_packageRegExp.hasMatch(name)) {
      usageException('"$name" is not a valid package name.\n\n'
          'You should use snake_case for the package name e.g. my_jaspr_project');
    }

    return (directory, name);
  }

  String getMode() {
    return logger.logger
        .chooseOne(
          'Select a rendering mode:',
          choices: [
            ('static', 'Build a statically prerendered site with optional client-side rendering.'),
            ('server', 'Build a server-rendered site with optional client-side hydration.'),
            ('client', 'Build a purely client-rendered site.'),
          ],
          display: (o) => '${o.$1}: ${o.$2}',
        )
        .$1;
  }

  bool getUseHydration() {
    return logger.logger
        .confirm('(Recommended) Setup automatic client hydration for interactivity?', defaultValue: true);
  }

  bool getUseRouting() {
    return logger.logger.confirm('Setup routing for different pages of your site?', defaultValue: true);
  }

  bool getUseMultiPageRouting() {
    return logger.logger.confirm(
      '(Recommended) Use multi-page routing? '
      '${darkGray.wrap('Choosing [no] sets up a single-page application with client-side routing instead.')}',
      defaultValue: true,
    );
  }

  bool getUseFlutter() {
    return logger.logger.confirm('Setup Flutter web embedding?', defaultValue: false);
  }

  bool getUseFlutterPlugins() {
    return logger.logger.confirm(
      'Enable support for using Flutter web plugins in your project?',
      defaultValue: true,
    );
  }

  bool getUseCustomBackend() {
    return logger.logger.confirm(
      'Use a custom backend package or framework for the server part of your project?',
      defaultValue: false,
    );
  }

  String getCustomBackend() {
    return logger.logger
        .chooseOne(
          'Select a backend framework:',
          choices: [
            ('shelf', 'Shelf: An official and well-supported minimal server package by the Dart Team.'),
            ('dartfrog', 'Dart Frog: A fast, minimalistic backend framework for Dart built by Very Good Ventures.'),
          ],
          display: (o) => o.$2,
        )
        .$1;
  }
}

class ScaffoldGeneratorTarget extends DirectoryGeneratorTarget {
  ScaffoldGeneratorTarget(super.dir, this.prefixes);

  final Set<String> prefixes;

  @override
  Future<GeneratedFile> createFile(String path, List<int> contents,
      {m.Logger? logger, OverwriteRule? overwriteRule}) async {
    var filename = p.basename(path);
    if (filename.contains(':')) {
      var [prefix, ...] = filename.split(':');

      if (!prefixes.contains(prefix)) {
        return GeneratedFile.skipped(path: path);
      }

      path = path.replaceFirst('$prefix:', '');
    }

    return await super.createFile(path, contents, logger: logger, overwriteRule: overwriteRule);
  }
}
