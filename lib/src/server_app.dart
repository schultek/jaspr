import 'dart:async';
import 'dart:io';

import 'package:domino/markup.dart' hide DomComponent;
import 'package:hotreloader/hotreloader.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_proxy/shelf_proxy.dart';
import 'package:shelf_static/shelf_static.dart';

import 'core/core.dart';
import 'web_app.dart';

class ServerWebApp extends WebApp {
  ServerWebApp(this._server);

  HttpServer _server;
  HttpServer get server => _server;
}

Future<ServerWebApp> runApp(Component app, {required String id}) {
  var mode = Platform.environment['DART_WEB_MODE'];

  if (mode == 'DEBUG') {
    return _runDebugApp(app, id: id);
  } else {
    return _runReleaseApp(app, id: id);
  }
}

Future<ServerWebApp> _runDebugApp(Component app, {required String id}) async {
  var handler = proxyHandler(
      'http://localhost:${Platform.environment['DART_WEB_PROXY_PORT']}/');

  var serverApp = await _reload(() => _createServer(app, handler, id: id));
  print('[INFO] Running app in debug mode');
  print(
      '[INFO] Serving at http://${serverApp.server.address.host}:${serverApp.server.port}');
  return serverApp;
}

Future<ServerWebApp> _runReleaseApp(Component app, {required String id}) async {
  var handler = createStaticHandler('web', defaultDocument: 'index.html');
  var server = await _createServer(app, handler, id: id);
  print('[INFO] Running app in release mode');
  print('[INFO] Serving at http://${server.address.host}:${server.port}');
  return ServerWebApp(server);
}

Future<ServerWebApp> _reload(FutureOr<HttpServer> Function() init) async {
  ServerWebApp? app;
  HttpServer? runningServer;

  // ignore: prefer_function_declarations_over_variables
  var obtainNewServer = (FutureOr<HttpServer> Function() initializer) async {
    var willReplaceServer = runningServer != null;
    await runningServer?.close(force: true);
    if (willReplaceServer) {
      print('[INFO] Application reloaded.');
    }
    runningServer = await initializer();
    if (app == null) {
      app = ServerWebApp(runningServer!);
    } else {
      app!._server = runningServer!;
    }
  };

  try {
    await HotReloader.create(
      debounceInterval: Duration.zero,
      onAfterReload: (ctx) => obtainNewServer(init),
    );
    print('[INFO] Hot reload is enabled.');
  } on StateError catch (e) {
    if (e.message.contains('VM service not available')) {
      print(
          '[INFO] Hot reload not enabled. Run this app with --enable-vm-service (or use debug run) in order to enable hot reload.');
    } else {
      rethrow;
    }
  }

  await obtainNewServer(init);
  return app!;
}

Future<HttpServer> _createServer(Component app, Handler fileHandler,
    {required String id}) async {
  var handler = const Pipeline().addHandler((Request request) async {
    var fileResponse = await fileHandler(request);

    if (fileResponse.headers['content-type'] != 'text/html') {
      return fileResponse;
    }

    var indexHtml = await fileResponse.readAsString();

    var root = StateStore(child: DomComponent(tag: 'div', id: id, child: app));

    var rootElement = root.createElement();

    await rootElement.mount(null);
    await rootElement.rebuild();

    var appHtml = renderMarkup(builderFn: rootElement.render);

    var data = root.write().replaceAll('"', '&quot;');

    return Response.ok(
      indexHtml
          .replaceFirst('<body>', '<body data-app="$data">')
          .replaceFirst('<div id="$id"></div>', appHtml),
      headers: {'Content-Type': 'text/html'},
    );
  });

  var server = await shelf_io.serve(handler, 'localhost', 8080);

  return server;
}
