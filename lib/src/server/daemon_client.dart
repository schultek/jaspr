import 'dart:io';

import 'package:build_daemon/client.dart';
import 'package:build_daemon/data/build_status.dart' as daemon;
import 'package:build_daemon/data/build_target.dart';
import 'package:build_daemon/data/server_log.dart';
import 'package:dwds/data/build_result.dart';
import 'package:dwds/dwds.dart';
import 'package:http/io_client.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_proxy/shelf_proxy.dart';
import 'package:webdev/src/daemon_client.dart' as webdev;
import 'package:webdev/src/logging.dart';
import 'package:webdev/src/serve/chrome.dart';
import 'package:webdev/src/util.dart';

Future<Handler> runDaemon() async {
  configureLogWriter(false);

  print(Directory.current.path);
  var client = await BuildDaemonClient.connect(
    Directory.current.path,
    [dartPath, 'run', 'build_runner', 'daemon'],
    logHandler: (serverLog) {
      logWriter(toLoggingLevel(serverLog.level), serverLog.message,
          loggerName: serverLog.loggerName,
          error: serverLog.error,
          stackTrace: serverLog.stackTrace);
    },
  );

  client.registerBuildTarget(DefaultBuildTarget((b) => b..target = ''));

  client.startBuild();

  var pipeline = const Pipeline();

  var daemonPort = webdev.daemonPort(Directory.current.path);

  var cascade = Cascade();
  var clientio = IOClient(HttpClient()
    ..maxConnectionsPerHost = 200
    ..idleTimeout = const Duration(seconds: 30)
    ..connectionTimeout = const Duration(seconds: 30));
  var assetHandler =
      proxyHandler('http://localhost:$daemonPort/web/', client: clientio);

  var filteredBuildResults =
      client.buildResults.asyncMap<BuildResult>((results) {
    var result = results.results.firstWhere((result) => result.target == '');
    switch (result.status) {
      case daemon.BuildStatus.started:
        return BuildResult((b) => b.status = BuildStatus.started);
      case daemon.BuildStatus.failed:
        return BuildResult((b) => b.status = BuildStatus.failed);
      case daemon.BuildStatus.succeeded:
        return BuildResult((b) => b.status = BuildStatus.succeeded);
    }
    throw StateError('Unexpected Daemon build result: $result');
  });

  var assetReader = ProxyServerAssetReader(
    daemonPort,
    root: 'web',
  );

  var loadStrategy = BuildRunnerRequireStrategyProvider(
          assetHandler, ReloadConfiguration.hotRestart, assetReader)
      .strategy;

  Dwds dwds = await Dwds.start(
    hostname: 'localhost',
    assetReader: assetReader,
    buildResults: filteredBuildResults,
    chromeConnection: () async =>
        (await Chrome.connectedInstance).chromeConnection,
    loadStrategy: loadStrategy,
    enableDebugExtension: false,
    enableDebugging: false,
    spawnDds: true,
    expressionCompiler: null,
    devtoolsLauncher: null,
  );
  pipeline = pipeline.addMiddleware(dwds.middleware);
  cascade = cascade.add(dwds.handler);
  cascade = cascade.add(assetHandler);

  dwds.connectedApps?.listen((connection) {
    connection.runMain();
  });

  return pipeline.addHandler(cascade.handler);
}
