import 'dart:async';
import 'dart:io';

import 'package:build_daemon/data/server_log.dart';
import 'package:domino/markup.dart' hide DomComponent;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_hotreload/shelf_hotreload.dart';
import 'package:webdev/src/logging.dart';

import '../../dart_web.dart';
import '../web_app.dart';
import 'daemon_client.dart';

export 'package:shelf_hotreload/shelf_hotreload.dart';

export '../../dart_web.dart';

class ServerWebApp extends WebApp {
  ServerWebApp(this.server);

  final HttpServer server;
}

void runApp(Component app, {required String id}) async {
  var handler = await runDaemon();
  withHotreload(() => _createServer(app, handler, id: id));
}

Future<HttpServer> _createServer(Component app, Handler fileHandler,
    {required String id}) async {
  var indexFile = File('web/index.html');

  var handler = const Pipeline().addHandler((Request request) async {
    var fileResponse = await fileHandler(request);

    if (fileResponse.headers['content-type'] != 'text/html') {
      return fileResponse;
    }

    var indexHtml = indexFile.readAsStringSync();

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

  var server = await shelf_io.serve(handler, 'localhost', 8081);
  logWriter(toLoggingLevel(Level.INFO),
      'Serving at http://${server.address.host}:${server.port}');

  return server;
}
