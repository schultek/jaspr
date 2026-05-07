import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:build_daemon/data/build_status.dart' as daemon;
import 'package:dwds/data/build_result.dart';
import 'package:dwds/dwds.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart';
import 'package:shelf_proxy/shelf_proxy.dart';
import 'package:vm_service/vm_service.dart' as vm;
import 'package:vm_service/vm_service_io.dart';

import '../project.dart';
import 'chrome.dart';
import 'util.dart';

class DevProxy {
  final http.Client client;
  final Handler handler;
  final Stream<BuildResult> buildResults;
  final ReloadConfiguration reload;

  final Dwds dwds;
  final ExpressionCompilerService? ddcService;

  final _clientConnections = <String, ClientConnection>{};
  final _clientEvents = StreamController<Map<String, dynamic>>();
  Stream<Map<String, dynamic>> get clientEvents => _clientEvents.stream;

  DevProxy._({
    required this.client,
    required this.handler,
    required this.buildResults,
    required this.reload,
    required this.dwds,
    this.ddcService,
  }) {
    _listenToClientConnections();
    _listenToBuildResults();
  }

  Future<void> _listenToClientConnections() async {
    await for (final appConnection in dwds.connectedApps) {
      final appId = appConnection.request.appId;

      if (_clientConnections.containsKey(appId)) {
        appConnection.runMain();
        continue;
      }

      _clientConnections[appId] = ClientConnection(appConnection, dwds, this)..start();
    }
  }

  void _listenToBuildResults() async {
    if (reload == ReloadConfiguration.hotReload) {
      await for (final buildResult in buildResults) {
        if (buildResult.status == BuildStatus.succeeded) {
          for (final clientConnection in _clientConnections.values) {
            await clientConnection.performHotReload();

            for (var callback in _postReloadCallbacks) {
              callback();
            }
          }
        }
      }
    }
  }

  List<Function> _postReloadCallbacks = [];

  void registerPostReloadCallback(Function callback) {
    _postReloadCallbacks.add(callback);
  }

  void unregisterPostReloadCallback(Function callback) {
    _postReloadCallbacks.remove(callback);
  }

  List<ClientConnection> getClientConnections() => _clientConnections.values.toList();

  ClientConnection? getClientConnection(String? appId) {
    if (appId == null) return null;
    return _clientConnections[appId];
  }

  static Future<DevProxy> start(
    int daemonPort,
    int proxyPort,
    Stream<daemon.BuildResults> buildResults, {
    bool enableDebugging = false,
    bool useDwdsWebSocketConnection = true,
    ReloadConfiguration reload = ReloadConfiguration.hotRestart,
    String moduleFormat = 'amd',
  }) async {
    const target = 'web';
    final reloadedSources = <Map<String, dynamic>>[];
    var pipeline = const Pipeline();

    // Only provide relevant build results
    final filteredBuildResults = buildResults.asyncMap<BuildResult>((results) {
      if (moduleFormat == 'ddc') {
        reloadedSources.clear();
        results.changedAssets?.forEach((uri) {
          if (uri.path.endsWith('.ddc.js')) {
            final reloadedSource = {
              'src': ddcUriToSourceUrl('', target, uri),
              'module': ddcUriToLibraryId(uri),
              'libraries': [ddcUriToLibraryId(uri)],
            };
            reloadedSources.add(reloadedSource);
          }
        });
      }
      final result = results.results.firstWhere((result) => result.target == target);
      switch (result.status) {
        case daemon.BuildStatus.started:
          return BuildResult(status: BuildStatus.started);
        case daemon.BuildStatus.failed:
          return BuildResult(status: BuildStatus.failed);
        case daemon.BuildStatus.succeeded:
          return BuildResult(status: BuildStatus.succeeded);
        default:
          break;
      }
      throw StateError('Unexpected Daemon build result: $result');
    });

    var cascade = Cascade();

    final client = http.Client();
    final assetHandler = proxyHandler('http://localhost:$daemonPort/$target/', client: client);

    Dwds? dwds;
    ExpressionCompilerService? ddcService;

    final assetReader = ProxyServerAssetReader(
      daemonPort,
      root: target,
    );

    final buildSettings = BuildSettings(
      //appEntrypoint: Uri.parse('org-dartlang-app:///$target/main.dart'),
      canaryFeatures: moduleFormat == 'ddc' || reload == ReloadConfiguration.hotReload,
      isFlutterApp: false,
      experiments: [],
    );

    final reloadedSourcesUri = Uri.parse('/reloaded_sources.json');

    // We handle hot-reload ourselves, so we don't need the DDC service to do it.
    final reloadStrategy = reload == ReloadConfiguration.hotReload ? ReloadConfiguration.none : reload;

    final loadStrategy = moduleFormat == 'ddc'
        ? BuildRunnerDdcLibraryBundleStrategyProvider(
            reloadStrategy,
            assetReader,
            buildSettings,
            packageConfigPath: findPackageConfigFilePath(),
            reloadedSourcesUri: reloadedSourcesUri,
          ).strategy
        : BuildRunnerRequireStrategyProvider(
            reloadStrategy,
            assetReader,
            buildSettings,
            packageConfigPath: findPackageConfigFilePath(),
          ).strategy;

    if (enableDebugging) {
      ddcService = ExpressionCompilerService(
        'localhost',
        proxyPort,
        verbose: false,
        sdkConfigurationProvider: const JasprSdkConfigurationProvider(),
      );
    }

    final debugSettings = DebugSettings(
      enableDebugExtension: enableDebugging,
      enableDebugging: enableDebugging,
      ddsConfiguration: DartDevelopmentServiceConfiguration(
        enable: true,
        serveDevTools: true,
        dartExecutable: dartExecutable,
      ),
      expressionCompiler: ddcService,
    );

    final appMetadata = AppMetadata(
      hostname: 'localhost',
    );

    final toolConfiguration = ToolConfiguration(
      loadStrategy: loadStrategy,
      debugSettings: debugSettings,
      appMetadata: appMetadata,
    );
    dwds = await Dwds.start(
      toolConfiguration: toolConfiguration,
      assetReader: assetReader,
      buildResults: filteredBuildResults,
      chromeConnection: () async => (await Chrome.connectedInstance).chrome.chromeConnection,
      useDwdsWebSocketConnection: useDwdsWebSocketConnection,
    );

    if (moduleFormat == 'ddc') {
      cascade = cascade.add((Request req) {
        if (req.url.path == 'reloaded_sources.json') {
          return Response.ok(jsonEncode(reloadedSources), headers: {'content-type': 'application/json'});
        }
        return Response.notFound('');
      });
    }

    pipeline = pipeline.addMiddleware(dwds.middleware);

    cascade = cascade.add(dwds.handler);
    cascade = cascade.add(assetHandler);

    return DevProxy._(
      client: client,
      handler: pipeline.addHandler(cascade.handler),
      buildResults: filteredBuildResults,
      reload: reload,
      dwds: dwds,
      ddcService: ddcService,
    );
  }

  Future<void> stop() async {
    client.close();
    await dwds.stop();
    await ddcService?.stop();
    for (final connection in _clientConnections.values) {
      connection.dispose();
    }
    _clientConnections.clear();
  }
}

/// A custom [SdkConfigurationProvider] that resolves the SDK directory
/// using the `dartExecutable` in AOT mode.
class JasprSdkConfigurationProvider extends SdkConfigurationProvider {
  const JasprSdkConfigurationProvider();

  @override
  Future<SdkConfiguration> get configuration async {
    // Check that we're running from a compiled binary (like jaspr.exe) and not
    // from source or snapshot.
    final isAotMode =
        !Platform.script.path.endsWith('.dart') &&
        !Platform.script.path.endsWith('.snapshot') &&
        !Platform.script.path.endsWith('.dill');

    final defaultLayout = SdkLayout.createDefault(dartSdkDir);

    if (!isAotMode) {
      return SdkConfiguration.fromSdkLayout(defaultLayout);
    }

    final aotSnapshotPath = p.join(
      dartSdkDir,
      'bin',
      'snapshots',
      'dartdevc_aot.dart.snapshot',
    );

    return SdkConfiguration.fromSdkLayout(
      SdkLayout(
        sdkDirectory: dartSdkDir,
        summaryPath: defaultLayout.summaryPath,
        dartdevcSnapshotPath: aotSnapshotPath,
      ),
    );
  }
}

String ddcUriToSourceUrl(String basePath, String target, Uri uri) {
  String jsPath;
  if (uri.isScheme('asset')) {
    var pathParts = uri.pathSegments.skip(1);
    if (pathParts.first == target) {
      pathParts = pathParts.skip(1);
    }
    jsPath = pathParts.join('/');
  } else if (uri.isScheme('package')) {
    jsPath = 'packages/${uri.path}';
  } else {
    jsPath = uri.path;
  }
  return '$basePath/$jsPath';
}

String ddcUriToLibraryId(Uri uri) {
  final jsPath = uri.isScheme('package') ? 'package:${uri.path}' : 'org-dartlang-app:///${uri.path}';
  final prefix = jsPath.substring(
    0,
    jsPath.length - '.ddc.js'.length,
  );
  return '$prefix.dart';
}

class ClientConnection {
  ClientConnection(this.appConnection, this.dwds, this.devProxy);

  final AppConnection appConnection;
  final Dwds dwds;
  final DevProxy devProxy;

  DebugConnection? _debugConnection;
  StreamSubscription<BuildResult>? _resultSub;
  StreamSubscription<vm.Event>? _stdOutSub;
  StreamSubscription<vm.Event>? _vmServiceSub;

  bool _isDisposed = false;

  vm.VmService? get vmService => _debugConnection?.vmService;

  void start() async {
    final appId = appConnection.request.appId;

    try {
      final debugConnection = _debugConnection = await dwds.debugConnection(appConnection);
      final debugUri = debugConnection.ddsUri ?? debugConnection.uri;
      final vmService = await vmServiceConnectUri(debugUri);

      if (_isDisposed) return;

      unawaited(
        debugConnection.onDone.then((_) {
          sendEvent('client.log', {'appId': appId, 'log': 'Lost connection to device.'});
          sendEvent('client.stop', {'appId': appId});
          dispose();
          devProxy._clientConnections.remove(appId);
        }),
      );

      sendEvent('client.start', {
        'appId': appId,
        'directory': Directory.current.path,
        'deviceId': 'chrome',
        'launchMode': 'run',
      });

      try {
        await vmService.streamCancel('Stdout');
      } catch (_) {}
      try {
        await vmService.streamListen('Stdout');
      } catch (_) {}

      try {
        _vmServiceSub = vmService.onServiceEvent.listen(_onServiceEvent);
        await vmService.streamListen('Service');
      } catch (_) {}

      if (_isDisposed) return;

      _stdOutSub = vmService.onStdoutEvent.listen((log) {
        sendEvent('client.log', {'appId': appId, 'log': utf8.decode(base64.decode(log.bytes!))});
      });

      sendEvent('client.debugPort', {'appId': appId, 'port': debugConnection.port, 'wsUri': debugConnection.uri});
    } catch (e) {
      // noop
    }

    _resultSub = devProxy.buildResults.listen((r) {
      _handleBuildResult(r, appId);
    });

    sendEvent('app.started', {'appId': appId});

    appConnection.runMain();
  }

  void sendEvent(String method, Map<String, dynamic> params) {
    devProxy._clientEvents.add({'method': method, 'params': params});
  }

  // Mapping from service name to service method.
  final Map<String, String> _registeredMethodsForService = <String, String>{};

  void _onServiceEvent(vm.Event e) {
    if (e.kind == vm.EventKind.kServiceRegistered) {
      final serviceName = e.service!;
      _registeredMethodsForService[serviceName] = e.method!;
    }

    if (e.kind == vm.EventKind.kServiceUnregistered) {
      final serviceName = e.service!;
      _registeredMethodsForService.remove(serviceName);
    }
  }

  Future<vm.Response?> restart() async {
    final restartMethod = _registeredMethodsForService['hotRestart'] ?? 'hotRestart';
    final response = await vmService?.callServiceExtension(restartMethod);
    return response;
  }

  Future<void> performHotReload() async {
    final isolateId = (await vmService?.getVM())?.isolates?.first.id;
    vm.ReloadReport? response;
    for (var i = 0; i < 5; i++) {
      response = await vmService?.reloadSources(isolateId!);
      if (response?.success ?? false) {
        break;
      }
    }
    if (response?.success ?? false) {
      await reassemble();
    }
  }

  Future<vm.Response?> reassemble() async {
    final reassembleMethod = _registeredMethodsForService['ext.jaspr.reassemble'] ?? 'ext.jaspr.reassemble';
    try {
      final response = await vmService?.callServiceExtension(reassembleMethod);
      return response;
    } catch (_) {
      return null;
    }
  }

  int? _buildProgressEventId;
  var _progressEventId = 0;

  Future<void> _handleBuildResult(BuildResult result, String appId) async {
    switch (result.status) {
      case BuildStatus.started:
        _buildProgressEventId = _progressEventId++;
        sendEvent('client.progress', {'appId': appId, 'id': '$_buildProgressEventId', 'message': 'Building...'});
      case BuildStatus.failed:
        sendEvent('client.progress', {'appId': appId, 'id': '$_buildProgressEventId', 'finished': true});
      case BuildStatus.succeeded:
        sendEvent('client.progress', {'appId': appId, 'id': '$_buildProgressEventId', 'finished': true});
        await reassemble();
    }
  }

  Future<void> stop() async {
    _debugConnection?.close();
  }

  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;

    _stdOutSub?.cancel();
    _resultSub?.cancel();
    _vmServiceSub?.cancel();
    _debugConnection?.close();
  }
}
