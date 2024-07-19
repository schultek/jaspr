import 'dart:io';

import 'package:mason/mason.dart' as m show Logger;
import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;
import 'package:pub_updater/pub_updater.dart';

import '../logging.dart';
import '../scaffold/scaffold_bundle.dart';
import '../version.dart';
import 'base_command.dart';

final RegExp _packageRegExp = RegExp(r'^[a-z_][a-z0-9_]*$');

enum RenderingMode {
  static('Build a statically pre-rendered site'),
  server('Build a server-rendered site'),
  client('Build a purely client-rendered site');

  const RenderingMode(this.help);

  final String help;

  bool get useServer => this == server || this == static;
  String get recommend => this == static ? '(Recommended) ' : '';
}

class CreateCommand extends BaseCommand {
  CreateCommand({super.logger}) {
    argParser.addSeparator('Project Presets:');
    argParser.addOption(
      'mode',
      abbr: 'm',
      help: 'Choose a rendering mode for the project.',
      allowed: [
        for (var m in RenderingMode.values) ...[m.name, if (m.useServer) '${m.name}:auto']
      ],
      allowedHelp: {
        for (var v in RenderingMode.values) ...{
          v.name: '${v.help}.',
          if (v.useServer) '${v.name}:auto': '${v.recommend}${v.help} with automatic client-side hydration.',
        }
      },
    );
    argParser.addOption(
      'routing',
      abbr: 'r',
      help: 'Choose a routing strategy for the project.',
      allowed: ['none', 'multi-page', 'single-page'],
      allowedHelp: {
        'none': 'No preconfigured routing.',
        'multi-page': '(Recommended) Sets up multi-page (server-side) routing.',
        'single-page': 'Sets up single-page (client-side) routing.',
      },
    );
    argParser.addOption(
      'flutter',
      abbr: 'f',
      help: 'Choose the Flutter support for the project.',
      allowed: ['none', 'embedded', 'plugins-only'],
      allowedHelp: {
        'none': 'No preconfigured Flutter support.',
        'embedded': 'Sets up an embedded Flutter app inside your site.',
        'plugins-only': '(Recommended) Enables support for using Flutter web plugins.'
      },
    );
    argParser.addOption(
      'backend',
      abbr: 'b',
      help: 'Choose the backend setup for the project (only valid in "server" mode).',
      allowed: ['none', 'shelf'],
      allowedHelp: {
        'none': 'No custom backend setup.',
        'shelf': 'Sets up a custom backend using the shelf package.',
      },
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
  Future<CommandResult?> run() async {
    await super.run();

    var (dir, name) = getTargetDirectory();

    var (useMode, useHydration) = getRenderingMode();
    var (useRouting, useMultiPageRouting) = getRouting(useMode.useServer, useHydration);
    var (useFlutter, usePlugins) = getFlutter();
    var useBackend = useMode == RenderingMode.server ? getBackend() : null;

    var description = 'A new jaspr project.';

    var usedPrefixes = {
      if (useMode.useServer) 'server',
      if (useMode == RenderingMode.client) 'client',
      if (useRouting) 'routing',
      if (useHydration) 'hydration',
      if (useFlutter) 'flutter',
      if (useMode == RenderingMode.client || !useHydration) 'manual',
      if (useMode.useServer) useBackend ?? 'base',
    };

    var updater = PubUpdater();

    var webCompilersPackage = usePlugins ? 'jaspr_web_compilers' : 'build_web_compilers';

    var [
      jasprFlutterEmbedVersion,
      jasprRouterVersion,
      webCompilersVersion,
    ] = await Future.wait([
      updater.getLatestVersion('jaspr_flutter_embed'),
      updater.getLatestVersion('jaspr_router'),
      updater.getLatestVersion(webCompilersPackage),
    ]);

    var progress = logger.logger.progress('Generating project...');
    var generator = await MasonGenerator.fromBundle(scaffoldBundle);
    final files = await generator.generate(
      ScaffoldGeneratorTarget(dir, usedPrefixes),
      vars: {
        'name': name,
        'description': description,
        'mode': useMode.name,
        'routing': useRouting,
        'multipage': useMultiPageRouting,
        'flutter': useFlutter,
        'plugins': usePlugins,
        'hydration': useHydration,
        'server': useMode.useServer,
        'shelf': useBackend == 'shelf',
        'jasprCoreVersion': jasprCoreVersion,
        'jasprBuilderVersion': jasprBuilderVersion,
        'jasprFlutterEmbedVersion': jasprFlutterEmbedVersion,
        'jasprRouterVersion': jasprRouterVersion,
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
        'Created project $name! In order to get started, run the following commands:\n\n'
        '  cd ${p.relative(dir.path, from: Directory.current.absolute.path)}\n'
        '  jaspr serve\n');

    return null;
  }

  (Directory, String) getTargetDirectory() {
    var targetPath = argResults!.rest.firstOrNull ?? logger.logger.prompt('Specify a target directory:');

    var directory = Directory(targetPath).absolute;
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

  (RenderingMode, bool) getRenderingMode() {
    var opt = argResults!['mode'] as String?;
    return switch (opt?.split(':')) {
      ['client'] => (RenderingMode.client, false),
      [var m, 'auto'] => (RenderingMode.values.byName(m), true),
      [var m] => (RenderingMode.values.byName(m), false),
      _ => () {
          var mode = logger.logger.chooseOne(
            'Select a rendering mode:',
            choices: RenderingMode.values,
            display: (o) => '${o.name}: ${o.help}.',
          );
          var hydration = mode.useServer &&
              logger.logger.confirm('(Recommended) Enable automatic hydration on the client?', defaultValue: true);
          return (mode, hydration);
        }(),
    };
  }

  (bool, bool) getRouting(bool useServer, bool useHydration) {
    var opt = argResults!['routing'] as String?;

    return switch (opt) {
      'none' => (false, false),
      'single-page' => (true, false),
      'multi-page' => (true, true),
      _ => () {
          var routing = logger.logger.confirm('Setup routing for different pages of your site?', defaultValue: true);
          var multiPage = routing && useServer && useHydration
              ? logger.logger.confirm(
                  '(Recommended) Use multi-page (server-side) routing? '
                  '${darkGray.wrap('Choosing [no] sets up a single-page application with client-side routing instead.')}',
                  defaultValue: true,
                )
              : false;
          return (routing, multiPage);
        }(),
    };
  }

  (bool, bool) getFlutter() {
    var opt = argResults!['flutter'] as String?;

    return switch (opt) {
      'none' => (false, false),
      'embedded' => (true, true),
      'plugins-only' => (false, true),
      _ => () {
          var flutter = logger.logger.confirm('Setup Flutter web embedding?', defaultValue: false);
          var plugins = flutter ||
              logger.logger.confirm(
                'Enable support for using Flutter web plugins in your project?',
                defaultValue: true,
              );
          return (flutter, plugins);
        }(),
    };
  }

  String? getBackend() {
    var opt = argResults!['backend'] as String?;

    return switch (opt) {
      'none' => null,
      String b => b,
      null => () {
          var backend = logger.logger.confirm(
            'Use a custom backend package or framework for the server part of your project?',
            defaultValue: false,
          );
          if (!backend) return null;

          var b = logger.logger
              .chooseOne(
                'Select a backend framework:',
                choices: [
                  ('shelf', 'Shelf: An official and well-supported minimal server package by the Dart Team.'),
                  (
                    'dart_frog',
                    'Dart Frog: (Coming Soon) A fast, minimalistic backend framework for Dart built by Very Good Ventures.'
                  ),
                ],
                display: (o) => o.$2,
              )
              .$1;

          if (b == 'dart_frog') {
            usageException('Support for Dart Frog is coming soon.');
          }

          return b;
        }(),
    };
  }
}

class ScaffoldGeneratorTarget extends DirectoryGeneratorTarget {
  ScaffoldGeneratorTarget(super.dir, this.prefixes);

  final Set<String> prefixes;

  @override
  Future<GeneratedFile> createFile(String path, List<int> contents,
      {m.Logger? logger, OverwriteRule? overwriteRule}) async {
    var filename = p.basename(path);
    if (filename.contains('#')) {
      var [prefix, ...] = filename.split('#');

      if (!prefixes.contains(prefix)) {
        return GeneratedFile.skipped(path: path);
      }

      path = path.replaceFirst('$prefix#', '');
    }

    return await super.createFile(path, contents, logger: logger, overwriteRule: overwriteRule);
  }
}
