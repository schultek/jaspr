// ignore_for_file: depend_on_referenced_packages, implementation_imports

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:build_daemon/data/build_status.dart';
import 'package:build_daemon/data/build_target.dart';
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http show Client, Response;
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
      help:
          'Specify the entry file for the server app. Must end in ".server.dart".\nDefaults to the first found "*.server.dart" file in the project.',
    );
    argParser.addOption(
      'target',
      abbr: 't',
      help: 'Specify the compilation target for the executable (only in server mode)',
      allowed: ['exe', 'aot-snapshot', 'jit-snapshot'],
      allowedHelp: {
        'exe': 'Compile to a self-contained executable.',
        'aot-snapshot': 'Compile to an AOT snapshot.',
        'kernel': 'Compile to a portable kernel module.',
      },
      defaultsTo: 'exe',
    );
    argParser.addFlag('experimental-wasm', help: 'Compile to wasm', negatable: false);
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
    argParser.addFlag(
      'include-source-maps',
      help: 'Include source maps (and dart source files) in the output.',
      negatable: false,
      defaultsTo: false,
    );
    argParser.addOption(
      'sitemap-domain',
      help:
          'If set, generates a sitemap.xml file for the static site.\n'
          'The domain will be used as the base URL for the sitemap entries.',
    );
    argParser.addOption(
      'sitemap-exclude',
      help: 'A regex pattern of routes that should be excluded from the sitemap. ',
    );
    argParser.addFlag(
      'managed-build-options',
      help:
          'Whether jaspr will launch `build_runner` with options derived from command line arguments (the default).\n'
          'When disabled, builders compiling to the web need to be configured manually.',
      negatable: true,
      defaultsTo: true,
    );

    argParser.addFlag(
      'use-flutter-sdk',
      help:
          'Use the installed Flutter SDK to compile the app. This enables support for using '
          'Flutter web plugins and Flutter embedding.\n'
          'This is automatically enabled when depending on flutter in pubspec.yaml.',
      negatable: false,
      defaultsTo: false,
    );
    addDartDefineArgs();
  }

  @override
  String get description => 'Build the full project.';

  @override
  String get name => 'build';

  @override
  String get category => 'Project';

  late final input = argResults!.option('input');
  late final useWasm = argResults!.flag('experimental-wasm');
  late final includeSourceMaps = argResults!.flag('include-source-maps');
  late final sitemapDomain = argResults!.option('sitemap-domain');
  late final sitemapExclude = argResults!.option('sitemap-exclude');
  late final managedBuildOptions = argResults!.flag('managed-build-options');
  late final useFlutterSdk = argResults!.flag('use-flutter-sdk');

  @override
  Future<int> runCommand() async {
    ensureInProject();

    logger.write("Building jaspr for ${project.requireMode.name} rendering mode.");

    var dir = Directory('build/jaspr').absolute;
    var webDir = project.requireMode == JasprMode.server ? Directory('build/jaspr/web').absolute : dir;

    final entryPoint = await getServerEntryPoint(input);

    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
    webDir.createSync(recursive: true);

    var indexHtml = File('web/index.html').absolute;
    var targetIndexHtml = File('${webDir.path}/index.html').absolute;

    var dummyIndex = false;
    var dummyTargetIndex = false;
    if (project.usesFlutter && !indexHtml.existsSync()) {
      dummyIndex = true;
      dummyTargetIndex = true;
      indexHtml
        ..createSync()
        ..writeAsStringSync(
          'This file (web/index.html) should not exist. If you see this message something went wrong during "jaspr build". Simply delete the file.',
        );
      guardResource(() {
        if (indexHtml.existsSync()) indexHtml.deleteSync();
      });
    }

    var webResult = _buildWeb();
    var flutterResult = Future<void>.value();

    await webResult;

    if (project.usesFlutter) {
      flutterResult = buildFlutter(useWasm);
    }

    bool hasBuildError = false;

    var serverDefines = getServerDartDefines();

    if (project.requireMode == JasprMode.server) {
      logger.write('Building server app...', progress: ProgressState.running);

      final compileTarget = argResults!.option('target')!;
      final extension = switch (compileTarget) {
        'exe' when Platform.isWindows => '.exe',
        'aot-snapshot' => '.aot',
        'kernel' => '.dill',
        _ => '',
      };

      var process = await Process.start('dart', [
        'compile',
        compileTarget,
        entryPoint!,
        '-o',
        './build/jaspr/app$extension',
        '-Djaspr.flags.release=true',
        for (var define in serverDefines.entries) '-D${define.key}=${define.value}',
      ], workingDirectory: Directory.current.path);

      await watchProcess('server build', process, tag: Tag.cli, progress: 'Building server app...');
    } else if (project.requireMode == JasprMode.static) {
      logger.write('Generating static site...', progress: ProgressState.running);

      Map<String, ({String? lastmod, String? changefreq, double? priority})?> generatedRoutes = {};
      List<String> queuedRoutes = [];

      var serverStartedCompleter = Completer<void>();
      final serverPort = project.port ?? '8080';

      await startProxy(
        '5567',
        webPort: '0',
        serverPort: serverPort,
        onMessage: (message) {
          if (message case {'route': String route}) {
            if (!serverStartedCompleter.isCompleted) {
              serverStartedCompleter.complete();
            }
            if (!generatedRoutes.containsKey(route)) {
              queuedRoutes.insert(0, route);
            }

            final lastmod = message['lastmod'] is String ? message['lastmod'] as String : null;
            final changefreq = message['changefreq'] is String ? message['changefreq'] as String : null;
            final priority = message['priority'] is num ? (message['priority'] as num).toDouble() : null;

            generatedRoutes[route] = (lastmod: lastmod, changefreq: changefreq, priority: priority);
          }
        },
      );

      var serverPid = File('.dart_tool/jaspr/server.pid').absolute;
      if (!serverPid.existsSync()) {
        serverPid.createSync(recursive: true);
      }
      serverPid.writeAsStringSync('');

      var process = await Process.start(
        Platform.executable,
        [
          // Use direct `dart` entry point for now due to
          // https://github.com/dart-lang/sdk/issues/61373.
          // 'run',
          '--enable-asserts',
          '-Djaspr.flags.release=true',
          '-Djaspr.flags.generate=true',
          '-Djaspr.dev.web=build/jaspr',
          for (var define in serverDefines.entries) '-D${define.key}=${define.value}',
          entryPoint!,
        ],
        environment: {'PORT': serverPort, 'JASPR_PROXY_PORT': '5567'},
        workingDirectory: Directory.current.path,
      );

      bool done = false;
      watchProcess(
        'server',
        process,
        tag: Tag.server,
        progress: 'Running server app...',
        onFail: () {
          logger.write('Server process failed unexpectedly.', level: Level.error, progress: ProgressState.completed);
          return !done;
        },
      );

      await serverStartedCompleter.future;

      logger.complete(true);

      logger.write('Generating routes...', progress: ProgressState.running);

      final httpClient = http.Client();

      while (queuedRoutes.isNotEmpty) {
        var route = queuedRoutes.removeLast();

        logger.write(
          'Generating route "$route" (${generatedRoutes.length - queuedRoutes.length}/${generatedRoutes.length})...',
          progress: ProgressState.running,
        );

        http.Response response;
        try {
          response = await httpClient.get(Uri.parse('http://localhost:$serverPort$route'));
        } catch (e) {
          logger.write(
            'Failed to generate route "$route". ($e)',
            level: Level.error,
            progress: ProgressState.completed,
          );
          hasBuildError = true;
          continue;
        }

        if (response.statusCode != 200) {
          logger.write(
            'Failed to generate route "$route". (Received status code ${response.statusCode})',
            level: Level.error,
            progress: ProgressState.completed,
          );
          hasBuildError = true;
          continue;
        }

        var file = File(
          p.url.join(
            'build/jaspr',
            route.startsWith('/') ? route.substring(1) : route,
            p.url.extension(route).isEmpty ? 'index.html' : null,
          ),
        ).absolute;

        file.createSync(recursive: true);
        file.writeAsBytesSync(response.bodyBytes);

        if (response.headers['jaspr-sitemap-data'] case String data) {
          if (data == 'false') {
            generatedRoutes[route] = null;
          } else {
            final sitemap = jsonDecode(data) as Object?;

            if (sitemap is! Map<String, Object?>) {
              logger.write(
                'Invalid sitemap data for route "$route". Expected a map, but got ${sitemap.runtimeType}.',
                level: Level.error,
                progress: ProgressState.completed,
              );
              hasBuildError = true;
              continue;
            }

            final originalRouteConfig = generatedRoutes[route];
            final lastModConfig = sitemap['lastmod'];
            final changeFrequencyConfig = sitemap['changefreq'];
            final priorityConfig = sitemap['priority'];

            generatedRoutes[route] = (
              lastmod: lastModConfig is String ? lastModConfig : originalRouteConfig?.lastmod,
              changefreq: changeFrequencyConfig is String ? changeFrequencyConfig : originalRouteConfig?.changefreq,
              priority: priorityConfig is num ? priorityConfig.toDouble() : originalRouteConfig?.priority,
            );
          }
        }
      }

      done = true;
      httpClient.close();
      process.kill();

      logger.complete(!hasBuildError);

      if (sitemapDomain != null) {
        logger.write('Generating sitemap.xml...');

        var content = StringBuffer();
        content.writeln('<?xml version="1.0" encoding="UTF-8"?>');
        content.writeln('<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">');

        var domain = sitemapDomain!;
        if (!domain.startsWith(RegExp('https?://'))) {
          domain = 'https://$domain';
        }

        var excludePattern = sitemapExclude != null ? RegExp(sitemapExclude!) : null;
        var now = DateTime.now().copyWith(millisecond: 0, microsecond: 0).toIso8601String();

        for (var route in generatedRoutes.entries) {
          if (excludePattern != null && excludePattern.hasMatch(route.key)) {
            continue;
          }

          final sitemapData = route.value;
          if (sitemapData == null) {
            continue;
          }

          content.writeln('  <url>');
          content.writeln('    <loc>$domain${route.key}</loc>');
          content.writeln('    <lastmod>${sitemapData.lastmod ?? now}</lastmod>');
          if (sitemapData.changefreq != null) {
            content.writeln('    <changefreq>${sitemapData.changefreq}</changefreq>');
          }
          content.writeln('    <priority>${sitemapData.priority ?? 0.5}</priority>');
          content.writeln('  </url>');
        }
        content.writeln('</urlset>');

        var sitemap = File(p.url.join('build/jaspr', 'sitemap.xml')).absolute;
        sitemap.createSync(recursive: true);
        sitemap.writeAsStringSync(content.toString());
      }

      dummyTargetIndex &= !(generatedRoutes.containsKey('/') || generatedRoutes.containsKey('/index'));
    }

    await flutterResult;

    if (dummyIndex) {
      if (indexHtml.existsSync()) indexHtml.deleteSync();
      if (dummyTargetIndex && targetIndexHtml.existsSync()) {
        targetIndexHtml.deleteSync();
      }
    }

    if (hasBuildError) {
      logger.write('Failed to build project.', progress: ProgressState.completed, level: Level.error);
      return 1;
    }

    logger.write('Completed building project to /build/jaspr.', progress: ProgressState.completed);
    return 0;
  }

  Future<int> _buildWeb() async {
    if (useWasm) {
      project.checkWasmSupport();
    }

    logger.write('Building web assets...', progress: ProgressState.running);

    final compiler = useWasm ? 'dart2wasm' : 'dart2js';

    var dartDefines = getClientDartDefines();
    if (project.usesFlutter) {
      dartDefines.addAll(getFlutterDartDefines(useWasm, true));
    }

    final args = [
      '-Djaspr.flags.release=true',
      '-O${argResults!.option('optimize')}',
      if (useWasm) //
        ...argResults!.multiOption('extra-wasm-compiler-option')
      else
        ...argResults!.multiOption('extra-js-compiler-option'),
      if (useWasm && (useFlutterSdk || project.usesFlutter))
        '--extra-compiler-option=--platform=${p.join(webSdkDir, 'kernel', 'dart2wasm_platform.dill')}',

      for (final entry in dartDefines.entries) //
        '-D${entry.key}=${entry.value}',
    ];

    List<String> additionalFlutterBuildArgs() {
      final librariesPath = p.join(webSdkDir, 'libraries.json');
      final sdkJsPath = p.join(
        webSdkDir,
        'kernel',
        flutterVersion.compareTo('3.32.0') >= 0 ? 'amd-canvaskit' : 'amd-canvaskit-sound',
      );
      return [
        '--define=build_web_compilers:entrypoint=use-ui-libraries=true',
        '--define=build_web_compilers:entrypoint_marker=use-ui-libraries=true',
        '--define=build_web_compilers:ddc=use-ui-libraries=true',
        '--define=build_web_compilers:ddc_modules=use-ui-libraries=true',
        '--define=build_web_compilers:dart2js_modules=use-ui-libraries=true',
        '--define=build_web_compilers:dart2wasm_modules=use-ui-libraries=true',
        '--define=build_web_compilers:entrypoint=libraries_path="$librariesPath"',
        '--define=build_web_compilers:entrypoint=silence_unsupported_modules_warnings=true',
        '--define=build_web_compilers:sdk_js=use-prebuilt-sdk-from-path="$sdkJsPath"',
      ];
    }

    final client = await d.connectClient(Directory.current.path, [
      '--release',
      '--verbose',
      '--delete-conflicting-outputs',
      if (managedBuildOptions) ...[
        '--define=build_web_compilers:entrypoint=compiler=$compiler',
        '--define=build_web_compilers:entrypoint=${compiler}_args=[${args.map((a) => '"$a"').join(',')}]',
        if (useFlutterSdk || project.usesFlutter) ...additionalFlutterBuildArgs(),
        if (includeSourceMaps) ...[
          '--define=build_web_compilers:dart2js_archive_extractor=filter_outputs=false',
          '--define=build_web_compilers:dart_source_cleanup=enabled=false',
        ],
      ],
    ], logger.writeServerLog);
    OutputLocation outputLocation = OutputLocation(
      (b) => b
        ..output = 'build/jaspr${project.requireMode == JasprMode.server ? '/web' : ''}'
        ..useSymlinks = false
        ..hoist = true,
    );

    client.registerBuildTarget(
      DefaultBuildTarget(
        (b) => b
          ..target = 'web'
          ..outputLocation = outputLocation.toBuilder(),
      ),
    );

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

      if (includeSourceMaps) {
        _fixSourceMaps(outputLocation.output);
      }
    }
    return exitCode;
  }

  void _fixSourceMaps(String root) {
    final files = Directory(root).listSync(recursive: true);

    for (final file in files) {
      if (file is File && RegExp(r'\.dart\.js.*\.(map|deps)$').hasMatch(file.path)) {
        file.writeAsStringSync(file.readAsStringSync().replaceAll('org-dartlang-app://', ''));
      }
    }
  }
}
