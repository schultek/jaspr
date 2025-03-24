// ignore_for_file: depend_on_referenced_packages, implementation_imports

import 'dart:async';
import 'dart:io';

import 'package:build_daemon/data/build_status.dart';
import 'package:build_daemon/data/build_target.dart';
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:webdev/src/daemon_client.dart' as d;

import '../config.dart';
import '../helpers/dart_define_helpers.dart';
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
        'exe': 'Compile to a self-contained executable.',
        'aot-snapshot': 'Compile to an AOT snapshot.',
        'kernel': 'Compile to a portable kernel module.',
      },
      defaultsTo: 'exe',
    );
    argParser.addFlag(
      'experimental-wasm',
      help: 'Compile to wasm',
      negatable: false,
    );
    argParser.addMultiOption(
      'extra-js-compiler-option',
      help: 'Extra flags to pass to `dart compile js`.',
      defaultsTo: [],
      hide: true,
    );
    argParser.addMultiOption(
      'extra-wasm-compiler-option',
      help: 'Extra flags to pass to `dart compile wasm`.',
      defaultsTo: [],
      hide: true,
    );
    argParser.addOption(
      'optimize',
      abbr: 'O',
      help: 'Set the dart2js / dart2wasm compiler optimization level',
      allowed: ['0', '1', '2', '3', '4'],
      allowedHelp: {
        '0': 'No optimizations (only meant for debugging the compiler).',
        '1': 'Includes whole program analyses and inlining.',
        '2': 'Safe production-oriented optimizations (like minification).',
        '3': 'Potentially unsafe optimizations.',
        '4': 'More aggressive unsafe optimizations.',
      },
      defaultsTo: '2',
    );
    addDartDefineArgs();
  }

  @override
  String get description => 'Build the full project.';

  @override
  String get name => 'build';

  @override
  String get category => 'Project';

  late final useWasm = argResults!['experimental-wasm'] as bool;

  @override
  Future<CommandResult?> run() async {
    await super.run();

    logger.write("Building jaspr for ${config!.mode.name} rendering mode.");

    var dir = Directory('build/jaspr').absolute;
    var webDir = config!.mode == JasprMode.server ? Directory('build/jaspr/web').absolute : dir;

    String? entryPoint;
    if (config!.mode != JasprMode.client) {
      entryPoint = await getEntryPoint(argResults!['input']);
    }

    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
    webDir.createSync(recursive: true);

    var indexHtml = File('web/index.html').absolute;
    var targetIndexHtml = File('${webDir.path}/index.html').absolute;

    var dummyIndex = false;
    var dummyTargetIndex = false;
    if (config!.usesFlutter && !indexHtml.existsSync()) {
      dummyIndex = true;
      dummyTargetIndex = true;
      indexHtml
        ..createSync()
        ..writeAsStringSync(
            'This file (web/index.html) should not exist. If you see this message something went wrong during "jaspr build". Simply delete the file.');
      guardResource(() {
        if (indexHtml.existsSync()) indexHtml.deleteSync();
      });
    }

    var webResult = _buildWeb();
    var flutterResult = Future<void>.value();

    await webResult;

    if (config!.usesFlutter) {
      flutterResult = buildFlutter(useWasm);
    }

    var serverDefines = getServerDartDefines();

    if (config!.mode == JasprMode.server) {
      logger.write('Building server app...', progress: ProgressState.running);

      final target = argResults!['target'];
      String extension = switch (target) {
        'exe' when Platform.isWindows => '.exe',
        'aot-snapshot' => '.aot',
        'kernel' => '.dill',
        _ => '',
      };

      var process = await Process.start(
        'dart',
        [
          'compile',
          argResults!['target'],
          entryPoint!,
          '-o',
          './build/jaspr/app$extension',
          '-Djaspr.flags.release=true',
          for (var define in serverDefines.entries) '-D${define.key}=${define.value}',
        ],
        workingDirectory: Directory.current.path,
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

      var serverPid = File('.dart_tool/jaspr/server.pid').absolute;
      if (!serverPid.existsSync()) {
        serverPid.createSync(recursive: true);
      }
      serverPid.writeAsStringSync('');

      var process = await Process.start(
        Platform.executable,
        [
          'run',
          '--enable-asserts',
          '-Djaspr.flags.release=true',
          '-Djaspr.flags.generate=true',
          '-Djaspr.dev.web=build/jaspr',
          for (var define in serverDefines.entries) '-D${define.key}=${define.value}',
          entryPoint!,
        ],
        environment: {'PORT': '8080', 'JASPR_PROXY_PORT': '5567'},
        workingDirectory: Directory.current.path,
      );

      bool done = false;
      watchProcess('server', process, tag: Tag.server, progress: 'Running server app...', onFail: () => !done);

      await serverStartedCompleter.future;

      logger.complete(true);

      logger.write('Generating routes...', progress: ProgressState.running);

      while (queuedRoutes.isNotEmpty) {
        var route = queuedRoutes.removeLast();

        logger.write('Generating route "$route"...', progress: ProgressState.running);

        var response = await http.get(Uri.parse('http://localhost:8080$route'));

        var file = File(p.url.join(
          'build/jaspr',
          route.startsWith('/') ? route.substring(1) : route,
          p.url.extension(route).isEmpty ? 'index.html' : null,
        )).absolute;

        file.createSync(recursive: true);
        file.writeAsBytesSync(response.bodyBytes);
      }

      done = true;
      process.kill();

      logger.complete(true);

      dummyTargetIndex &= !(generatedRoutes.contains('/') || generatedRoutes.contains('/index'));
    }

    await flutterResult;

    if (dummyIndex) {
      if (indexHtml.existsSync()) indexHtml.deleteSync();
      if (dummyTargetIndex && targetIndexHtml.existsSync()) {
        targetIndexHtml.deleteSync();
      }
    }

    logger.write('Completed building project to /build/jaspr.', progress: ProgressState.completed);
    return null;
  }

  Future<int> _buildWeb() async {
    if (useWasm) {
      checkWasmSupport();
    }

    logger.write('Building web assets...', progress: ProgressState.running);

    final compiler = useWasm ? 'dart2wasm' : 'dart2js';
    final entrypointBuilder = '${config!.usesJasprWebCompilers ? 'jaspr' : 'build'}_web_compilers:entrypoint';

    var dartDefines = getClientDartDefines();
    if (config!.usesFlutter) {
      dartDefines.addAll(getFlutterDartDefines(useWasm, true));
    }

    final args = [
      '-Djaspr.flags.release=true',
      '-O${argResults!['optimize']}',
      if (useWasm) //
        ...argResults!['extra-wasm-compiler-option']
      else
        ...argResults!['extra-js-compiler-option'],
      for (final entry in dartDefines.entries) //
        '-D${entry.key}=${entry.value}',
    ];

    final client = await d.connectClient(
      Directory.current.path,
      [
        '--release',
        '--verbose',
        '--delete-conflicting-outputs',
        '--define=$entrypointBuilder=compiler=$compiler',
        '--define=$entrypointBuilder=${compiler}_args=[${args.map((a) => '"$a"').join(',')}]',
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
