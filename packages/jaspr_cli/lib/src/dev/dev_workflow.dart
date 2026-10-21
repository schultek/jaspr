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

import '../logging.dart';
import '../project.dart';
import 'chrome.dart';
import 'chrome_runner.dart';
import 'client_manager.dart';
import 'client_runner.dart';
import 'css_runner.dart';
import 'flutter_runner.dart';
import 'server_runner.dart';
import 'util.dart';

class DevWorkflow {
  final ClientRunner clientRunner;
  final CssRunner css;
  final http.Client client;
  final Handler handler;
  final Stream<BuildResult> buildResults;
  final ReloadConfiguration reload;
  final String moduleFormat;
  final int proxyPort;

  Dwds _dwds;
  bool _useDwdsWebSocketConnection;
  final ToolConfiguration _toolConfiguration;
  final AssetReader _assetReader;

  final ExpressionCompilerService? ddcService;
  final Logger logger;

  late final ClientManager clients;
  late final ChromeRunner chrome;

  ServerRunner? server;
  FlutterRunner? flutter;

  late final StreamSubscription<Map<String, Object?>> _clientEventsSub;
  StreamSubscription<void>? _buildResultsSub;
  StreamSubscription<void>? _buildActionsSub;

  bool _isBuilding = false;
  bool get isBuilding => _isBuilding;

  QueuedAction? _queuedAction;
  QueuedAction? get queuedAction => _queuedAction;

  void queueAction(QueuedAction action) {
    if (_queuedAction == QueuedAction.restart && action == QueuedAction.reload) {
      return;
    }
    _queuedAction = action;
  }

  QueuedAction? takeQueuedAction() {
    final action = _queuedAction;
    _queuedAction = null;
    return action;
  }

  final _doneCompleter = Completer<int>();
  Future<int> get done => _doneCompleter.future;

  Stream<Map<String, Object?>> get clientEvents => clients.clientEvents;
  String? get clientDevToolsUri => clients.clientDevToolsUri;
  String? get serverDevToolsUri => server?.devToolsUri;

  DevWorkflow._({
    required this.clientRunner,
    required this.css,
    required this.client,
    required this.handler,
    required this.buildResults,
    required this.reload,
    required this.moduleFormat,
    required this.proxyPort,
    required this._dwds,
    required this._useDwdsWebSocketConnection,
    required this._toolConfiguration,
    required this._assetReader,
    required this.logger,
    this.ddcService,
  }) {
    clients = ClientManager(this);
    clients.listenTo(_dwds);
    chrome = ChromeRunner(this, logger);

    _clientEventsSub = clientEvents.listen((event) {
      if (event['method'] == 'client.stop') {
        chrome.reset();
      }
    });

    clientRunner.done.then((code) {
      if (!_doneCompleter.isCompleted) {
        _doneCompleter.complete(code);
      }
    });

    _listenToBuildResults();
  }

  void _listenToBuildResults() {
    _buildResultsSub = buildResults.listen((buildResult) {
      if (buildResult.status == BuildStatus.started) {
        _isBuilding = true;
      } else {
        _isBuilding = false;
      }
    });

    _buildActionsSub = buildResults
        .asyncMap((buildResult) async {
          if (buildResult.status == BuildStatus.succeeded) {
            if (_queuedAction == null) {
              switch (reload) {
                case ReloadConfiguration.hotReload:
                  await reloadClients();
                case ReloadConfiguration.hotRestart:
                  await restartClients(incremental: true);
                case ReloadConfiguration.liveReload:
                  await refreshClients();
                case ReloadConfiguration.none:
              }
            }
          }
        })
        .listen(null);
  }

  Future<void> reloadClients() async {
    flutter?.reload();
    final cssFuture = css.reload();
    await server?.reload();

    for (final clientConnection in clients.connections) {
      await clientConnection.performHotReload();
      await clientConnection.reassemble();
      await clientConnection.reloadHtml();
    }

    final changedCssFiles = await cssFuture;
    if (changedCssFiles.isNotEmpty) {
      for (final clientConnection in clients.connections) {
        await clientConnection.reloadStylesheets(changedCssFiles);
      }
      for (final file in changedCssFiles) {
        logger.write('Reloaded $file', tag: Tag.css);
      }
    }
  }

  Future<void> restartClients({bool incremental = false}) async {
    final Future<List<String>> cssFuture;
    if (incremental) {
      flutter?.reload();
      cssFuture = css.reload();
    } else {
      flutter?.restart();
      cssFuture = css.restart();
    }

    await server?.reload();

    for (final clientConnection in clients.connections) {
      await clientConnection.restart();
      await clientConnection.reloadHtml();
    }

    final changedCssFiles = await cssFuture;
    if (changedCssFiles.isNotEmpty) {
      for (final clientConnection in clients.connections) {
        await clientConnection.reloadStylesheets(changedCssFiles);
      }
      for (final file in changedCssFiles) {
        logger.write('Reloaded $file', tag: Tag.css);
      }
    }
  }

  Future<void> refreshClients() async {
    flutter?.reload();
    final cssFuture = css.reload();
    await server?.reload();
    final changedCssFiles = await cssFuture;
    if (changedCssFiles.isNotEmpty) {
      for (final file in changedCssFiles) {
        logger.write('Reloaded $file', tag: Tag.css);
      }
    }

    for (final client in clients.connections) {
      await client.refreshPage();
    }
  }

  /// Ensures DWDS is operating in Chrome DevTools Protocol (CDP) mode.
  ///
  /// When Chrome is launched for debugging, this dynamically swaps DWDS from
  /// WebSocket mode to CDP mode without recompiling or restarting the Shelf server.
  Future<void> ensureCdpMode() async {
    if (!_useDwdsWebSocketConnection) {
      return;
    }

    _useDwdsWebSocketConnection = false;

    clients.stop();
    await _dwds.stop();

    _dwds = await Dwds.start(
      toolConfiguration: _toolConfiguration,
      assetReader: _assetReader,
      buildResults: buildResults,
      chromeConnection: () async => (await Chrome.connectedInstance).chrome.chromeConnection,
      useDwdsWebSocketConnection: false,
    );

    clients.listenTo(_dwds);
  }

  static Future<DevWorkflow?> start({
    required int proxyPort,
    required List<String> buildArgs,
    required Project project,
    required Logger logger,
    required void Function(FutureOr<void> Function()) guard,
    bool enableDebugging = true,
    bool launchInChrome = false,
    ReloadConfiguration reload = ReloadConfiguration.hotRestart,
    String moduleFormat = 'ddc',
  }) async {
    final clientRunner = await ClientRunner.start(buildArgs, logger, guard);
    if (clientRunner == null) {
      return null;
    }

    const target = 'web';
    final reloadedSources = <Map<String, Object>>[];
    var pipeline = const Pipeline();

    // Only provide relevant build results as a broadcast stream.
    final filteredBuildResults = clientRunner.buildResults.asyncMap<BuildResult>((results) {
      if (moduleFormat == 'ddc') {
        reloadedSources.clear();
        results.changedAssets?.forEach((uri) {
          if (uri.path.endsWith('.ddc.js')) {
            final libraryId = ddcUriToLibraryId(uri);
            final reloadedSource = {
              'src': ddcUriToSourceUrl('', target, uri),
              'module': libraryId,
              'libraries': [libraryId],
            };
            reloadedSources.add(reloadedSource);
          }
        });
      }
      final resultForTarget = results.results.where((result) => result.target == target).firstOrNull;
      final result = switch (resultForTarget?.status) {
        daemon.BuildStatus.started => BuildResult(status: BuildStatus.started),
        daemon.BuildStatus.failed => BuildResult(status: BuildStatus.failed),
        daemon.BuildStatus.succeeded => BuildResult(status: BuildStatus.succeeded),
        _ => null,
      };
      if (result == null) {
        throw StateError('Unexpected Daemon build result: $resultForTarget');
      }
      return result;
    }).asBroadcastStream();

    final initialBuildCompleter = Completer<BuildResult>();

    final initialBuildSub = filteredBuildResults.listen((result) {
      if (!initialBuildCompleter.isCompleted &&
          (result.status == BuildStatus.succeeded || result.status == BuildStatus.failed)) {
        initialBuildCompleter.complete(result);
      }
    });

    final timer = Timer(const Duration(seconds: 20), () {
      if (!initialBuildCompleter.isCompleted) {
        logger.write(
          'Building web assets... (This takes longer for the initial build)',
          tag: Tag.builder,
          progress: ProgressState.running,
        );
      }
    });

    var aborted = false;
    guard(() {
      if (!initialBuildCompleter.isCompleted) {
        logger.write('Aborting build...', level: Level.debug);
        aborted = true;
        initialBuildCompleter.completeError(Object());
      }
    });

    clientRunner.startBuild();

    final BuildResult initialResult;
    try {
      initialResult = await initialBuildCompleter.future;
    } catch (_) {
      if (aborted) {
        return null;
      }
      rethrow;
    } finally {
      timer.cancel();
      await initialBuildSub.cancel();
    }

    if (initialResult.status == BuildStatus.failed) {
      logger.write(
        'Could not start dev server due to build errors.',
        tag: Tag.builder,
        level: Level.error,
        progress: ProgressState.completed,
      );
      return null;
    }

    logger.write('Done building web assets.', tag: Tag.builder, progress: ProgressState.completed);

    final css = await CssRunner.watch(
      project: project,
      logger: logger,
    );

    var cascade = Cascade();

    final client = http.Client();
    final assetHandler = proxyHandler('http://localhost:${clientRunner.daemonPort}/$target/', client: client);

    ExpressionCompilerService? ddcService;

    final assetReader = ProxyServerAssetReader.fromHandler(assetHandler);

    final buildSettings = BuildSettings(
      canaryFeatures: moduleFormat == 'ddc',
      isFlutterApp: false,
      experiments: [],
    );

    final reloadedSourcesUri = Uri.parse('/reloaded_sources.json');
    final reloadStrategy = ReloadConfiguration.none;

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

    final useDwdsWebSocketConnection = !launchInChrome;

    final dwds = await Dwds.start(
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

    late final DevWorkflow workflow;

    // Use delegating middleware and handler to allow dynamic DWDS swapping.
    pipeline = pipeline.addMiddleware(
      (inner) =>
          (req) => workflow._dwds.middleware(inner)(req),
    );
    cascade = cascade.add((req) => workflow._dwds.handler(req));
    cascade = cascade.add(assetHandler);

    workflow = DevWorkflow._(
      clientRunner: clientRunner,
      css: css,
      client: client,
      handler: pipeline.addHandler(cascade.handler),
      buildResults: filteredBuildResults,
      reload: reload,
      moduleFormat: moduleFormat,
      proxyPort: proxyPort,
      dwds: dwds,
      useDwdsWebSocketConnection: useDwdsWebSocketConnection,
      toolConfiguration: toolConfiguration,
      assetReader: assetReader,
      ddcService: ddcService,
      logger: logger,
    );

    guard(() async {
      await workflow.shutDown();
    });

    return workflow;
  }

  Future<void>? _shuttingDown;
  bool get isShuttingDown => _shuttingDown != null;

  Future<void> shutDown([int code = 0]) {
    return _shuttingDown ??= () async {
      clients.stop();
      await _clientEventsSub.cancel();
      await _buildResultsSub?.cancel();
      await _buildActionsSub?.cancel();
      await clientRunner.shutDown(code);
      await flutter?.stop();
      await server?.stop();
      await chrome.close();
      await css.stop();
      client.close();
      await _dwds.stop();
      await ddcService?.stop();
      if (!_doneCompleter.isCompleted) {
        _doneCompleter.complete(code);
      }
    }();
  }
}

enum QueuedAction { reload, restart }

/// A custom [SdkConfigurationProvider] that resolves the SDK directory
/// using the `dartExecutable` in AOT mode.
class JasprSdkConfigurationProvider extends SdkConfigurationProvider {
  const JasprSdkConfigurationProvider();

  @override
  Future<SdkConfiguration> get configuration async {
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

/// Converts a [Uri] that refers to a JavaScript file in the `web` target
/// to a relative URI from the root of the web server.
String ddcUriToSourceUrl(String basePath, String target, Uri uri) {
  final String jsPath;
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

/// Converts a [Uri] that refers to a JavaScript file in the `web` target
/// to a library id that can be used to resolve the library in the SDK.
String ddcUriToLibraryId(Uri uri) {
  final jsPath = uri.isScheme('package') ? 'package:${uri.path}' : 'org-dartlang-app:///${uri.path}';
  final prefix = jsPath.substring(
    0,
    jsPath.length - '.ddc.js'.length,
  );
  return '$prefix.dart';
}
