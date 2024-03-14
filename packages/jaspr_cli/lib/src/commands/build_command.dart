// ignore_for_file: depend_on_referenced_packages, implementation_imports

import 'dart:async';
import 'dart:io';

import 'package:build_daemon/data/build_status.dart';
import 'package:build_daemon/data/build_target.dart';
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'package:mason/mason.dart' show ExitCode;
import 'package:webdev/src/daemon_client.dart' as d;

import '../config.dart';
import '../helpers/flutter_helpers.dart';
import '../helpers/proxy_helper.dart';
import '../logging.dart';
import 'base_command.dart';

class BuildCommand extends BaseCommand with ProxyHelper, FlutterHelper {
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
      help: 'Specify the compilation target for the executable (only in server mode)',
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

    logger.write("Building jaspr for ${config!.mode.name} rendering mode.");

    var dir = Directory('build/jaspr').absolute;
    var webDir = config!.mode == JasprMode.server ? Directory('build/jaspr/web').absolute : dir;

    String? entryPoint;
    if (config!.mode != JasprMode.client) {
      entryPoint = await getEntryPoint(argResults!['input']);
    }

    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
    await webDir.create(recursive: true);

    var indexHtml = File('web/index.html').absolute;
    var targetIndexHtml = File('${webDir.path}/index.html').absolute;

    var dummyIndex = false;
    var dummyTargetIndex = false;
    if (config!.usesFlutter && !await indexHtml.exists()) {
      dummyIndex = true;
      dummyTargetIndex = true;
      await indexHtml.create();
    }

    var webResult = _buildWeb();
    var flutterResult = Future<void>.value();

    await webResult;

    if (config!.usesFlutter) {
      flutterResult = buildFlutter();
    }

    if (config!.mode == JasprMode.server) {
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
          entryPoint!,
          '-o',
          './build/jaspr/app$extension',
          '-Djaspr.flags.release=true',
        ],
        runInShell: true,
      );

      await watchProcess('server build', process, tag: Tag.cli, progress: 'Building server app...');
    } else if (config!.mode == JasprMode.static) {
      logger.write('Building server app...', progress: ProgressState.running);

      Set<String> generatedRoutes = {};
      List<String> queuedRoutes = [];

      var serverStartedCompleter = Completer();

      await startProxy('5567', webPort: '0', onMessage: (message) {
        if (message case {'route': String route}) {
          if (!serverStartedCompleter.isCompleted) {
            serverStartedCompleter.complete();
          }
          if (generatedRoutes.contains(route)) {
            return;
          }
          queuedRoutes.insert(0, route);
          generatedRoutes.add(route);
        }
      });

      var process = await Process.start(
        'dart',
        [
          'run',
          '--enable-asserts',
          '-Djaspr.flags.release=true',
          '-Djaspr.flags.generate=true',
          '-Djaspr.dev.web=build/jaspr',
          entryPoint!,
        ],
        runInShell: true,
        environment: {'PORT': '8080', 'JASPR_PROXY_PORT': '5567'},
        workingDirectory: Directory.current.absolute.path,
      );

      watchProcess('server', process, tag: Tag.server, progress: 'Running server app...');

      await serverStartedCompleter.future;

      logger.complete(true);

      logger.write('Generating routes...', progress: ProgressState.running);

      while (queuedRoutes.isNotEmpty) {
        var route = queuedRoutes.removeLast();

        logger.write('Generating route "$route"...', progress: ProgressState.running);

        var response = await http.get(Uri.parse('http://localhost:8080$route'));

        var filename = route.endsWith('/') ? '${route}index.html' : '$route.html';

        var file = File('build/jaspr$filename').absolute;

        await file.create(recursive: true);
        await file.writeAsBytes(response.bodyBytes);
      }

      process.kill();

      logger.complete(true);

      dummyTargetIndex &= !(generatedRoutes.contains('/') || generatedRoutes.contains('/index'));
    }

    await flutterResult;

    if (dummyIndex) {
      await indexHtml.delete();
      if (dummyTargetIndex && await targetIndexHtml.exists()) {
        await targetIndexHtml.delete();
      }
    }

    logger.write('Completed building project to /build/jaspr.', progress: ProgressState.completed);
    return ExitCode.success.code;
  }

  Future<int> _buildWeb() async {
    logger.write('Building web assets...', progress: ProgressState.running);
    var client = await d.connectClient(
      Directory.current.path,
      [
        '--release',
        '--verbose',
        '--delete-conflicting-outputs',
        '--define=${config!.usesJasprWebCompilers ? 'jaspr' : 'build'}_web_compilers:entrypoint=dart2js_args=["-Djaspr.flags.release=true"]'
      ],
      logger.writeServerLog,
    );
    OutputLocation outputLocation = OutputLocation((b) => b
      ..output = 'build/jaspr${config!.mode == JasprMode.server ? '/web' : ''}'
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
