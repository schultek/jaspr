import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:domino/markup.dart' hide DomComponent;
import 'package:hotreloader/hotreloader.dart';
import 'package:html/parser.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_proxy/shelf_proxy.dart';
import 'package:shelf_static/shelf_static.dart';

import 'framework/framework.dart';

typedef SetupFunction = Component Function();

Future<ServerApp> runApp(SetupFunction setup, {required String id}) {
  var mode = Platform.environment['DART_WEB_MODE'];

  if (mode == 'DEBUG') {
    return _runDebugApp(setup, id: id);
  } else {
    return _runReleaseApp(setup, id: id);
  }
}

Future<ServerApp> _runDebugApp(SetupFunction setup, {required String id}) async {
  var handler = proxyHandler('http://localhost:${Platform.environment['DART_WEB_PROXY_PORT']}/');
  var serverApp = await _reload(() => _createServer(setup, catchAll(handler), id: id));
  print('[INFO] Running app in debug mode');
  print('[INFO] Serving at http://${serverApp.server.address.host}:${serverApp.server.port}');
  return serverApp;
}

Future<ServerApp> _runReleaseApp(SetupFunction setup, {required String id}) async {
  var handler = createStaticHandler('web', defaultDocument: 'index.html');
  var server = await _createServer(setup, catchAll(handler), id: id);
  print('[INFO] Running app in release mode');
  print('[INFO] Serving at http://${server.address.host}:${server.port}');
  return ServerApp(server);
}

Future<Response> Function(Request) catchAll(FutureOr<Response> Function(Request) handler) {
  return (Request req) async {
    var res = await handler(req);
    if (res.statusCode == 404 && req.method == 'GET') {
      res = await handler(Request(req.method, req.requestedUri.replace(path: '/')));
    }
    return res;
  };
}

class ServerApp {
  ServerApp(this._server);

  HttpServer _server;
  HttpServer get server => _server;
}

Future<ServerApp> _reload(FutureOr<HttpServer> Function() init) async {
  var app = ServerApp(await init());

  // ignore: prefer_function_declarations_over_variables
  var obtainNewServer = (FutureOr<HttpServer> Function() initializer) async {
    await app.server.close(force: true);
    print('[INFO] Application reloaded.');
    app._server = await initializer();
  };

  try {
    await HotReloader.create(
      debounceInterval: Duration.zero,
      onAfterReload: (ctx) => obtainNewServer(init),
    );
    print('[INFO] Hot reload is enabled.');
  } on StateError catch (e) {
    if (e.message.contains('VM service not available')) {
      print('[INFO] Hot reload not enabled. Run with --enable-vm-service to enable hot reload.');
    } else {
      rethrow;
    }
  }

  return app;
}

Future<HttpServer> _createServer(SetupFunction setup, Handler fileHandler, {required String id}) async {
  var handler = const Pipeline().addHandler((Request request) async {
    var fileResponse = await fileHandler(request);

    if (fileResponse.headers['content-type'] != 'text/html') {
      return fileResponse;
    }

    return renderApp(request, setup, id, fileResponse);
  });

  var server = await shelf_io.serve(handler, 'localhost', 8080);

  return server;
}

class HtmlRenderMessage extends RenderMessage {
  String html;

  HtmlRenderMessage(SetupFunction setup, Uri requestUri, String id, SendPort sendPort, this.html)
      : super(setup, requestUri, id, sendPort);
}

class RenderMessage {
  String id;
  SetupFunction setup;
  Uri requestUri;
  SendPort sendPort;

  RenderMessage(this.setup, this.requestUri, this.id, this.sendPort);
}

Future<Response> renderApp(Request request, SetupFunction setup, String id, Response fileResponse) async {
  var port = ReceivePort();

  if (request.headers['dart-web-mode'] == 'data-only') {
    var message = RenderMessage(setup, request.requestedUri, id, port.sendPort);

    await Isolate.spawn(renderData, message);
    var result = await port.first;

    return Response.ok(result, headers: {'Content-Type': 'application/json'});
  } else {
    var indexHtml = await fileResponse.readAsString();
    var message = HtmlRenderMessage(setup, request.requestedUri, id, port.sendPort, indexHtml);

    await Isolate.spawn(renderHtml, message);
    var result = await port.first;

    return Response.ok(result, headers: {'Content-Type': 'text/html'});
  }
}

void renderHtml(HtmlRenderMessage message) async {
  var app = message.setup();
  var binding = ServerAppBinding(message.requestUri)..attachRootComponent(app, to: message.id);
  message.sendPort.send(await binding.render(message.html));
}

void renderData(RenderMessage message) async {
  var app = message.setup();
  var binding = ServerAppBinding(message.requestUri)..attachRootComponent(app, to: message.id);
  message.sendPort.send(await binding.data());
}

class ServerAppBinding extends AppBinding {
  ServerAppBinding(this.currentUri);

  @override
  final Uri currentUri;

  BuildScheduler? _element;
  String? _targetId;

  @override
  void attachRootElement(BuildScheduler element, {required String to}) {
    _element = element;
    _targetId = to;
  }

  Future<String> render(String rawHtml) async {
    await firstBuild;

    var document = parse(rawHtml);
    var appElement = document.getElementById(_targetId!)!;
    appElement.innerHtml = renderMarkup(builderFn: _element!.render);

    document.body!.attributes['data-app'] = jsonEncode(getStateData());

    return document.outerHtml;
  }

  Future<String> data() async {
    await firstBuild;
    return jsonEncode(getStateData());
  }

  @override
  FutureOr<void> performRebuild(Element? child) {
    if (child is StatefulElement && child.state is PreloadStateMixin) {
      return Future.sync(() async {
        await (child.state as PreloadStateMixin).preload;
        return super.performRebuild(child);
      });
    } else {
      return super.performRebuild(child);
    }
  }
}
