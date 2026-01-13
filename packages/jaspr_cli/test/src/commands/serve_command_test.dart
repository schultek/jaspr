import 'dart:io';

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
      runner = JasprCommandRunner(false);
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

        await expectLater(io.stdout.queue, emits('Running jaspr in client rendering mode.'));

        await io.runInitialBuild(buildDaemon);

        await expectLater(
          io.serverSockets.next,
          completion(isA<FakeServerSocket>().having((s) => s.port, 'port', 8080)),
        );

        await expectLater(io.stdout.queue, emits('[CLI] Serving at http://localhost:8080'));

        await io.shutdownBuildDaemon(buildDaemon);

        expect(io.stdout.queue, emits('Terminating web compilers...'));

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
          emitsInOrder([
            'Running jaspr in server rendering mode.',
            'Using server entry point: lib/main.server.dart',
          ]),
        );

        await io.runInitialBuild(buildDaemon);

        await expectLater(
          io.serverSockets.next,
          completion(isA<FakeServerSocket>().having((s) => s.port, 'port', int.parse(serverProxyPort))),
        );

        await io.expectServerStarted(server);

        server.exit(0);

        expect(io.stdout.queue, emits('Terminating web compilers...'));

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
          emitsInOrder([
            'Running jaspr in server rendering mode.',
            'Using server entry point: lib/main.server.dart',
          ]),
        );

        await io.runInitialBuild(buildDaemon);

        expect(flutterProcess, isNotNull);

        await io.connectToProxy();

        await io.expectServerStarted(server);

        server.exit(0);

        expect(
          io.stdout.queue,
          emitsInOrder([
            'Terminating web compilers...',
            'Terminating flutter run...',
          ]),
        );

        expect(await serveResult, equals(0));
      });
    });
  });
}

const buildRunnerDartArgs = [
  '--delete-conflicting-outputs',
  '--define=build_web_compilers:ddc=generate-full-dill=true',
  '--define=build_web_compilers:entrypoint=compiler=dartdevc',
  '--define=build_web_compilers:ddc=environment={"jaspr.flags.verbose":false}',
];

const buildRunnerFlutterArgs = [
  '--delete-conflicting-outputs',
  '--define=build_web_compilers:ddc=generate-full-dill=true',
  '--define=build_web_compilers:entrypoint=compiler=dartdevc',
  '--define=build_web_compilers:ddc=environment={"jaspr.flags.verbose":false,"dart.vm.product":"false","FLUTTER_WEB_USE_SKWASM":"false","FLUTTER_WEB_USE_SKIA":"true"}',
  '--define=build_web_compilers:entrypoint=use-ui-libraries=true',
  '--define=build_web_compilers:entrypoint_marker=use-ui-libraries=true',
  '--define=build_web_compilers:ddc=use-ui-libraries=true',
  '--define=build_web_compilers:ddc_modules=use-ui-libraries=true',
  '--define=build_web_compilers:dart2js_modules=use-ui-libraries=true',
  '--define=build_web_compilers:dart2wasm_modules=use-ui-libraries=true',
  '--define=build_web_compilers:entrypoint=libraries-path="/fake/flutter/bin/cache/flutter_web_sdk/libraries.json"',
  '--define=build_web_compilers:entrypoint=unsafe-allow-unsupported-modules=true',
  '--define=build_web_compilers:sdk_js=use-prebuilt-sdk-from-path="/fake/flutter/bin/cache/flutter_web_sdk/kernel/amd-canvaskit"',
  '--define=build_web_compilers:ddc=ddc-kernel-path="kernel/ddc_outline.dill"',
  '--define=build_web_compilers:ddc=libraries-path="/fake/flutter/bin/cache/flutter_web_sdk/libraries.json"',
  '--define=build_web_compilers:ddc=platform-sdk="/fake/flutter/bin/cache/flutter_web_sdk"',
];

extension FakeServerIO on FakeIO {
  FakeProcess stubFakeServer() {
    final serverProcess = FakeProcess();

    when(
      () => process.start(
        '/fake/bin/dart',
        [
          '--enable-vm-service',
          '--enable-asserts',
          '-Djaspr.flags.verbose=false',
          '/root/myapp/.dart_tool/jaspr/server_target.dart',
        ],
        workingDirectory: '/root/myapp',
        environment: {'PORT': '8080', 'JASPR_PROXY_PORT': '5567'},
      ),
    ).thenAnswer((_) async => serverProcess);

    int n = 0;
    when(() => sockets.connect('localhost', 8080)).thenAnswer((_) async {
      if (n == 0) {
        n++;
        throw SocketException.closed();
      }
      return FakeSocket(InternetAddress.anyIPv4, 8080);
    });

    return serverProcess;
  }

  Future<void> expectServerStarted(FakeProcess server) async {
    await expectLater(this.stdout.queue, emits('[CLI] Starting server...'));

    expect(fs.file('.dart_tool/jaspr/server_target.dart').existsSync(), isTrue);
    expect(fs.file('.dart_tool/jaspr/server.pid').existsSync(), isTrue);

    await expectLater(this.stdout.queue, emits('[CLI] Server started.'));

    server.writeStdout('Fake server running.');

    await expectLater(this.stdout.queue, emits('[SERVER] Fake server running.'));
  }
}
