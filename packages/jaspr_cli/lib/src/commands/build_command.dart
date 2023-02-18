// ignore_for_file: depend_on_referenced_packages, implementation_imports

import 'dart:async';
import 'dart:io';

import 'package:build_daemon/data/build_status.dart';
import 'package:build_daemon/data/build_target.dart';
import 'package:collection/collection.dart';
import 'package:logging/logging.dart' as ll;
import 'package:mason/mason.dart';
import 'package:webdev/src/daemon_client.dart' as d;
import 'package:webdev/src/logging.dart' as l;

import 'base_command.dart';

class BuildCommand extends BaseCommand {
  BuildCommand({super.logger}) {
    argParser.addOption(
      'input',
      abbr: 'i',
      help: 'Specify the input file for the web app',
      defaultsTo: 'lib/main.dart',
    );
    argParser.addFlag(
      'ssr',
      defaultsTo: true,
      help: 'Optionally disables server-side rendering and runs as a pure client-side app.',
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
  String get description => 'Performs a single build on the specified target and then exits.';

  @override
  String get name => 'build';

  @override
  Future<int> run() async {
    await super.run();

    var useSSR = argResults!['ssr'] as bool;

    if (useSSR) {
      var dir = Directory('build');
      if (!await dir.exists()) {
        await dir.create();
      }
    }

    var webResult = _buildWeb(true, useSSR);
    if (useSSR) {
      String? entryPoint = await getEntryPoint(argResults!['input']);

      if (entryPoint == null) {
        logger.warn(
            "Cannot find entry point. Create a main.dart in lib/ or web/, or specify a file using --input.");
        await shutdown(1);
      }

      logger.info('Building server app...');

      var process = await Process.start(
        'dart',
        [
          'compile',
          argResults!['target'],
          entryPoint,
          '-o',
          './build/app',
          '-Djaspr.flags.release=true'
        ],
      );

      await watchProcess(process);
    }

    await webResult;

    logger.success('Completed building project to /build.');
    return ExitCode.success.code;
  }

  Future<int> _buildWeb(bool release, bool useSSR) async {
    logger.info('Building web assets...');
    var client = await d.connectClient(
      Directory.current.path,
      [
        '--release',
        '--verbose',
        '--delete-conflicting-outputs',
        '--define=build_web_compilers:entrypoint=dart2js_args=["-Djaspr.flags.release=true"]'
      ],
      (serverLog) {
        if (!verbose) return;
        //if (serverLog.level < Level.INFO) return;

        var log = l.formatLog(ll.Level.INFO, serverLog.message,
            error: serverLog.error,
            loggerName: serverLog.loggerName,
            stackTrace: serverLog.stackTrace,
            withColors: true);

        if (!log.endsWith('\n')) {
          log += '\n';
        }

        logger.write(log);
      },
    );
    OutputLocation outputLocation = OutputLocation((b) => b
      ..output = 'build${useSSR ? '/web' : ''}'
      ..useSymlinks = false
      ..hoist = true);

    client.registerBuildTarget(DefaultBuildTarget((b) => b
      ..target = 'web'
      ..outputLocation = outputLocation.toBuilder()));

    client.startBuild();

    var exitCode = 0;
    var gotBuildStart = false;
    await for (final result in client.buildResults) {
      var targetResult =
          result.results.firstWhereOrNull((buildResult) => buildResult.target == 'web');
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
        logger.alert(error);
      }
      break;
    }
    await client.close();
    if (exitCode == 0) {
      logger.info('Completed building web assets.');
    }
    return exitCode;
  }
}
