import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:build_daemon/data/build_status.dart';
import 'package:dwds/data/connect_request.dart';
import 'package:dwds/dwds.dart';
import 'package:jaspr_cli/src/command_runner.dart';
import 'package:jaspr_cli/src/commands/serve_command.dart';
import 'package:jaspr_cli/src/dev/dev_workflow.dart';
import 'package:jaspr_cli/src/dev/server_runner.dart';
import 'package:jaspr_cli/src/project.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:vm_service/vm_service.dart' as vm;

import '../fakes/fake_build_daemon.dart';
import '../fakes/fake_io.dart';
import '../fakes/fake_project.dart';
import '../fakes/fake_socket.dart';

const String _reloadHtmlCall = 'ext.jaspr.reload_html';

/// Expected RPCs in client mode.
/// Other modes follow these with `_reloadHtmlCall`.
const List<String> _reloadCalls = [
  'getVM',
  'reloadSources',
  'ext.jaspr.reassemble',
];

const List<String> _restartCalls = [
  'hotRestart',
];

void main() {
  for (final mode in JasprMode.values) {
    for (final (auto, shortcut, failingRpc, baseCalls) in [
      ('reload', null, 'getVM', _reloadCalls),
      ('reload', null, 'reloadSources', _reloadCalls),
      ('restart', null, 'hotRestart', _restartCalls),
      (null, 'r', 'reloadSources', _reloadCalls),
      (null, 'R', 'hotRestart', _restartCalls),
    ]) {
      final trigger = shortcut == null ? 'automatic $auto' : 'keyboard $shortcut';
      final expectedCalls = [...baseCalls, if (mode != JasprMode.client) _reloadHtmlCall];
      test('$trigger survives a browser disconnect during $failingRpc in ${mode.name} mode', () async {
        await _withWorkflow(auto, mode: mode, (fixture) async {
          Future<void> update({String? warning}) =>
              fixture.update(expectedCalls.last, shortcut: shortcut, warning: warning);

          final closing = await fixture.connectBrowser('closing');
          final healthy = await fixture.connectBrowser('healthy');

          // Establish that both browsers were connected and receiving updates.
          await update();
          expect(closing.calls, expectedCalls);
          expect(healthy.calls, expectedCalls);
          closing.calls.clear();
          healthy.calls.clear();

          // An in-flight VM request can fail before DWDS reports `onDone`.
          closing.failingRpc = failingRpc;
          await update(warning: 'client closing: Bad state: VM service disconnected');
          expect(closing.calls, expectedCalls.take(expectedCalls.indexOf(failingRpc) + 1).toList());
          expect(healthy.calls, expectedCalls);
          expect(fixture.workflow.isShuttingDown, isFalse);

          // Complete disconnect cleanup and reconnect the app.
          // The next update must still reach both clients
          // through the original build listener.
          await closing.disconnect();
          expect(fixture.workflow.clients.getConnection('closing'), isNull);
          final reconnected = await fixture.connectBrowser('closing');
          healthy.calls.clear();
          await update();
          expect(healthy.calls, expectedCalls);
          expect(reconnected.calls, expectedCalls);
        });
      });
    }
  }

  for (final (action, Future<void> Function(DevWorkflow) runUpdate, firstRpc, expectedCalls) in [
    ('reload', (DevWorkflow w) => w.reloadClients(), 'getVM', _reloadCalls),
    ('restart', (DevWorkflow w) => w.restartClients(incremental: true), 'hotRestart', _restartCalls),
    ('refresh', (DevWorkflow w) => w.refreshClients(), 'fullReload', ['fullReload']),
  ]) {
    test('$action tolerates browsers connecting and disconnecting during an update', () async {
      await _withWorkflow(null, (fixture) async {
        final first = await fixture.connectBrowser('first');
        final closing = await fixture.connectBrowser('closing');

        Future<void> update() => runUpdate(fixture.workflow);

        await update();
        expect(first.calls, expectedCalls);
        expect(closing.calls, expectedCalls);
        first.calls.clear();
        closing.calls.clear();

        final entered = Completer<void>();
        final resume = Completer<void>();
        first.beforeRpc = (method) async {
          if (method == firstRpc) {
            entered.complete();
            await resume.future;
          }
        };
        final pendingUpdate = update();
        await entered.future;
        late final _Browser added;
        try {
          await closing.disconnect();
          expect(fixture.workflow.clients.getConnection('closing'), isNull);
          added = await fixture.connectBrowser('added');
        } finally {
          resume.complete();
        }
        await pendingUpdate;
        expect(first.calls, expectedCalls);
        expect(closing.calls, isEmpty, reason: 'A disposed connection in the snapshot should be skipped.');
        expect(added.calls, isEmpty, reason: 'New connections participate in the next update.');

        first.beforeRpc = null;
        first.calls.clear();
        await update();
        expect(first.calls, expectedCalls);
        expect(added.calls, expectedCalls);
      });
    });
  }

  for (final (action, Future<void> Function(DevWorkflow) runUpdate, hangingRpc, expectedCalls) in [
    ('reload', (DevWorkflow w) => w.reloadClients(), 'reloadSources', _reloadCalls),
    ('restart', (DevWorkflow w) => w.restartClients(incremental: true), 'hotRestart', _restartCalls),
    ('refresh', (DevWorkflow w) => w.refreshClients(), 'fullReload', ['fullReload']),
  ]) {
    test('$action skips a browser that stops responding', () async {
      await _withWorkflow(null, (fixture) async {
        fixture.workflow.clients.callTimeout = const Duration(milliseconds: 100);
        final hanging = await fixture.connectBrowser('hanging');
        final healthy = await fixture.connectBrowser('healthy');

        // Fails instead of hanging when an unresponsive browser blocks the update.
        Future<void> update() => runUpdate(fixture.workflow).timeout(const Duration(seconds: 5));

        // The browser never answers, e.g. a phone with the screen turned off.
        final respond = Completer<void>();
        hanging.beforeRpc = (method) async {
          if (method == hangingRpc) await respond.future;
        };

        await update();
        expect(hanging.calls, expectedCalls.take(expectedCalls.indexOf(hangingRpc) + 1).toList());
        expect(healthy.calls, expectedCalls);
        await expectLater(
          fixture.io.stdout.queue,
          emitsWithTimeout(emitsThrough(contains('Client hanging did not respond'))),
        );

        // Following updates skip the browser without waiting for it again.
        hanging.calls.clear();
        healthy.calls.clear();
        await update();
        expect(hanging.calls, isEmpty);
        expect(healthy.calls, expectedCalls);

        // Once the pending call completes, the browser takes part in updates again.
        respond.complete();
        await pumpEventQueue();
        await expectLater(
          fixture.io.stdout.queue,
          emitsWithTimeout(emitsThrough(contains('Client hanging is responding again'))),
        );
        hanging.beforeRpc = null;
        hanging.calls.clear();
        healthy.calls.clear();
        await update();
        expect(hanging.calls, expectedCalls);
        expect(healthy.calls, expectedCalls);
      });
    });
  }

  test('delivers missed stylesheets once a browser responds again', () async {
    await _withWorkflow(null, (fixture) async {
      fixture.workflow.clients.callTimeout = const Duration(milliseconds: 100);
      final hanging = await fixture.connectBrowser('hanging');
      final respond = Completer<void>();
      hanging.beforeRpc = (method) async {
        if (method == 'reloadSources') await respond.future;
      };

      await fixture.workflow.reloadClients().timeout(const Duration(seconds: 5));
      final connection = fixture.workflow.clients.getConnection('hanging')!;
      expect(await connection.reloadStylesheets(['main.css']), isNull, reason: 'The browser is skipped.');
      expect(hanging.calls, isNot(contains('ext.jaspr.reload_stylesheets')));

      hanging.beforeRpc = null;
      respond.complete();
      await pumpEventQueue();
      expect(hanging.calls, contains('ext.jaspr.reload_stylesheets'));
      verify(
        () => hanging.service.callServiceExtension(
          'ext.jaspr.reload_stylesheets',
          args: {
            'urls': jsonEncode(['main.css']),
          },
        ),
      ).called(1);
    });
  });

  for (final (action, Future<void> Function(DevWorkflow) runUpdate, expectedCalls) in [
    ('reload', (DevWorkflow w) => w.reloadClients(), [..._reloadCalls, _reloadHtmlCall]),
    ('restart', (DevWorkflow w) => w.restartClients(), [..._restartCalls, _reloadHtmlCall]),
    ('refresh', (DevWorkflow w) => w.refreshClients(), ['fullReload']),
  ]) {
    test('$action waits for the server to reload before updating browsers', () async {
      await _withWorkflow(null, mode: JasprMode.server, (fixture) async {
        final browser = await fixture.connectBrowser('browser');
        final serverReload = Completer<void>();
        final server = _Server();
        when(() => server.reload()).thenAnswer((_) => serverReload.future);
        when(() => server.stop()).thenAnswer((_) async {});
        fixture.workflow.server = server;

        final pendingUpdate = runUpdate(fixture.workflow);
        await pumpEventQueue();
        verify(() => server.reload()).called(1);
        expect(browser.calls, isEmpty, reason: 'Browsers should wait for the server to finish reloading.');

        serverReload.complete();
        await pendingUpdate;
        expect(browser.calls, expectedCalls);
      });
    });
  }
}

/// Runs [test] against a `jaspr serve` workflow started with the
/// optional `--auto` mode [auto] in the rendering [mode], stopping it afterwards.
Future<void> _withWorkflow(
  String? auto,
  Future<void> Function(_WorkflowFixture) test, {
  JasprMode mode = JasprMode.client,
}) async {
  final io = FakeIO();
  addTearDown(io.tearDown);
  await io.runZoned(() async {
    final fixture = _WorkflowFixture(io);
    try {
      await fixture.start(auto, mode);
      await test(fixture);
    } finally {
      await fixture.stop();
    }
  });
}

/// A running `jaspr serve` command backed by fake IO, a fake build daemon,
/// and mocked DWDS browser connections.
class _WorkflowFixture {
  _WorkflowFixture(this.io);

  final FakeIO io;
  final dwds = _Dwds();
  final apps = StreamController<AppConnection>();
  final browsers = <_Browser>[];
  late final FakeBuildDaemon buildDaemon;
  late final ServeCommand command;
  late final Future<void> serve;
  Object? serveError;
  bool serveFinished = false;

  DevWorkflow get workflow => command.workflow;

  /// Starts `jaspr serve` and waits until it's serving and listening for apps.
  ///
  /// Modes other than client skip starting the server process.
  Future<void> start(String? auto, JasprMode mode) async {
    io.stdin.hasTerminalOverride = true;
    io.setupFakeProject('myapp', mode: mode.name);
    io.stubDartSDK();
    buildDaemon = io.setupFakeBuildDaemon();
    final runner = JasprCommandRunner(false, false);
    command = runner.commands['serve']! as ServeCommand;
    serve = runner
        .run(['serve', '--verbose', if (auto != null) '--auto=$auto', if (mode != JasprMode.client) '--skip-server'])
        .then<void>(
          (_) => serveFinished = true,
          onError: (Object error, StackTrace stack) {
            serveError = error;
            serveFinished = true;
          },
        );

    await expectLater(io.stdout.queue, emitsWithTimeout(emitsThrough('[BUILDER] Starting initial build...')));
    await io.runInitialBuild(buildDaemon);
    await expectLater(io.serverSockets.next, completion(isA<FakeServerSocket>()));
    await expectLater(
      io.stdout.queue,
      emitsWithTimeout(
        emitsThrough(mode == JasprMode.client ? '[LOG] Serving at http://localhost:8080' : contains('Skipping server')),
      ),
    );

    when(() => dwds.connectedApps).thenAnswer((_) => apps.stream);
    workflow.clients.listenTo(dwds);
  }

  /// Connects a new mocked browser with [appId] and
  /// waits until its client connection has started.
  Future<_Browser> connectBrowser(String appId) async {
    final browser = _Browser(appId);
    browsers.add(browser);
    when(() => dwds.debugConnection(browser.app)).thenAnswer((_) async => browser.debug);

    // The connection uses a separate VM service socket for logging and service
    // registration. Exercise its normal setup so onDone and disposal are real.
    final socket = FakeSocket(InternetAddress.loopbackIPv4, 0);
    when(() => io.sockets.connect('localhost', 9000)).thenAnswer((_) async => socket);
    final pendingLoggingSocket = io.upgradeToReverseWebSocket(socket);
    apps.add(browser.app);
    await pumpEventQueue();
    browser.loggingSocket = await pendingLoggingSocket;
    browser.loggingSocket.listen((data) {
      final request = jsonDecode(data as String) as Map<String, Object?>;
      browser.loggingSocket.add(
        jsonEncode({
          'jsonrpc': '2.0',
          'id': request['id'],
          'result': {'type': 'Success'},
        }),
      );
    });
    await browser.started.future;
    expect(workflow.clients.getConnection(appId)?.vmService, same(browser.service));
    return browser;
  }

  /// Triggers an update with the keyboard [shortcut],
  /// or a successful build if `null`,
  /// and waits until each browser
  /// without a [_Browser.failingRpc] has completed [lastRpc].
  ///
  /// If [warning] is provided, also waits for it to be logged.
  Future<void> update(String lastRpc, {String? shortcut, String? warning}) async {
    final updated = [
      for (final browser in browsers)
        if (browser.failingRpc == null) browser.completedRpcs.stream.firstWhere((method) => method == lastRpc),
    ].wait;
    if (shortcut != null) {
      io.stdin.addBytes(utf8.encode(shortcut));
    } else {
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
    }

    // Stop promptly on the original regression instead of waiting for a reload
    // that can never finish after BaseCommand shuts down the workflow.
    await Future.any([updated, serve]).timeout(const Duration(seconds: 10));
    expect(serveError, isNull);
    expect(serveFinished, isFalse);
    await updated;
    if (warning != null) {
      await expectLater(io.stdout.queue, emitsWithTimeout(emitsThrough(contains(warning))));
    }
    if (shortcut != null) {
      await expectLater(
        io.stdout.queue,
        emitsWithTimeout(emitsThrough('[CLIENT] ${shortcut == 'r' ? 'Reload' : 'Restart'} complete.')),
      );
    }
    await pumpEventQueue();
  }

  /// Stops the serve command and closes all fake connections.
  Future<void> stop() async {
    await command.stop();
    await serve;
    await apps.close();
    for (final browser in browsers) {
      await browser.loggingSocket.close();
      await browser.completedRpcs.close();
    }
    await buildDaemon.close();
  }
}

/// A mocked browser app connection with a VM service that records RPCs.
class _Browser {
  _Browser(String appId) {
    when(() => app.request).thenReturn(ConnectRequest(appId: appId, instanceId: appId, entrypointPath: 'main.dart'));
    when(() => app.runMain()).thenAnswer((_) => started.complete());
    when(() => debug.vmService).thenReturn(service);
    when(() => debug.ddsUri).thenReturn('ws://localhost:9000/ws');
    when(() => debug.uri).thenReturn('ws://localhost:9000/ws');
    when(() => debug.port).thenReturn(0);
    when(() => debug.onDone).thenAnswer((_) => done.future);
    when(() => debug.close()).thenAnswer((_) async {
      if (!done.isCompleted) done.complete();
    });
    when(() => service.getVM()).thenAnswer((_) async {
      await _rpc('getVM');
      return vm.VM(
        isolates: [vm.IsolateRef(id: 'isolates/1', name: 'main')],
      );
    });
    when(() => service.reloadSources('isolates/1')).thenAnswer((_) async {
      await _rpc('reloadSources');
      return vm.ReloadReport(success: true);
    });
    when(() => service.callServiceExtension(any(), args: any(named: 'args'))).thenAnswer((invocation) async {
      final method = invocation.positionalArguments.first as String;
      await _rpc(method);
      return vm.Success();
    });
  }

  final app = _App();
  final debug = _Debug();
  final service = _Vm();
  final started = Completer<void>();
  final done = Completer<void>();
  final completedRpcs = StreamController<String>.broadcast();

  /// The VM service methods called on this browser, in order.
  final calls = <String>[];
  late final WebSocket loggingSocket;

  /// A VM service method that should throw as if the browser disconnected.
  String? failingRpc;

  /// Called before each recorded RPC, allowing tests to pause mid-update.
  Future<void> Function(String method)? beforeRpc;

  Future<void> _rpc(String method) async {
    calls.add(method);
    await beforeRpc?.call(method);
    if (method == failingRpc) throw StateError('VM service disconnected');
    completedRpcs.add(method);
  }

  /// Closes the debug connection and waits for the client to be cleaned up.
  Future<void> disconnect() async {
    await debug.close();
    await pumpEventQueue();
  }
}

class _Dwds extends Mock implements Dwds {}

class _App extends Mock implements AppConnection {}

class _Debug extends Mock implements DebugConnection {}

class _Vm extends Mock implements vm.VmService {}

class _Server extends Mock implements ServerRunner {}
