import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:domino/markup.dart' hide DomComponent, DomElement;
import 'package:hotreloader/hotreloader.dart';
import 'package:html/parser.dart';
import 'package:path/path.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_proxy/shelf_proxy.dart';
import 'package:shelf_static/shelf_static.dart';

import '../framework/framework.dart';

typedef SetupFunction = Component Function();

/// Main entry point on the server
ServerApp runApp(SetupFunction setup, {required String id}) {
  return ServerApp.start(setup, id);
}

/// An object to be returned from runApp on the server and provide access to the internal http server
class ServerApp {
  ServerApp._(this._setup, this.id, [this._fileHandler, this._debugMode]);

  factory ServerApp.start(SetupFunction setup, String id, [Handler? fileHandler, bool? debugMode]) {
    return ServerApp._(setup, id, fileHandler, debugMode).._run();
  }

  final String id;
  final SetupFunction _setup;

  final bool? _debugMode;
  final Handler? _fileHandler;

  HotReloader? _reloader;

  HttpServer? _server;
  HttpServer? get server => _server;

  bool _running = false;

  final List<Middleware> _middleware = [];

  /// Adds a custom shelf middleware to the server
  void addMiddleware(Middleware middleware) {
    if (_running) throw 'Cannot attach middleware. Server is already running.';
    _middleware.add(middleware);
  }

  Function(HttpServer server)? _listener;

  /// Registers a listener to be called after the server has started.
  /// Might be called multiple times when using hot reload.
  void setListener(Function(HttpServer server) listener) {
    if (_running) throw 'Cannot attach listener. Server is already running.';
    _listener = listener;
  }

  Future<HttpServer> Function(Handler)? _builder;

  /// Registers a custom function to spin up a http server,
  /// which will be used instead of the default server.
  void setBuilder(Future<HttpServer> Function(Handler) builder) {
    if (_running) throw 'Cannot attach builder. Server is already running.';
    _builder = builder;
  }

  void _run() {
    Future.microtask(() async {
      _running = true;

      var isDebug = _debugMode ?? Platform.environment['JASPR_MODE'] == 'DEBUG';

      var fileHandler = _fileHandler ??
          (isDebug
              ? proxyHandler('http://localhost:${Platform.environment['JASPR_PROXY_PORT']}/')
              : createStaticHandler(join(dirname(Platform.script.path), 'web'), defaultDocument: 'index.html'));

      if (isDebug) {
        await _reload(this, () => _createServer(this, catchAll(fileHandler)));
      } else {
        _server = await _createServer(this, catchAll(fileHandler));
        _listener?.call(_server!);
      }

      print('[INFO] Running app in ${isDebug ? 'debug' : 'release'} mode');
      print('[INFO] Serving at http://${server!.address.host}:${server!.port}');
    });
  }

  Future<void> close() async {
    await _server?.close();
    await _reloader?.stop();
  }
}

/// Redirects all unhandled urls to the base url
Future<Response> Function(Request) catchAll(FutureOr<Response> Function(Request) handler) {
  return (Request req) async {
    var res = await handler(req);
    if (res.statusCode == 404 && req.method == 'GET') {
      res = await handler(Request(req.method, req.requestedUri.replace(path: '/')));
    }
    return res;
  };
}

/// Wraps the http server creation and enables hotreload
/// Modified from package:shelf_hotreload
Future<void> _reload(ServerApp app, FutureOr<HttpServer> Function() init) async {
  app._server = await init();
  app._listener?.call(app._server!);

  // ignore: prefer_function_declarations_over_variables
  var obtainNewServer = (FutureOr<HttpServer> Function() initializer) async {
    await app.server?.close(force: true);
    print('[INFO] Application reloaded.');
    app._server = await initializer();
    app._listener?.call(app._server!);
  };

  try {
    app._reloader = await HotReloader.create(
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
}

/// Creates and runs the http server
Future<HttpServer> _createServer(ServerApp app, Handler fileHandler) async {
  var pipeline = const Pipeline();
  for (var middleware in app._middleware) {
    pipeline = pipeline.addMiddleware(middleware);
  }
  var handler = pipeline.addHandler((Request request) async {
    var fileResponse = await fileHandler(request);

    if (fileResponse.headers['content-type'] != 'text/html') {
      return fileResponse;
    }

    return renderApp(app, request, fileResponse);
  });

  if (app._builder != null) {
    return app._builder!.call(handler);
  } else {
    var port = int.parse(Platform.environment['PORT'] ?? '8080');
    return shelf_io.serve(handler, InternetAddress.anyIPv4, port);
  }
}

/// This spawns an isolate for each render, in order to avoid conflicts with static instances and multiple parallel requests
Future<Response> renderApp(ServerApp app, Request request, Response fileResponse) async {
  var port = ReceivePort();

  /// We support two modes here, rendered-html and data-only
  /// rendered-html does normal ssr, but data-only only returns the preloaded state data as json
  if (request.headers['dart-web-mode'] == 'data-only') {
    var message = RenderMessage(app._setup, request.requestedUri, app.id, port.sendPort);

    await Isolate.spawn(renderData, message);
    var result = await port.first;

    return Response.ok(result, headers: {'Content-Type': 'application/x-www-form-urlencoded'});
  } else {
    var indexHtml = await fileResponse.readAsString();
    var message = HtmlRenderMessage(app._setup, request.requestedUri, app.id, port.sendPort, indexHtml);

    await Isolate.spawn(renderHtml, message);
    var result = await port.first;

    return Response.ok(result, headers: {'Content-Type': 'text/html'});
  }
}

class RenderMessage {
  String id;
  SetupFunction setup;
  Uri requestUri;
  SendPort sendPort;

  RenderMessage(this.setup, this.requestUri, this.id, this.sendPort);
}

class HtmlRenderMessage extends RenderMessage {
  String html;

  HtmlRenderMessage(SetupFunction setup, Uri requestUri, String id, SendPort sendPort, this.html)
      : super(setup, requestUri, id, sendPort);
}

/// Runs the app and returns the rendered html
void renderHtml(HtmlRenderMessage message) async {
  var app = message.setup();
  var binding = ServerComponentsBinding(message.requestUri)..attachRootComponent(app, to: message.id);
  message.sendPort.send(await binding.render(message.html));
}

/// Runs the app and returns the preloaded state data as json
void renderData(RenderMessage message) async {
  var app = message.setup();
  var binding = ServerComponentsBinding(message.requestUri)..attachRootComponent(app, to: message.id);
  message.sendPort.send(await binding.data());
}

/// Global component binding for the server
class ServerComponentsBinding extends ComponentsBinding {
  ServerComponentsBinding(this.currentUri);

  @override
  final Uri currentUri;

  String? _targetId;

  @override
  bool get isClient => false;

  @override
  void didAttachRootElement(BuildScheduler element, {required String to}) {
    _targetId = to;
  }

  Future<String> render(String rawHtml) async {
    await firstBuild;

    var document = parse(rawHtml);
    var appElement = document.getElementById(_targetId!)!;
    appElement.innerHtml = renderMarkup(builderFn: rootElement!.render);

    for (var entry in getStateData().entries) {
      document.body!.attributes['data-state-${entry.key}'] = entry.value;
    }

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
        await (child.state as PreloadStateMixin).preloadFuture;
        return super.performRebuild(child);
      });
    } else {
      return super.performRebuild(child);
    }
  }

  @override
  String? getRawState(String id) => null;

  @override
  Future<Map<String, String>> fetchState(String url) {
    throw 'Cannot fetch state on the server';
  }

  @override
  void updateRawState(String id, String state) {}
}
