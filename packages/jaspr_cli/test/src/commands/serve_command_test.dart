import 'dart:convert';
import 'dart:io';

import 'package:build_daemon/data/build_status.dart';
import 'package:jaspr_cli/src/command_runner.dart';
import 'package:jaspr_cli/src/project.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../fakes/fake_build_daemon.dart';
import '../fakes/fake_io.dart';
import '../fakes/fake_project.dart';
import '../fakes/fake_server.dart';
import '../fakes/fake_socket.dart';

void main() {
  group('serve command', () {
    late JasprCommandRunner runner;
    late FakeIO io;

    setUp(() {
      io = FakeIO();
      runner = JasprCommandRunner(false, false);
    });

    tearDown(() {
      io.tearDown();
    });

    test('serves project with client mode', () async {
      await io.runZoned(() async {
        io.setupFakeProject('myapp', mode: 'client');
        io.stubDartSDK();

        final buildDaemon = io.setupFakeBuildDaemon(verifyArgs: buildRunnerDartArgs);

        final serveResult = runner.run(['serve', '--verbose']);

        await expectLater(
          io.stdout.queue,
          emitsInOrderWithTimeout([
            'Starting myapp in client rendering mode.',
            '[BUILDER] Starting web compilers...',
            '[BUILDER] Connecting to the build daemon...',
            '[BUILDER] Starting initial build...',
          ]),
        );

        await io.runInitialBuild(buildDaemon);

        await expectLater(
          io.serverSockets.next,
          completion(isA<FakeServerSocket>().having((s) => s.port, 'port', 8080)),
        );

        await expectLater(
          io.stdout.queue,
          emitsInOrderWithTimeout([
            '[BUILDER] Done building web assets.',
            '[LOG] Serving at http://localhost:8080',
          ]),
        );

        await io.shutdownBuildDaemon(buildDaemon);

        expect(
          io.stdout.queue,
          emitsInOrderWithTimeout([
            'Stopping web compilers...',
          ]),
        );

        expect(await serveResult, equals(0));
      });
    });

    test('handles keyboard shortcuts (r, R, d, l)', () async {
      await io.runZoned(() async {
        io.stdin.hasTerminalOverride = true;
        io.setupFakeProject('myapp', mode: 'client');
        io.stubDartSDK();

        final buildDaemon = io.setupFakeBuildDaemon(verifyArgs: buildRunnerDartArgs);

        final serveResult = runner.run(['serve', '--verbose']);

        await expectLater(
          io.stdout.queue,
          emitsInOrderWithTimeout([
            'Starting myapp in client rendering mode.',
            '[BUILDER] Starting web compilers...',
            '[BUILDER] Connecting to the build daemon...',
            '[BUILDER] Starting initial build...',
          ]),
        );

        await io.runInitialBuild(buildDaemon);

        await expectLater(
          io.serverSockets.next,
          completion(isA<FakeServerSocket>().having((s) => s.port, 'port', 8080)),
        );

        await expectLater(
          io.stdout.queue,
          emitsInOrderWithTimeout([
            '[BUILDER] Done building web assets.',
            '[LOG] Serving at http://localhost:8080',
          ]),
        );

        // Press 'r' for reload
        io.stdin.addBytes([utf8.encode('r').first]);
        await expectLater(
          io.stdout.queue,
          emitsInOrderWithTimeout([
            '[CLIENT] Reloading...',
            '[CLIENT] Reload complete.',
          ]),
        );

        // Press 'R' for restart
        io.stdin.addBytes([utf8.encode('R').first]);
        await expectLater(
          io.stdout.queue,
          emitsInOrderWithTimeout([
            '[CLIENT] Restarting...',
            '[CLIENT] Restart complete.',
          ]),
        );

        // Press 'd' for devtools
        io.stdin.addBytes([utf8.encode('d').first]);
        await expectLater(
          io.stdout.queue,
          emits('[LOG] DevTools not available yet.'),
        );

        // Press 'l' for launch chrome
        io.stdin.addBytes([utf8.encode('l').first]);
        await expectLater(
          io.stdout.queue,
          emits('[LOG] Launching Chrome...'),
        );

        // Press 'q' for quit
        io.stdin.addBytes([utf8.encode('q').first]);

        expect(
          io.stdout.queue,
          emitsInOrderWithTimeout([
            'Stopping web compilers...',
          ]),
        );

        expect(await serveResult, equals(0));
      });
    });

    test('queues reload and restart shortcuts when build is in progress', () async {
      await io.runZoned(() async {
        io.stdin.hasTerminalOverride = true;
        io.setupFakeProject('myapp', mode: 'client');
        io.stubDartSDK();

        final buildDaemon = io.setupFakeBuildDaemon(verifyArgs: buildRunnerDartArgs);

        final serveResult = runner.run(['serve', '--verbose']);

        await expectLater(
          io.stdout.queue,
          emitsInOrderWithTimeout([
            'Starting myapp in client rendering mode.',
            '[BUILDER] Starting web compilers...',
            '[BUILDER] Connecting to the build daemon...',
            '[BUILDER] Starting initial build...',
          ]),
        );

        await io.runInitialBuild(buildDaemon);

        await expectLater(
          io.serverSockets.next,
          completion(isA<FakeServerSocket>().having((s) => s.port, 'port', 8080)),
        );

        await expectLater(
          io.stdout.queue,
          emitsInOrderWithTimeout([
            '[BUILDER] Done building web assets.',
            '[LOG] Serving at http://localhost:8080',
          ]),
        );

        // 1. Start a rebuild, queue reload ('r'), and complete build
        buildDaemon.sendMessage(
          BuildResults((b) {
            b.results.add(
              DefaultBuildResult((b) {
                b.target = 'web';
                b.status = BuildStatus.started;
              }),
            );
          }),
        );

        await expectLater(
          io.stdout.queue,
          emits('[BUILDER] Rebuilding web assets...'),
        );

        // Press 'r' for reload while building
        io.stdin.addBytes([utf8.encode('r').first]);
        await expectLater(
          io.stdout.queue,
          emits('[CLIENT] Build in progress. Queued reload...'),
        );

        // Pressing 'r' again informs that reload is already queued
        io.stdin.addBytes([utf8.encode('r').first]);
        await expectLater(
          io.stdout.queue,
          emits('[CLIENT] Build in progress. Reload already queued.'),
        );

        // Build finishes successfully -> executes queued reload
        buildDaemon.sendMessage(
          BuildResults((b) {
            b.results.add(
              DefaultBuildResult((b) {
                b.target = 'web';
                b.status = BuildStatus.succeeded;
              }),
            );
          }),
        );

        await expectLater(
          io.stdout.queue,
          emitsInOrderWithTimeout([
            '[BUILDER] Rebuilt web assets.',
            '[CLIENT] Reloading...',
            '[CLIENT] Reload complete.',
          ]),
        );

        // 2. Start another rebuild, queue reload then upgrade to restart ('R')
        buildDaemon.sendMessage(
          BuildResults((b) {
            b.results.add(
              DefaultBuildResult((b) {
                b.target = 'web';
                b.status = BuildStatus.started;
              }),
            );
          }),
        );

        await expectLater(
          io.stdout.queue,
          emits('[BUILDER] Rebuilding web assets...'),
        );

        // Press 'r' while building
        io.stdin.addBytes([utf8.encode('r').first]);
        await expectLater(
          io.stdout.queue,
          emits('[CLIENT] Build in progress. Queued reload...'),
        );

        // Press 'R' to upgrade to restart
        io.stdin.addBytes([utf8.encode('R').first]);
        await expectLater(
          io.stdout.queue,
          emits('[CLIENT] Build in progress. Queued restart...'),
        );

        // Press 'r' while restart is queued
        io.stdin.addBytes([utf8.encode('r').first]);
        await expectLater(
          io.stdout.queue,
          emits('[CLIENT] Build in progress. Restart already queued.'),
        );

        // Build finishes successfully -> executes queued restart
        buildDaemon.sendMessage(
          BuildResults((b) {
            b.results.add(
              DefaultBuildResult((b) {
                b.target = 'web';
                b.status = BuildStatus.succeeded;
              }),
            );
          }),
        );

        await expectLater(
          io.stdout.queue,
          emitsInOrderWithTimeout([
            '[BUILDER] Rebuilt web assets.',
            '[CLIENT] Restarting...',
            '[CLIENT] Restart complete.',
          ]),
        );

        // 3. Start a rebuild, queue reload, but build fails
        buildDaemon.sendMessage(
          BuildResults((b) {
            b.results.add(
              DefaultBuildResult((b) {
                b.target = 'web';
                b.status = BuildStatus.started;
              }),
            );
          }),
        );

        await expectLater(
          io.stdout.queue,
          emits('[BUILDER] Rebuilding web assets...'),
        );

        io.stdin.addBytes([utf8.encode('r').first]);
        await expectLater(
          io.stdout.queue,
          emits('[CLIENT] Build in progress. Queued reload...'),
        );

        // Build fails
        buildDaemon.sendMessage(
          BuildResults((b) {
            b.results.add(
              DefaultBuildResult((b) {
                b.target = 'web';
                b.status = BuildStatus.failed;
              }),
            );
          }),
        );

        await expectLater(
          io.stderr.queue,
          emits('[BUILDER] [ERROR] Failed building web assets. There is probably more output above.'),
        );
        await expectLater(
          io.stdout.queue,
          emits('[CLIENT] Build failed. Skipped queued reload.'),
        );

        // Quit
        io.stdin.addBytes([utf8.encode('q').first]);

        expect(
          io.stdout.queue,
          emitsInOrderWithTimeout([
            'Stopping web compilers...',
          ]),
        );

        expect(await serveResult, equals(0));
      });
    });

    test('disables reload shortcut and warns when hot reload is not supported', () async {
      await io.runZoned(() async {
        io.stdin.hasTerminalOverride = true;
        io.setupFakeProject('myapp', mode: 'client');
        io.stubDartSDK();

        final buildDaemon = io.setupFakeBuildDaemon();

        final serveResult = runner.run(['serve', '--verbose', '--module-format=amd', '--mode=reload']);

        await expectLater(
          io.stdout.queue,
          emitsInOrderWithTimeout([
            'Starting myapp in client rendering mode.',
            '[LOG] [WARNING] The AMD module format does not support hot reload.',
            '[BUILDER] Starting web compilers...',
            '[LOG] [WARNING] Falling back to hot restart instead of hot reload.',
            '[BUILDER] Connecting to the build daemon...',
            '[BUILDER] Starting initial build...',
          ]),
        );

        await io.runInitialBuild(buildDaemon);

        await expectLater(
          io.serverSockets.next,
          completion(isA<FakeServerSocket>().having((s) => s.port, 'port', 8080)),
        );

        await expectLater(
          io.stdout.queue,
          emitsInOrderWithTimeout([
            '[BUILDER] Done building web assets.',
            '[LOG] Serving at http://localhost:8080',
          ]),
        );

        // Press 'r' for reload - should be ignored
        io.stdin.addBytes([utf8.encode('r').first]);

        // Press 'R' for restart - should work
        io.stdin.addBytes([utf8.encode('R').first]);
        await expectLater(
          io.stdout.queue,
          emitsInOrderWithTimeout([
            '[CLIENT] Restarting...',
            '[CLIENT] Restart complete.',
          ]),
        );

        // Press 'q' for quit
        io.stdin.addBytes([utf8.encode('q').first]);

        expect(
          io.stdout.queue,
          emitsInOrderWithTimeout([
            'Stopping web compilers...',
          ]),
        );

        expect(await serveResult, equals(0));
      });
    });

    test('serves project with server mode', () async {
      await io.runZoned(() async {
        io.setupFakeProject('myapp', mode: 'server');
        io.stubDartSDK();

        final buildDaemon = io.setupFakeBuildDaemon(verifyArgs: buildRunnerDartArgs);
        final server = io.stubFakeServer();

        final serveResult = runner.run(['serve', '--verbose']);

        await expectLater(
          io.stdout.queue,
          emitsInOrderWithTimeout([
            'Starting myapp in server rendering mode.',
            '[BUILDER] Starting web compilers...',
            '[BUILDER] Connecting to the build daemon...',
            '[BUILDER] Starting initial build...',
          ]),
        );

        await io.runInitialBuild(buildDaemon);

        expect(io.stdout.queue, emits('[BUILDER] Done building web assets.'));

        await expectLater(
          io.serverSockets.next,
          completion(isA<FakeServerSocket>().having((s) => s.port, 'port', int.parse(serverProxyPort))),
        );

        await io.expectServerStarted(server);

        server.exit(0);

        expect(
          io.stdout.queue,
          emitsInOrderWithTimeout([
            'Stopping web compilers...',
          ]),
        );

        expect(await serveResult, equals(0));
      });
    });

    test('serves project with flutter embedding', () async {
      await io.runZoned(() async {
        io.setupFakeProject('myapp', mode: 'server', flutterEmbedding: true);
        io.stubDartSDK();
        io.stubFlutterSDK();

        final buildDaemon = io.setupFakeBuildDaemon(verifyArgs: buildRunnerFlutterArgs);
        final server = io.stubFakeServer();

        FakeProcess? flutterProcess;
        when(
          () => io.process.start(
            'flutter',
            [
              'run',
              '--device-id=web-server',
              '-t',
              '.dart_tool/jaspr/flutter_target.dart',
              '--web-port=$flutterProxyPort',
            ],
            workingDirectory: '/root/myapp',
            runInShell: true,
          ),
        ).thenAnswer((_) async => flutterProcess = FakeProcess());

        final serveResult = runner.run(['serve', '--verbose']);

        await expectLater(
          io.stdout.queue,
          emitsInOrderWithTimeout([
            'Starting myapp in server rendering mode.',
            '[BUILDER] Starting web compilers...',
            '[BUILDER] Connecting to the build daemon...',
            '[BUILDER] Starting initial build...',
          ]),
        );

        await io.runInitialBuild(buildDaemon);

        expect(io.stdout.queue, emits('[BUILDER] Done building web assets.'));

        await io.connectToProxy();

        expect(flutterProcess, isNotNull);

        await io.expectServerStarted(server);

        server.exit(0);

        expect(
          io.stdout.queue,
          emitsInOrderWithTimeout([
            'Stopping web compilers...',
            'Stopping flutter run...',
          ]),
        );

        expect(await serveResult, equals(0));
      });
    });

    test('serves project with automatic port fallback when default port is in use', () async {
      await io.runZoned(() async {
        io.setupFakeProject('myapp', mode: 'client');
        io.stubDartSDK();

        io.inUsePorts.add(8080);

        final buildDaemon = io.setupFakeBuildDaemon(verifyArgs: buildRunnerDartArgs);

        final serveResult = runner.run(['serve', '--verbose']);

        await expectLater(
          io.stdout.queue,
          emitsInOrderWithTimeout([
            'Starting myapp in client rendering mode.',
            '[BUILDER] Starting web compilers...',
            '[BUILDER] Connecting to the build daemon...',
            '[BUILDER] Starting initial build...',
          ]),
        );

        await io.runInitialBuild(buildDaemon);

        await expectLater(
          io.serverSockets.next,
          completion(isA<FakeServerSocket>().having((s) => s.port, 'port', 8081)),
        );

        await expectLater(
          io.stdout.queue,
          emitsInOrderWithTimeout([
            '[BUILDER] Done building web assets.',
            '[LOG] Serving at http://localhost:8081',
          ]),
        );

        await io.shutdownBuildDaemon(buildDaemon);

        expect(await serveResult, equals(0));
      });
    });

    test('serves project with automatic proxy port fallback in server mode', () async {
      await io.runZoned(() async {
        io.setupFakeProject('myapp', mode: 'server');
        io.stubDartSDK();

        io.inUsePorts.add(int.parse(serverProxyPort));

        final buildDaemon = io.setupFakeBuildDaemon(verifyArgs: buildRunnerDartArgs);
        final server = io.stubFakeServer(proxyPort: '5568');

        final serveResult = runner.run(['serve', '--verbose']);

        await expectLater(
          io.stdout.queue,
          emitsInOrderWithTimeout([
            'Starting myapp in server rendering mode.',
            '[BUILDER] Starting web compilers...',
            '[BUILDER] Connecting to the build daemon...',
            '[BUILDER] Starting initial build...',
          ]),
        );

        await io.runInitialBuild(buildDaemon);

        expect(io.stdout.queue, emits('[BUILDER] Done building web assets.'));

        await expectLater(
          io.serverSockets.next,
          completion(isA<FakeServerSocket>().having((s) => s.port, 'port', 5568)),
        );

        await io.expectServerStarted(server);

        server.exit(0);

        expect(await serveResult, equals(0));
      });
    });

    test('fails when explicit --port is in use', () async {
      await io.runZoned(() async {
        final stderr = io.stderr.queue;
        io.setupFakeProject('myapp', mode: 'client');
        io.stubDartSDK();

        io.inUsePorts.add(3000);

        final serveResult = runner.run(['serve', '--port', '3000']);

        await expectLater(
          stderr,
          emitsThrough('[LOG] [ERROR] Port 3000 is already in use.'),
        );

        expect(await serveResult, equals(1));
      });
    });

    test('fails when explicit --port is invalid or out of range', () async {
      await io.runZoned(() async {
        final stderr = io.stderr.queue;
        io.setupFakeProject('myapp', mode: 'client');
        io.stubDartSDK();

        final serveResult = runner.run(['serve', '--port', '0']);

        await expectLater(
          stderr,
          emitsThrough('[LOG] [ERROR] Invalid port "0". Must be a number between 1 and 65535.'),
        );

        expect(await serveResult, equals(1));
      });
    });
  });
}

const buildRunnerDartArgs = [
  '--verbose',
  '--define=build_web_compilers:ddc=generate-full-dill=true',
  '--define=build_web_compilers:entrypoint=compiler=dartdevc',
  '--define=build_web_compilers:ddc=ddc-library-bundle=true',
  '--define=build_web_compilers:sdk_js=ddc-library-bundle=true',
  '--define=build_web_compilers:entrypoint=ddc-library-bundle=true',
  '--define=build_web_compilers:entrypoint_marker=ddc-library-bundle=true',
  '--define=build_web_compilers:sdk_js=web-hot-reload=true',
  '--define=build_web_compilers:entrypoint=web-hot-reload=true',
  '--define=build_web_compilers:entrypoint_marker=web-hot-reload=true',
  '--define=build_web_compilers:ddc=web-hot-reload=true',
  '--define=build_web_compilers:ddc_modules=web-hot-reload=true',
  '--define=build_web_compilers:ddc=environment={"jaspr.flags.verbose":false}',
];

const buildRunnerFlutterArgs = [
  '--verbose',
  '--define=build_web_compilers:ddc=generate-full-dill=true',
  '--define=build_web_compilers:entrypoint=compiler=dartdevc',
  '--define=build_web_compilers:ddc=ddc-library-bundle=true',
  '--define=build_web_compilers:sdk_js=ddc-library-bundle=true',
  '--define=build_web_compilers:entrypoint=ddc-library-bundle=true',
  '--define=build_web_compilers:entrypoint_marker=ddc-library-bundle=true',
  '--define=build_web_compilers:sdk_js=web-hot-reload=true',
  '--define=build_web_compilers:entrypoint=web-hot-reload=true',
  '--define=build_web_compilers:entrypoint_marker=web-hot-reload=true',
  '--define=build_web_compilers:ddc=web-hot-reload=true',
  '--define=build_web_compilers:ddc_modules=web-hot-reload=true',
  '--define=build_web_compilers:ddc=environment={"jaspr.flags.verbose":false,"dart.vm.product":"false","FLUTTER_WEB_USE_SKWASM":"false","FLUTTER_WEB_USE_SKIA":"true"}',
  '--define=build_web_compilers:entrypoint=use-ui-libraries=true',
  '--define=build_web_compilers:entrypoint_marker=use-ui-libraries=true',
  '--define=build_web_compilers:ddc=use-ui-libraries=true',
  '--define=build_web_compilers:ddc_modules=use-ui-libraries=true',
  '--define=build_web_compilers:dart2js_modules=use-ui-libraries=true',
  '--define=build_web_compilers:dart2wasm_modules=use-ui-libraries=true',
  '--define=build_web_compilers:entrypoint=libraries-path="/fake/flutter/bin/cache/flutter_web_sdk/libraries.json"',
  '--define=build_web_compilers:entrypoint=unsafe-allow-unsupported-modules=true',
  '--define=build_web_compilers:sdk_js=use-prebuilt-sdk-from-path="/fake/flutter/bin/cache/flutter_web_sdk/kernel/ddcLibraryBundle-canvaskit"',
  '--define=build_web_compilers:ddc=ddc-kernel-path="kernel/ddc_outline.dill"',
  '--define=build_web_compilers:ddc=libraries-path="/fake/flutter/bin/cache/flutter_web_sdk/libraries.json"',
  '--define=build_web_compilers:ddc=platform-sdk="/fake/flutter/bin/cache/flutter_web_sdk"',
];

extension FakeServerIO on FakeIO {
  FakeProcess stubFakeServer({String port = '8080', String proxyPort = '5567'}) {
    final serverProcess = FakeProcess();

    when(
      () => process.start(
        '/fake/bin/dart',
        [
          'run',
          '--enable-vm-service',
          '--enable-asserts',
          '-Djaspr.flags.verbose=false',
          '/root/myapp/.dart_tool/jaspr/server_target.dart',
        ],
        workingDirectory: '/root/myapp',
        environment: {'PORT': port, 'JASPR_PROXY_PORT': proxyPort},
      ),
    ).thenAnswer((_) async => serverProcess);

    int n = 0;
    final intPort = int.parse(port);
    when(() => sockets.connect('localhost', intPort)).thenAnswer((_) async {
      if (n == 0) {
        n++;
        throw SocketException.closed();
      }
      return FakeSocket(InternetAddress.anyIPv4, intPort);
    });

    return serverProcess;
  }

  Future<void> expectServerStarted(FakeProcess server, {String port = '8080'}) async {
    await expectLater(
      this.stdout.queue,
      emitsInOrderWithTimeout([
        '[SERVER] Starting server...',
        '[SERVER] Using server entry point: lib/main.server.dart',
      ]),
    );

    expect(fs.file('.dart_tool/jaspr/server_target.dart').existsSync(), isTrue);

    await expectLater(this.stdout.queue, emits('[SERVER] Server started and listening on http://localhost:$port'));

    server.writeStdout('Fake server running.');

    await expectLater(this.stdout.queue, emits('[SERVER] Fake server running.'));
  }
}
