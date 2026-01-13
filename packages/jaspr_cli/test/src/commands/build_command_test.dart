import 'dart:convert';

import 'package:jaspr_cli/src/command_runner.dart';
import 'package:jaspr_cli/src/project.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../fakes/fake_build_daemon.dart';
import '../fakes/fake_io.dart';
import '../fakes/fake_project.dart';
import '../fakes/fake_server.dart';

void main() {
  group('build command', () {
    late JasprCommandRunner runner;
    late FakeIO io;

    setUp(() {
      io = FakeIO();
      runner = JasprCommandRunner(false);
    });

    tearDown(() {
      io.tearDown();
    });

    test('builds project with client mode', () async {
      await io.runZoned(() async {
        io.setupFakeProject('myapp', mode: 'client');
        io.stubDartSDK();

        final buildDaemon = io.setupFakeBuildDaemon(verifyArgs: buildRunnerBuildArgs);

        final buildResult = runner.run(['build', '--verbose']);

        await expectLater(io.stdout.queue, emits('Building jaspr for client rendering mode.'));

        await io.runReleaseBuild(buildDaemon);

        await expectLater(io.stdout.queue, emits('Completed building project to /build/jaspr.'));

        expect(await buildResult, equals(0));
      });
    });

    test('builds project with server mode', () async {
      await io.runZoned(() async {
        io.setupFakeProject('myapp', mode: 'server');
        io.stubDartSDK();

        final buildDaemon = io.setupFakeBuildDaemon(verifyArgs: buildRunnerBuildArgs);

        final serverProcess = FakeProcess();
        when(
          () => io.process.start(
            'dart',
            any(that: containsAllInOrder(['compile', 'exe'])),
            workingDirectory: '/root/myapp',
          ),
        ).thenAnswer((inv) async {
          expect(
            inv.positionalArguments[1],
            equals(['compile', 'exe', 'lib/main.server.dart', '-o', './build/jaspr/app', '-Djaspr.flags.release=true']),
          );

          return serverProcess;
        });

        final buildResult = runner.run(['build', '--verbose']);

        await expectLater(
          io.stdout.queue,
          emitsInOrder([
            'Building jaspr for server rendering mode.',
            'Using server entry point: lib/main.server.dart',
          ]),
        );

        await io.runReleaseBuild(buildDaemon);

        await expectLater(
          io.stdout.queue,
          emitsInOrder([
            'Building server app...',
            'Compiling server executable.',
          ]),
        );

        serverProcess.exit(0);

        await expectLater(io.stdout.queue, emits('Completed building project to /build/jaspr.'));

        expect(await buildResult, equals(0));
      });
    });

    test('builds project with static mode', () async {
      await io.runZoned(() async {
        io.setupFakeProject('myapp', mode: 'static');
        io.stubDartSDK();

        final buildDaemon = io.setupFakeBuildDaemon(verifyArgs: buildRunnerBuildArgs);

        FakeProcess? serverProcess;
        when(
          () => io.process.start(
            '/fake/bin/dart',
            any(that: contains('-Djaspr.flags.generate=true')),
            workingDirectory: '/root/myapp',
            environment: any(named: 'environment'),
          ),
        ).thenAnswer((inv) async {
          expect(
            inv.positionalArguments[1],
            equals([
              '--enable-asserts',
              '-Djaspr.flags.release=true',
              '-Djaspr.flags.generate=true',
              '-Djaspr.dev.web=build/jaspr',
              'lib/main.server.dart',
            ]),
          );
          expect(
            inv.namedArguments[#environment],
            equals({'PORT': '8080', 'JASPR_PROXY_PORT': serverProxyPort}),
          );

          return serverProcess = FakeProcess();
        });

        final buildResult = runner.run(['build', '--verbose']);

        await expectLater(
          io.stdout.queue,
          emitsInOrder([
            'Building jaspr for static rendering mode.',
            'Using server entry point: lib/main.server.dart',
          ]),
        );

        await io.runReleaseBuild(buildDaemon);

        await expectLater(
          io.stdout.queue,
          emitsInOrder([
            'Preparing static rendering...',
            '[SERVER] Starting server app...',
          ]),
        );

        expect(serverProcess, isNotNull);

        final proxyConnection = await io.connectToProxy();

        final fakeServer = io.setupFakeServer(8080);

        fakeServer.onRequest('/abc', (request) async {
          request.response.write('FAKE HTML RESPONSE');
          await request.response.close();
        });

        await proxyConnection.sendFakeRequest(r'$jasprMessageHandler', jsonEncode({'route': '/abc'}));

        await expectLater(
          io.stdout.queue,
          emitsInOrder([
            'Server started',
            'Generating routes...',
            '(1/1) Generating route "/abc" ...',
          ]),
        );

        expect(io.fs.file('/root/myapp/build/jaspr/abc/index.html').existsSync(), isTrue);
        expect(io.fs.file('/root/myapp/build/jaspr/abc/index.html').readAsStringSync(), equals('FAKE HTML RESPONSE'));

        await expectLater(
          io.stdout.queue,
          emitsInOrder([
            'Completed building project to /build/jaspr.',
            'Terminating server...',
          ]),
        );

        expect(await buildResult, equals(0));
      });
    });

    test('builds project with flutter embedding', () async {
      await io.runZoned(() async {
        io.setupFakeProject('myapp', mode: 'client', flutterEmbedding: true);
        io.stubDartSDK();
        io.stubFlutterSDK();

        final buildDaemon = io.setupFakeBuildDaemon(verifyArgs: buildRunnerFlutterBuildArgs);

        final buildResult = runner.run(['build', '--verbose']);

        await expectLater(io.stdout.queue, emits('Building jaspr for client rendering mode.'));

        expect(io.fs.file('/root/myapp/web/index.html').existsSync(), isTrue);

        when(
          () => io.process.start(
            'flutter',
            [
              'build',
              'web',
              '-t',
              '.dart_tool/jaspr/flutter_target.dart',
              '--no-wasm-dry-run',
              '--output=build/flutter',
            ],
            workingDirectory: '/root/myapp',
            runInShell: true,
          ),
        ).thenAnswer((_) async {
          io.fs.file('/root/myapp/build/flutter/flutter_bootstrap.js')
            ..createSync(recursive: true)
            ..writeAsStringSync('FAKE FLUTTER BOOTSTRAP');
          io.fs.file('/root/myapp/build/flutter/canvaskit/canvaskit.js')
            ..createSync(recursive: true)
            ..writeAsStringSync('FAKE FLUTTER CANVASKIT');
          return FakeProcess.sync();
        });

        await io.runReleaseBuild(buildDaemon);

        await expectLater(io.stdout.queue, emits('Completed building project to /build/jaspr.'));

        expect(io.fs.file('/root/myapp/build/jaspr/flutter_bootstrap.js').existsSync(), isTrue);
        expect(
          io.fs.file('/root/myapp/build/jaspr/flutter_bootstrap.js').readAsStringSync(),
          equals('FAKE FLUTTER BOOTSTRAP'),
        );
        expect(io.fs.file('/root/myapp/build/jaspr/canvaskit/canvaskit.js').existsSync(), isTrue);
        expect(
          io.fs.file('/root/myapp/build/jaspr/canvaskit/canvaskit.js').readAsStringSync(),
          equals('FAKE FLUTTER CANVASKIT'),
        );

        expect(io.fs.file('/root/myapp/web/index.html').existsSync(), isFalse);

        expect(await buildResult, equals(0));
      });
    });

    test('builds project with sitemap', () async {
      await io.runZoned(() async {
        io.setupFakeProject('myapp', mode: 'static');
        io.stubDartSDK();

        final buildDaemon = io.setupFakeBuildDaemon();

        FakeProcess? serverProcess;
        when(
          () => io.process.start(
            '/fake/bin/dart',
            any(that: contains('-Djaspr.flags.generate=true')),
            workingDirectory: '/root/myapp',
            environment: any(named: 'environment'),
          ),
        ).thenAnswer((inv) async {
          return serverProcess = FakeProcess();
        });

        final buildResult = runner.run(['build', '--sitemap-domain=example.com', '--verbose']);

        await expectLater(
          io.stdout.queue,
          emitsInOrder([
            'Building jaspr for static rendering mode.',
            'Using server entry point: lib/main.server.dart',
          ]),
        );

        await io.runReleaseBuild(buildDaemon);

        await expectLater(
          io.stdout.queue,
          emitsInOrder([
            'Preparing static rendering...',
            '[SERVER] Starting server app...',
          ]),
        );

        expect(serverProcess, isNotNull);

        final proxyConnection = await io.connectToProxy();

        final fakeServer = io.setupFakeServer(8080);

        fakeServer.onRequest('/abc', (request) async {
          request.response.write('FAKE HTML RESPONSE');
          await request.response.close();
        });
        fakeServer.onRequest('/abc2', (request) async {
          request.response.headers.set(
            'jaspr-sitemap-data',
            jsonEncode({
              'lastmod': '234',
              'changefreq': 'daily',
              'priority': 0.3,
            }),
          );
          request.response.write('FAKE HTML RESPONSE 2');
          await request.response.close();
        });

        await proxyConnection.sendFakeRequest(
          r'$jasprMessageHandler',
          jsonEncode({'route': '/abc', 'lastmod': '123', 'changefreq': 'weekly', 'priority': 0.7}),
        );
        await proxyConnection.sendFakeRequest(r'$jasprMessageHandler', jsonEncode({'route': '/abc2'}));

        await expectLater(
          io.stdout.queue,
          emitsInOrder([
            'Server started',
            'Generating routes...',
            '(1/1) Generating route "/abc" ...',
            '(2/2) Generating route "/abc2" ...',
            'Generating sitemap.xml...',
          ]),
        );

        expect(io.fs.file('/root/myapp/build/jaspr/abc/index.html').existsSync(), isTrue);
        expect(io.fs.file('/root/myapp/build/jaspr/abc/index.html').readAsStringSync(), equals('FAKE HTML RESPONSE'));

        expect(io.fs.file('/root/myapp/build/jaspr/abc2/index.html').existsSync(), isTrue);
        expect(
          io.fs.file('/root/myapp/build/jaspr/abc2/index.html').readAsStringSync(),
          equals('FAKE HTML RESPONSE 2'),
        );

        expect(io.fs.file('/root/myapp/build/jaspr/sitemap.xml').existsSync(), isTrue);
        expect(
          io.fs.file('/root/myapp/build/jaspr/sitemap.xml').readAsStringSync(),
          equals(
            '<?xml version="1.0" encoding="UTF-8"?>\n'
            '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n'
            '  <url>\n'
            '    <loc>https://example.com/abc</loc>\n'
            '    <lastmod>123</lastmod>\n'
            '    <changefreq>weekly</changefreq>\n'
            '    <priority>0.7</priority>\n'
            '  </url>\n'
            '  <url>\n'
            '    <loc>https://example.com/abc2</loc>\n'
            '    <lastmod>234</lastmod>\n'
            '    <changefreq>daily</changefreq>\n'
            '    <priority>0.3</priority>\n'
            '  </url>\n'
            '</urlset>\n'
            '',
          ),
        );

        await expectLater(
          io.stdout.queue,
          emitsInOrder([
            'Completed building project to /build/jaspr.',
            'Terminating server...',
          ]),
        );

        expect(await buildResult, equals(0));
      });
    });
  });
}

const buildRunnerBuildArgs = [
  '--release',
  '--verbose',
  '--delete-conflicting-outputs',
  '--define=build_web_compilers:entrypoint=compiler=dart2js',
  '--define=build_web_compilers:entrypoint=dart2js_args=["-Djaspr.flags.release=true","-O2"]',
];

const buildRunnerFlutterBuildArgs = [
  '--release',
  '--verbose',
  '--delete-conflicting-outputs',
  '--define=build_web_compilers:entrypoint=compiler=dart2js',
  '--define=build_web_compilers:entrypoint=dart2js_args=["-Djaspr.flags.release=true","-O2","-Ddart.vm.product=true","-DFLUTTER_WEB_USE_SKWASM=false","-DFLUTTER_WEB_USE_SKIA=true"]',
  '--define=build_web_compilers:entrypoint=use-ui-libraries=true',
  '--define=build_web_compilers:entrypoint_marker=use-ui-libraries=true',
  '--define=build_web_compilers:ddc=use-ui-libraries=true',
  '--define=build_web_compilers:ddc_modules=use-ui-libraries=true',
  '--define=build_web_compilers:dart2js_modules=use-ui-libraries=true',
  '--define=build_web_compilers:dart2wasm_modules=use-ui-libraries=true',
  '--define=build_web_compilers:entrypoint=libraries-path="/fake/flutter/bin/cache/flutter_web_sdk/libraries.json"',
  '--define=build_web_compilers:entrypoint=unsafe-allow-unsupported-modules=true',
  '--define=build_web_compilers:sdk_js=use-prebuilt-sdk-from-path="/fake/flutter/bin/cache/flutter_web_sdk/kernel/amd-canvaskit"',
];
