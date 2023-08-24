// ignore_for_file: depend_on_referenced_packages, implementation_imports

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:build_daemon/data/build_status.dart';
import 'package:build_daemon/data/build_target.dart';
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'package:mason/mason.dart' show ExitCode;
import 'package:webdev/src/daemon_client.dart' as d;

import '../helpers/flutter_helpers.dart';
import '../helpers/ssr_helper.dart';
import '../logging.dart';
import 'base_command.dart';

class GenerateCommand extends BaseCommand with SsrHelper, FlutterHelper {
  GenerateCommand({super.logger}) {
    argParser.addOption(
      'input',
      abbr: 'i',
      help: 'Specify the input file for the web app',
      defaultsTo: 'lib/main.dart',
    );
  }

  @override
  String get description => 'Builds the project and generates static pages for each defined route.';

  @override
  String get name => 'generate';

  @override
  Future<int> run() async {
    await super.run();

    assert(
        useSSR,
        'Static site generation requires the "uses-ssr" flag set to true. '
        'If you want to build a purely client-rendered application use "jaspr build" instead.');

    var dir = Directory('build/jaspr');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    String? entryPoint = await getEntryPoint(argResults!['input']);

    if (entryPoint == null) {
      logger.write("Cannot find entry point. Create a main.dart in lib/ or web/, or specify a file using --input.",
          level: Level.critical);
      await shutdown(1);
    }

    var indexHtml = File('web/index.html');
    var targetIndexHtml = File('build/jaspr/index.html');

    var dummyIndex = false;
    if (usesFlutter && !await indexHtml.exists()) {
      dummyIndex = true;
      await indexHtml.create();
    }

    var webResult = _buildWeb(true, useSSR);
    var flutterResult = Future<void>.value();

    await webResult;

    if (usesFlutter) {
      flutterResult = buildFlutter(useSSR);
    }

    logger.write('Building server app...', progress: ProgressState.running);

    var process = await Process.start(
      'dart',
      [
        'run',
        '--enable-asserts',
        '-Djaspr.flags.release=true',
        '-Djaspr.flags.generate=true',
        '-Djaspr.dev.project=build/jaspr',
        entryPoint,
      ],
      environment: {'PORT': '8080', 'JASPR_PROXY_PORT': '5467'},
    );

    Set<String> generatedRoutes = {};
    List<String> queuedRoutes = [];

    var serverStartedCompleter = Completer();

    void queryTargetRoute(String route) {
      if (!serverStartedCompleter.isCompleted) {
        serverStartedCompleter.complete();
      }
      if (generatedRoutes.contains(route)) {
        return;
      }
      queuedRoutes.insert(0, route);
      generatedRoutes.add(route);
    }

    guardResource(() async => process.kill());
    watchProcess(process, tag: Tag.server, progress: 'Running server app...', hide: (s) {
      if (s.startsWith('[DAEMON] ')) {
        var message = jsonDecode(s.substring(9));
        if (message case {'route': String route}) {
          queryTargetRoute(route);
        }
        return true;
      }
      return false;
    });

    await serverStartedCompleter.future;

    logger.complete(true);

    logger.write('Generating routes...', progress: ProgressState.running);

    while (queuedRoutes.isNotEmpty) {
      var route = queuedRoutes.removeLast();

      logger.write('Generating route "$route"...', progress: ProgressState.running);

      var response = await http.get(Uri.parse('http://0.0.0.0:8080$route'));

      var filename = route.endsWith('/') ? '${route}index.html' : '$route.html';

      var file = File('build/jaspr$filename');

      await file.create(recursive: true);
      await file.writeAsBytes(response.bodyBytes);
    }

    logger.complete(true);
    process.kill();

    await flutterResult;

    if (dummyIndex) {
      await indexHtml.delete();
      if (!(generatedRoutes.contains('/') || generatedRoutes.contains('/index')) && await targetIndexHtml.exists()) {
        await targetIndexHtml.delete();
      }
    }

    logger.write('Completed building project to /build/jaspr.', progress: ProgressState.completed);
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
      ..output = 'build/jaspr'
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
