import 'dart:io';

import 'package:build_daemon/data/build_status.dart' as daemon;
import 'package:dwds/data/build_result.dart';
import 'package:dwds/dwds.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart';
import 'package:shelf_proxy/shelf_proxy.dart';

import '../project.dart';
import 'chrome.dart';
import 'util.dart';

typedef PreReloadCallback = Future<void> Function(BuildResult result);

/// Forwards build results, holding back a successful one until every callback
/// in [callbacks] completed.
@visibleForTesting
Stream<BuildResult> gateBuildResults(Stream<BuildResult> results, List<PreReloadCallback> callbacks) {
  return results.asyncMap((result) async {
    if (result.status == BuildStatus.succeeded) {
      for (final callback in callbacks) {
        await callback(result);
      }
    }
    return result;
  });
}

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
    bool autoRun,
    this._preReloadCallbacks, {
    this.dwds,
    this.ddcService,
  }) {
    if (autoRun) {
      dwds?.connectedApps.listen((connection) {
        connection.runMain();
      });
    }
  }

  final List<PreReloadCallback> _preReloadCallbacks;

  /// Registers a callback to run before a successful build reaches the client.
  ///
  /// Callbacks registered here get to finish first, so files generated from the
  /// build output are on disk before the browser reloads.
  void registerPreReloadCallback(PreReloadCallback callback) {
    _preReloadCallbacks.add(callback);
  }

  void unregisterPreReloadCallback(PreReloadCallback callback) {
    _preReloadCallbacks.remove(callback);
  }

  static Future<DevProxy> start(
    int daemonPort,
    int proxyPort,
    Stream<daemon.BuildResults> buildResults, {
    bool enableDebugging = false,
    bool enableInjectedClient = true,
    ReloadConfiguration reload = ReloadConfiguration.hotRestart,
  }) async {
    const target = 'web';
    var pipeline = const Pipeline();

    // Only provide relevant build results
    final filteredBuildResults = buildResults.asyncMap<BuildResult>((results) {
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
    });

    // Anything registered here writes files from the build output, so the
    // result is only passed on once those are done and the client reloads
    // against the assets that belong to the build it is reloading for.
    final preReloadCallbacks = <PreReloadCallback>[];
    final gatedBuildResults = gateBuildResults(filteredBuildResults, preReloadCallbacks);

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
        canaryFeatures: false,
        isFlutterApp: false,
        experiments: [],
      );

      final loadStrategy = BuildRunnerRequireStrategyProvider(
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
        buildResults: gatedBuildResults,
        chromeConnection: () async => (await Chrome.connectedInstance).chrome.chromeConnection,
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
      gatedBuildResults,
      !enableDebugging,
      preReloadCallbacks,
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
