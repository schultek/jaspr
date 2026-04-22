import 'dart:convert';
import 'dart:io';

import 'package:build_daemon/data/build_status.dart' as daemon;
import 'package:dwds/data/build_result.dart';
import 'package:dwds/dwds.dart';
import 'package:dwds/src/loaders/build_runner_strategy_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
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
    int proxyPort,
    Stream<daemon.BuildResults> buildResults, {
    bool enableDebugging = false,
    bool enableInjectedClient = true,
    ReloadConfiguration reload = ReloadConfiguration.hotRestart,
    String moduleFormat = 'amd',
    bool webHotReload = false,
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
    if (enableInjectedClient) {
      final assetReader = ProxyServerAssetReader(
        daemonPort,
        root: target,
      );

      final buildSettings = BuildSettings(
        //appEntrypoint: Uri.parse('org-dartlang-app:///$target/main.dart'),
        canaryFeatures: moduleFormat == 'ddc' || webHotReload,
        isFlutterApp: false,
        experiments: [],
      );

      final reloadedSourcesUri = Uri.parse('/reloaded_sources.json');

      final loadStrategy = moduleFormat == 'ddc'
          ? BuildRunnerDdcLibraryBundleStrategyProvider(
              reload,
              assetReader,
              buildSettings,
              packageConfigPath: findPackageConfigFilePath(),
              reloadedSourcesUri: reloadedSourcesUri,
            ).strategy
          : BuildRunnerRequireStrategyProvider(
              reload,
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
      );
      
      if (moduleFormat == 'ddc') {
        pipeline = pipeline.addMiddleware((Handler innerHandler) {
          return (Request req) async {
            if (req.url.path == 'reloaded_sources.json' || req.requestedUri.path == '/reloaded_sources.json') {
              return Response.ok(jsonEncode(reloadedSources), headers: {'content-type': 'application/json'});
            }
            return innerHandler(req);
          };
        });
      }
      
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
      !enableDebugging,
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
  final jsPath = uri.isScheme('package')
      ? 'package:${uri.path}'
      : 'org-dartlang-app:///${uri.path}';
  final prefix = jsPath.substring(
    0,
    jsPath.length - '.ddc.js'.length,
  );
  return '$prefix.dart';
}
