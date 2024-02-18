// ignore_for_file: depend_on_referenced_packages, implementation_imports

import 'dart:async';
import 'dart:io';

import 'package:build_daemon/data/build_status.dart';
import 'package:build_daemon/data/build_target.dart';
import 'package:collection/collection.dart';
import 'package:mason/mason.dart' show ExitCode;
import 'package:webdev/src/daemon_client.dart' as d;

import '../helpers/flutter_helpers.dart';
import '../helpers/ssr_helper.dart';
import '../logging.dart';
import 'base_command.dart';

class BuildCommand extends BaseCommand with SsrHelper, FlutterHelper {
  BuildCommand({super.logger}) {
    argParser.addOption(
      'input',
      abbr: 'i',
      help: 'Specify the input file for the server app',
      defaultsTo: 'lib/main.dart',
    );
    argParser.addOption(
      'target',
      abbr: 't',
      allowed: ['aot-snapshot', 'exe', 'jit-snapshot'],
      allowedHelp: {
        'aot-snapshot': 'Compile Dart to an AOT snapshot.',
        'exe': 'Compile Dart to a self-contained executable.',
        'jit-snapshot': 'Compile Dart to a JIT snapshot.',
      },
      defaultsTo: 'exe',
    );
  }

  @override
  String get description => 'Builds the full project.';

  @override
  String get name => 'build';

  @override
  String get category => 'Project';

  @override
  Future<int> run() async {
    await super.run();

    var dir = Directory('build/jaspr');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    if (useSSR) {
      var webDir = Directory('build/jaspr/web');
      if (!await webDir.exists()) {
        await webDir.create();
      }
    }

    var indexHtml = File('web/index.html');
    var targetIndexHtml = File('build/jaspr/web/index.html');

    var dummyIndex = false;
    if (usesFlutter && !await indexHtml.exists()) {
      dummyIndex = true;
      await indexHtml.create();
    }

    var webResult = _buildWeb(true, useSSR);
    var flutterResult = Future<void>.value();

    if (usesFlutter) {
      await webResult;
      flutterResult = buildFlutter(useSSR);
    }

    if (useSSR) {
      String? entryPoint = await getEntryPoint(argResults!['input']);

      if (entryPoint == null) {
        logger.write("Cannot find entry point. Create a main.dart in lib/ or web/, or specify a file using --input.",
            level: Level.critical);
        await shutdown(1);
      }

      await webResult;

      logger.write('Building server app...', progress: ProgressState.running);
      String extension = '';
      final target = argResults!['target'];
      if (Platform.isWindows && target == 'exe') {
        extension = '.exe';
      }

      var process = await Process.start(
        'dart',
        [
          'compile',
          argResults!['target'],
          entryPoint,
          '-o',
          './build/jaspr/app$extension',
          '-Djaspr.flags.release=true',
        ],
      );

      await watchProcess('server build', process, tag: Tag.cli, progress: 'Building server app...');
    }

    await Future.wait([
      webResult,
      flutterResult,
    ]);

    if (dummyIndex) {
      await indexHtml.delete();
      if (await targetIndexHtml.exists()) {
        await targetIndexHtml.delete();
      }
    }

    logger.write('Completed building project to /build.', progress: ProgressState.completed);
    return ExitCode.success.code;
  }

  Future<int> _buildWeb(bool release, bool useSSR) async {
    logger.write('Building web assets...', progress: ProgressState.running);
    var client = await d.connectClient(
      Directory.current.path,
      [
        '--release',
        '--verbose',
        '--delete-conflicting-outputs',
        '--define=${usesJasprWebCompilers ? 'jaspr' : 'build'}_web_compilers:entrypoint=dart2js_args=["-Djaspr.flags.release=true"]'
      ],
      logger.writeServerLog,
    );
    OutputLocation outputLocation = OutputLocation((b) => b
      ..output = 'build/jaspr${useSSR ? '/web' : ''}'
      ..useSymlinks = false
      ..hoist = true);

    client.registerBuildTarget(DefaultBuildTarget((b) => b
      ..target = 'web'
      ..outputLocation = outputLocation.toBuilder()));

    client.startBuild();

    var exitCode = 0;
    var gotBuildStart = false;
    await for (final result in client.buildResults) {
      var targetResult = result.results.firstWhereOrNull((buildResult) => buildResult.target == 'web');
      if (targetResult == null) continue;
      // We ignore any builds that happen before we get a `started` event,
      // because those could be stale (from some other client).
      gotBuildStart = gotBuildStart || targetResult.status == BuildStatus.started;
      if (!gotBuildStart) continue;

      // Shouldn't happen, but being a bit defensive here.
      if (targetResult.status == BuildStatus.started) continue;

      if (targetResult.status == BuildStatus.failed) {
        exitCode = 1;
      }

      var error = targetResult.error ?? '';
      if (error.isNotEmpty) {
        logger.complete(false);
        logger.write(error, level: Level.error);
      }
      break;
    }
    await client.close();
    if (exitCode == 0) {
      logger.write('Completed building web assets.', progress: ProgressState.completed);
    }
    return exitCode;
  }
}
