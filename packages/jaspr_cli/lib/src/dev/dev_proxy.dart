import 'package:build_daemon/data/build_status.dart' as daemon;
import 'package:dds/devtools_server.dart';
import 'package:dwds/data/build_result.dart';
import 'package:dwds/dwds.dart';
import 'package:dwds/sdk_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart';
import 'package:shelf_proxy/shelf_proxy.dart';

import '../project.dart';
import 'chrome.dart';
import 'util.dart';

class DevProxy {
  final http.Client client;
  final Handler handler;
  final Stream<BuildResult> buildResults;

  /// Can be null if client.js injection is disabled.
  final Dwds? dwds;
  final ExpressionCompilerService? ddcService;

  DevProxy._(
    this.client,
    this.handler,
    this.buildResults,
    bool autoRun, {
    this.dwds,
    this.ddcService,
  }) {
    if (autoRun) {
      dwds?.connectedApps.listen((connection) {
        connection.runMain();
      });
    }
  }

  static Future<DevProxy> start(
    int daemonPort,
    Stream<daemon.BuildResults> buildResults, {
    bool autoRun = true,
    bool enableDebugging = false,
    bool enableInjectedClient = true,
    ReloadConfiguration reload = ReloadConfiguration.hotRestart,
  }) async {
    const target = 'web';
    var pipeline = const Pipeline();

    //pipeline = pipeline.addMiddleware(interceptFavicon);

    // Only provide relevant build results
    final filteredBuildResults = buildResults.asyncMap<BuildResult>((results) {
      final result = results.results.firstWhere((result) => result.target == target);
      switch (result.status) {
        case daemon.BuildStatus.started:
          return BuildResult((b) => b.status = BuildStatus.started);
        case daemon.BuildStatus.failed:
          return BuildResult((b) => b.status = BuildStatus.failed);
        case daemon.BuildStatus.succeeded:
          return BuildResult((b) => b.status = BuildStatus.succeeded);
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
    if (enableInjectedClient) {
      final assetReader = ProxyServerAssetReader(
        daemonPort,
        root: target,
      );

      final buildSettings = BuildSettings(
        appEntrypoint: Uri.parse('org-dartlang-app:///$target/main.dart'),
        canaryFeatures: false,
        isFlutterApp: false,
        experiments: [],
      );

      final loadStrategy = BuildRunnerRequireStrategyProvider(
        assetHandler,
        reload,
        assetReader,
        buildSettings,
        packageConfigPath: findPackageConfigFilePath(),
      ).strategy;

      if (enableDebugging) {
        ddcService = ExpressionCompilerService(
          'localhost',
          daemonPort, // TODO: does this work instead of 'options.port'?
          verbose: false,
          sdkConfigurationProvider: const DefaultSdkConfigurationProvider(),
        );
      }

      final debugSettings = DebugSettings(
        enableDebugExtension: enableDebugging,
        enableDebugging: enableDebugging,
        spawnDds: true,
        expressionCompiler: ddcService,
        devToolsLauncher: enableDebugging
            ? (String hostname) async {
                final server = await DevToolsServer().serveDevTools(
                  hostname: hostname,
                  enableStdinCommands: false,
                  customDevToolsPath: dartDevToolsPath,
                );
                return DevTools(server!.address.host, server.port, server);
              }
            : null,
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
        injectDebuggingSupportCode: enableDebugging,
      );
      pipeline = pipeline.addMiddleware(dwds.middleware);
      cascade = cascade.add(dwds.handler);
      cascade = cascade.add(assetHandler);
    } else {
      cascade = cascade.add(assetHandler);
    }

    return DevProxy._(
      client,
      pipeline.addHandler(cascade.handler),
      filteredBuildResults,
      autoRun,
      dwds: dwds,
      ddcService: ddcService,
    );
  }

  Future<void> stop() async {
    client.close();
    await dwds?.stop();
    await ddcService?.stop();
  }
}
