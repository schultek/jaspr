import 'dart:io';

import 'package:mason/mason.dart' as m show Logger;
import 'package:mason/mason.dart' hide Level;
import 'package:path/path.dart' as p;

import '../bundles/bundles.dart';
import '../bundles/scaffold/scaffold_bundle.dart';
import '../helpers/print_logo.dart';
import '../logging.dart';
import '../process_runner.dart';
import '../project.dart';
import '../utils.dart';
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
}

class CreateCommand extends BaseCommand {
  CreateCommand({super.logger}) {
    argParser.addOption(
      'template',
      abbr: 't',
      help: 'The template to use for the project.',
      allowed: ['docs'],
      allowedHelp: {'docs': 'A template for creating a documentation site with jaspr_content.'},
    );
    argParser.addFlag(
      'pub-get',
      negatable: true,
      defaultsTo: true,
      help: 'Run "dart pub get" after creating the project.',
    );
    argParser.addSeparator('Project Presets:');
    argParser.addOption(
      'mode',
      abbr: 'm',
      help: 'Choose a rendering mode for the project.',
      allowed: [
        for (final m in RenderingMode.values) ...[m.name, if (m.useServer) '${m.name}:auto'],
      ],
      allowedHelp: {
        for (final v in RenderingMode.values) ...{
          v.name: '${v.help}.',
          if (v.useServer) '${v.name}:auto': '(Deprecated) ${v.help} with automatic client-side hydration.',
        },
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
        'plugins-only': 'Enables support for using Flutter web plugins.',
      },
    );
    argParser.addOption(
      'backend',
      abbr: 'b',
      help: 'Choose the backend setup for the project (only valid in "server" mode).',
      allowed: ['none', 'shelf'],
      allowedHelp: {'none': 'No custom backend setup.', 'shelf': 'Sets up a custom backend using the shelf package.'},
    );
  }

  @override
  String get invocation {
    return 'jaspr create [arguments] <directory>';
  }

  @override
  String get description => 'Create a new Jaspr project.';

  @override
  String get name => 'create';

  @override
  String get category => 'Project';

  late final bool runPubGet = argResults!.flag('pub-get');

  @override
  Future<int> runCommand() async {
    printLogo();

    final (dir, name) = await getTargetDirectory();

    final template = argResults!.option('template');
    if (template != null) {
      return await createFromTemplate(template, dir, name);
    }

    final useMode = await getRenderingMode();
    final (useRouting, useMultiPageRouting) = await getRouting(useMode.useServer);
    final useFlutterMode = await getFlutter();
    final useBackend = useMode == RenderingMode.server ? await getBackend() : null;

    final usedPrefixes = {
      if (useMode.useServer) 'server',
      if (useMode == RenderingMode.client) 'client',
      if (useRouting) 'routing',
      if (useFlutterMode == FlutterMode.embedded) 'flutter',
      if (useMode.useServer) useBackend ?? 'base',
    };

    final (jasprFlutterEmbedVersion, jasprRouterVersion, jasprLintsVersion, webCompilersVersion) = await (
      updater.getLatestVersion('jaspr_flutter_embed'),
      updater.getLatestVersion('jaspr_router'),
      updater.getLatestVersion('jaspr_lints'),
      updater.getLatestVersion('build_web_compilers'),
    ).wait;

    logger.write('\n');

    logger.write('Generating project...', progress: ProgressState.running);
    final generator = await MasonGenerator.fromBundle(scaffoldBundle);
    final files = await generator.generate(
      ScaffoldGeneratorTarget(dir, usedPrefixes),
      vars: {
        'name': name,
        'description': scaffoldBundle.description,
        'mode': useMode.name,
        'routing': useRouting,
        'multipage': useMultiPageRouting,
        'flutter': useFlutterMode == FlutterMode.embedded,
        'plugins': useFlutterMode == FlutterMode.plugins,
        'server': useMode.useServer,
        'shelf': useBackend == 'shelf',
        'jasprCoreVersion': jasprCoreVersion,
        'jasprBuilderVersion': jasprBuilderVersion,
        'jasprFlutterEmbedVersion': jasprFlutterEmbedVersion,
        'jasprRouterVersion': jasprRouterVersion,
        'jasprLintsVersion': jasprLintsVersion,
        'webCompilersVersion': webCompilersVersion,
      },
    );
    logger.write('Generated ${files.length} file(s)', progress: ProgressState.completed);

    if (runPubGet) {
      final process = await ProcessRunner.instance.start(dartExecutable, [
        'pub',
        'get',
      ], workingDirectory: dir.absolute.path);

      await watchProcess(
        'pub',
        process,
        progress: 'Resolving dependencies...',
        hide: (s) => s == '...' || s.contains('+'),
        onComplete: (code) {
          if (code == 0) {
            logger.write('Finished getting dependencies', progress: ProgressState.running);
          } else {
            logger.write('Failed to get dependencies', level: Level.error, progress: ProgressState.running);
          }
        },
      );
    }

    final relativePath = p.relative(dir.path, from: Directory.current.absolute.path);
    final commands = [
      if (relativePath != '.') 'cd $relativePath',
      'jaspr serve',
    ];

    logger.write('\n');
    logger.write(
      wrapBox(
        'Created project ${cyan.wrap(styleBold.wrap(name))}!\n'
        '\n'
        'In order to get started, run the following commands:\n'
        '\n'
        '${commands.map((cmd) => '  ${darkGray.wrap('\$')} ${styleBold.wrap(cmd)}').join('\n')}',
        borderColor: green,
      ),
    );

    return 0;
  }

  Future<int> createFromTemplate(String template, Directory dir, String name) async {
    final bundle = templates[template];
    if (bundle == null) {
      usageException('Template "$template" not found.');
    }

    final (
      jasprFlutterEmbedVersion,
      jasprRouterVersion,
      jasprContentVersion,
      jasprLintsVersion,
      webCompilersVersion,
    ) = await (
      updater.getLatestVersion('jaspr_flutter_embed'),
      updater.getLatestVersion('jaspr_router'),
      updater.getLatestVersion('jaspr_content'),
      updater.getLatestVersion('jaspr_lints'),
      updater.getLatestVersion('build_web_compilers'),
    ).wait;

    logger.write('Generating project from template "$template"...', tag: Tag.cli, progress: ProgressState.running);
    final generator = await MasonGenerator.fromBundle(bundle);
    final files = await generator.generate(
      DirectoryGeneratorTarget(dir),
      vars: {
        'name': name,
        'description': bundle.description,
        'jasprCoreVersion': jasprCoreVersion,
        'jasprBuilderVersion': jasprBuilderVersion,
        'jasprFlutterEmbedVersion': jasprFlutterEmbedVersion,
        'jasprRouterVersion': jasprRouterVersion,
        'jasprContentVersion': jasprContentVersion,
        'jasprLintsVersion': jasprLintsVersion,
        'webCompilersVersion': webCompilersVersion,
      },
    );
    logger.write('Generated ${files.length} file(s)', tag: Tag.cli, progress: ProgressState.completed);

    if (runPubGet) {
      final process = await ProcessRunner.instance.start(dartExecutable, [
        'pub',
        'get',
      ], workingDirectory: dir.absolute.path);

      await watchProcess(
        'pub',
        process,
        tag: Tag.cli,
        progress: 'Resolving dependencies...',
        hide: (s) => s == '...' || s.contains('+'),
      );
    }

    logger.write(
      '\n'
      'Created project $name! In order to get started, run the following commands:\n\n',
    );

    final relativePath = p.relative(dir.path, from: Directory.current.absolute.path);
    if (relativePath != '.') {
      logger.write('  cd $relativePath\n');
    }
    logger.write('  jaspr serve\n');

    return 0;
  }

  Future<(Directory, String)> getTargetDirectory() async {
    final targetPath = argResults!.rest.firstOrNull ?? await logger.prompt('Specify a target directory:');

    final directory = Directory(targetPath).absolute;
    final dir = p.basenameWithoutExtension(p.normalize(directory.path));
    final name = dir.replaceAll('-', '_');

    if (directory.existsSync()) {
      if (targetPath != '.') {
        usageException('Directory $targetPath already exists.');
      } else if (directory.listSync().isNotEmpty) {
        usageException('Directory must be empty.');
      }
    }

    if (name.isEmpty || !_packageRegExp.hasMatch(name)) {
      usageException('"$name" is not a valid package name.');
    }

    return (directory, name);
  }

  Future<RenderingMode> getRenderingMode() async {
    final opt = argResults!.option('mode');
    return switch (opt?.split(':')) {
      ['client'] => RenderingMode.client,
      [final m, 'auto'] => () {
        logger.write(
          'The ":auto" suffix for "--mode" is deprecated and will be removed in a future release. '
          'Automatic hydration is enabled by default.',
          level: Level.warning,
        );

        return RenderingMode.values.byName(m);
      }(),
      [final m] => RenderingMode.values.byName(m),

      _ => await () async {
        if (!stdout.hasTerminal) {
          throw usageException('No rendering mode specified.');
        }
        final mode = await logger.chooseOne(
          'Select a rendering mode:',
          choices: RenderingMode.values,
          display: (o) => '${o.name}: ${o.help}.',
        );
        return mode;
      }(),
    };
  }

  Future<(bool, bool)> getRouting(bool useServer) async {
    final opt = argResults!.option('routing');

    return switch (opt) {
      'none' => (false, false),
      'single-page' => (true, false),
      'multi-page' => !useServer ? usageException('Cannot use multi-page routing in client mode.') : (true, true),
      _ => await () async {
        if (!stdout.hasTerminal) {
          return useServer ? (true, true) : (true, false);
        }
        final routing = await logger.confirm('Setup routing for different pages of your site?', defaultValue: true);
        final multiPage = routing && useServer
            ? await logger.confirm(
                '(Recommended) Use multi-page (server-side) routing?',
                defaultValue: true,
                hint: 'Choosing [no] sets up a single-page application with client-side routing instead.',
              )
            : false;
        return (routing, multiPage);
      }(),
    };
  }

  Future<FlutterMode> getFlutter() async {
    final opt = argResults!.option('flutter');

    return switch (opt) {
      'none' => FlutterMode.none,
      'embedded' => FlutterMode.embedded,
      'plugins-only' => FlutterMode.plugins,
      _ => await () async {
        if (!stdout.hasTerminal) {
          return FlutterMode.none;
        }
        final flutter = await logger.confirm('Setup Flutter web embedding?', defaultValue: false);
        if (flutter) {
          return FlutterMode.embedded;
        }
        final plugins = await logger.confirm(
          'Enable support for using Flutter web plugins in your project?',
          defaultValue: false,
        );
        if (plugins) {
          return FlutterMode.plugins;
        }
        return FlutterMode.none;
      }(),
    };
  }

  Future<String?> getBackend() async {
    final opt = argResults!.option('backend');

    return switch (opt) {
      'none' => null,
      final String b => b,
      null => await () async {
        if (!stdout.hasTerminal) {
          return null;
        }
        final backend = await logger.confirm(
          'Use a custom backend package or framework for the server part of your project?',
          defaultValue: false,
        );
        if (!backend) return null;

        final b = (await logger.chooseOne(
          'Select a backend framework:',
          choices: [
            ('shelf', 'Shelf: An official and well-supported minimal server package by the Dart Team.'),
            // (
            //   'dart_frog',
            //   'Dart Frog: (Coming Soon) A fast, minimalistic backend framework for Dart built by Very Good Ventures.',
            // ),
          ],
          display: (o) => o.$2,
        )).$1;

        // if (b == 'dart_frog') {
        //   usageException('Support for Dart Frog is coming soon.');
        // }

        return b;
      }(),
    };
  }
}

class ScaffoldGeneratorTarget extends DirectoryGeneratorTarget {
  ScaffoldGeneratorTarget(super.dir, this.prefixes);

  final Set<String> prefixes;

  @override
  Future<GeneratedFile> createFile(
    String path,
    List<int> contents, {
    m.Logger? logger,
    OverwriteRule? overwriteRule,
  }) async {
    final filename = p.basename(path);
    if (filename.contains('#')) {
      final [prefix, ...] = filename.split('#');

      if (!prefixes.contains(prefix)) {
        return GeneratedFile.skipped(path: path);
      }

      path = path.replaceFirst('$prefix#', '');
    }

    return await super.createFile(path, contents, logger: logger, overwriteRule: overwriteRule);
  }
}
