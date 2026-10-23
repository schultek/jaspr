import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:build_daemon/data/build_status.dart';
import 'package:dwds/data/connect_request.dart';
import 'package:dwds/dwds.dart';
import 'package:jaspr_cli/src/command_runner.dart';
import 'package:jaspr_cli/src/commands/serve_command.dart';
import 'package:jaspr_cli/src/dev/dev_workflow.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:vm_service/vm_service.dart' as vm;

import '../fakes/fake_build_daemon.dart';
import '../fakes/fake_io.dart';
import '../fakes/fake_project.dart';
import '../fakes/fake_socket.dart';

const List<String> _reloadCalls = [
  'getVM',
  'reloadSources',
  'ext.jaspr.reassemble',
  'ext.jaspr.reload_html',
];
const List<String> _restartCalls = [
  'hotRestart',
  'ext.jaspr.reload_html',
];

void main() {
  for (final (auto, shortcut, failingRpc, expectedCalls) in [
    ('reload', null, 'getVM', _reloadCalls),
    ('reload', null, 'reloadSources', _reloadCalls),
    ('restart', null, 'hotRestart', _restartCalls),
    (null, 'r', 'reloadSources', _reloadCalls),
    (null, 'R', 'hotRestart', _restartCalls),
  ]) {
    final trigger = shortcut == null ? 'automatic $auto' : 'keyboard $shortcut';
    test('$trigger survives a browser disconnect during $failingRpc', () async {
      await _withWorkflow(auto, (fixture) async {
        final closing = await fixture.connectBrowser('closing');
        final healthy = await fixture.connectBrowser('healthy');

        // Establish that both browsers were connected and receiving updates.
        await fixture.update(healthy, shortcut: shortcut);
        expect(closing.calls, expectedCalls);
        expect(healthy.calls, expectedCalls);
        closing.calls.clear();
        healthy.calls.clear();

        // An in-flight VM request can fail before DWDS reports `onDone`.
        closing.failingRpc = failingRpc;
        await fixture.update(
          healthy,
          shortcut: shortcut,
          warning: 'client closing: Bad state: VM service disconnected',
        );
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
        await fixture.update(healthy, shortcut: shortcut);
        expect(healthy.calls, expectedCalls);
        expect(reconnected.calls, expectedCalls);
      });
    });
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
}

/// Runs [test] against a `jaspr serve` workflow started with the
/// optional `--auto` mode [auto], stopping it afterwards.
Future<void> _withWorkflow(String? auto, Future<void> Function(_WorkflowFixture) test) async {
  final io = FakeIO();
  addTearDown(io.tearDown);
  await io.runZoned(() async {
    final fixture = _WorkflowFixture(io);
    try {
      await fixture.start(auto);
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
  Future<void> start(String? auto) async {
    io.stdin.hasTerminalOverride = true;
    io.setupFakeProject('myapp', mode: 'client');
    io.stubDartSDK();
    buildDaemon = io.setupFakeBuildDaemon();
    final runner = JasprCommandRunner(false, false);
    command = runner.commands['serve']! as ServeCommand;
    serve = runner
        .run(['serve', '--verbose', if (auto != null) '--auto=$auto'])
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
    await expectLater(io.stdout.queue, emitsWithTimeout(emitsThrough('[LOG] Serving at http://localhost:8080')));

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
  /// and waits until the [healthy] browser has reloaded its HTML.
  ///
  /// If [warning] is provided, also waits for it to be logged.
  Future<void> update(_Browser healthy, {String? shortcut, String? warning}) async {
    final updated = healthy.htmlUpdates.stream.first;
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
      await browser.htmlUpdates.close();
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
      if (method == 'ext.jaspr.reload_html') htmlUpdates.add(null);
      return vm.Success();
    });
  }

  final app = _App();
  final debug = _Debug();
  final service = _Vm();
  final started = Completer<void>();
  final done = Completer<void>();
  final htmlUpdates = StreamController<void>.broadcast();

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
