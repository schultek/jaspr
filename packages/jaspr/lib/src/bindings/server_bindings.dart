import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:domino/markup.dart' hide DomComponent, DomElement;
import 'package:hotreloader/hotreloader.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_gzip/shelf_gzip.dart';
import 'package:shelf_proxy/shelf_proxy.dart';
import 'package:shelf_static/shelf_static.dart';

import '../foundation/binding.dart';
import '../foundation/scheduler.dart';
import '../foundation/sync.dart';
import '../framework/framework.dart';

const jasprDebugMode = bool.fromEnvironment('jaspr.debug');
const jasprHotreload = bool.fromEnvironment('jaspr.hotreload');

/// Main entry point on the server
void runApp(Component app, {String attachTo = 'body'}) {
  runServer(app, attachTo: attachTo);
}

/// Same as [runApp] but returns an instance of [ServerApp] to control aspects of the http server
ServerApp runServer(Component app, {String attachTo = 'body'}) {
  return ServerApp.run(() {
    AppBinding.ensureInitialized().attachRootComponent(app, attachTo: attachTo);
  });
}

typedef SetupFunction = void Function();

/// An object to be returned from runApp on the server and provide access to the internal http server
class ServerApp {
  ServerApp._(this._setup, [this._fileHandler]);

  factory ServerApp.run(SetupFunction setup, [Handler? fileHandler]) {
    return ServerApp._(setup, fileHandler).._run();
  }

  final SetupFunction _setup;

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

      var portToProxy = Platform.environment['JASPR_PROXY_PORT'];

      var fileHandler = _fileHandler ??
          (jasprDebugMode
              ? webdevProxyHandler('http://localhost:$portToProxy/', this)
              : createStaticHandler(join(dirname(Platform.script.path), 'web'), defaultDocument: 'index.html'));

      var cascade = Cascade();

      if (jasprDebugMode) {
        final serverHostname = 'localhost';
        final serverUri = Uri.parse('http://$serverHostname:$portToProxy');
        final serverSseUri = serverUri.replace(path: r'/$dwdsSseHandler');
        final sseUri = Uri.parse(r'/$dwdsSseHandler');

        cascade = cascade.add(sseProxyHandler(sseUri, serverSseUri));
      }

      cascade = cascade.add(gzipMiddleware(fileHandler)).add(proxyRootIndexHandler(fileHandler));

      if (jasprHotreload) {
        await _reload(this, () => _createServer(this, cascade.handler));
      } else {
        _server = await _createServer(this, cascade.handler);
        _listener?.call(_server!);
      }

      print('[INFO] Running app in ${jasprDebugMode ? 'debug' : 'release'} mode');
      print('[INFO] Serving at http://${server!.address.host}:${server!.port}');
    });
  }

  Future<void> close() async {
    await _server?.close();
    await _reloader?.stop();
  }
}

Handler proxyRootIndexHandler(Handler proxyHandler) {
  return (Request req) {
    final indexRequest = Request('GET', req.requestedUri.replace(path: '/'),
        context: req.context, encoding: req.encoding, headers: req.headers, protocolVersion: req.protocolVersion);
    return proxyHandler(indexRequest);
  };
}

// coverage:ignore-start

Handler webdevProxyHandler(String url, ServerApp app) {
  var handler = proxyHandler(url);
  return (Request req) async {
    var res = await handler(req);
    if (res.statusCode == 200 && app.server != null && res.headers['content-type'] == 'application/javascript') {
      var body = await res.readAsString();
      res = res.change(body: body.replaceAll('localhost:5467', '${app.server!.address.host}:${app.server!.port}'));
    }
    return res;
  };
}

String _sseHeaders(String? origin) => 'HTTP/1.1 200 OK\r\n'
    'Content-Type: text/event-stream\r\n'
    'Cache-Control: no-cache\r\n'
    'Connection: keep-alive\r\n'
    'Access-Control-Allow-Credentials: true\r\n'
    'Access-Control-Allow-Origin: $origin\r\n'
    '\r\n';

Handler sseProxyHandler(Uri proxyUri, Uri serverUri) {
  Handler? _incomingMessageProxyHandler;
  var _httpClient = http.Client();

  Future<Response> _createSseConnection(Request req, String path) async {
    final serverReq = http.StreamedRequest(req.method, serverUri.replace(query: req.requestedUri.query))
      ..followRedirects = false
      ..headers.addAll(req.headers)
      ..headers['Host'] = serverUri.authority
      ..sink.close();

    final serverResponse = await _httpClient.send(serverReq);

    req.hijack((channel) {
      final sink = utf8.encoder.startChunkedConversion(channel.sink)..add(_sseHeaders(req.headers['origin']));

      StreamSubscription? serverSseSub;
      StreamSubscription? reqChannelSub;

      serverSseSub = utf8.decoder.bind(serverResponse.stream).listen(sink.add, onDone: () {
        reqChannelSub?.cancel();
        sink.close();
      });

      reqChannelSub = channel.stream.listen((_) {
        // SSE is unidirectional.
      }, onDone: () {
        serverSseSub?.cancel();
        sink.close();
      });
    });
  }

  Future<Response> _handleIncomingMessage(Request req) async {
    _incomingMessageProxyHandler ??= proxyHandler(
      serverUri,
      client: _httpClient,
    );
    return _incomingMessageProxyHandler!(req);
  }

  return (Request req) async {
    final path = req.requestedUri.path;
    if (path != proxyUri.path) {
      return Response.notFound('');
    }

    if (req.headers['accept'] == 'text/event-stream' && req.method == 'GET') {
      return _createSseConnection(req, path);
    }

    if (req.headers['accept'] != 'text/event-stream' && req.method == 'POST') {
      return _handleIncomingMessage(req);
    }

    return Response.notFound('');
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

// coverage:ignore-end

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

    if (request.url.path.endsWith('.dart') ||
        request.url.path.endsWith('.js.map') ||
        request.url.path.endsWith('.js')) {
      return Response.internalServerError(body: 'Cannot handle request');
    }

    return renderApp(app, request, fileResponse);
  });

  if (app._builder != null) {
    return app._builder!.call(handler);
  } else {
    var port = int.parse(Platform.environment['PORT'] ?? '8080');
    return shelf_io.serve(handler, InternetAddress.anyIPv4, port, shared: true);
  }
}

/// This spawns an isolate for each render, in order to avoid conflicts with static instances and multiple parallel requests
Future<Response> renderApp(ServerApp app, Request request, Response fileResponse) async {
  var port = ReceivePort();

  /// We support two modes here, rendered-html and data-only
  /// rendered-html does normal ssr, but data-only only returns the preloaded state data as json
  if (request.headers['jaspr-mode'] == 'data-only') {
    var message = RenderMessage(app._setup, request.requestedUri, port.sendPort);

    await Isolate.spawn(renderData, message);
    var result = await port.first;

    return Response.ok(result, headers: {'Content-Type': 'application/json'});
  } else {
    var indexHtml = await fileResponse.readAsString();
    var message = HtmlRenderMessage(app._setup, request.requestedUri, port.sendPort, indexHtml);

    await Isolate.spawn(renderHtml, message);
    var result = await port.first;

    return Response.ok(result, headers: {'Content-Type': 'text/html'});
  }
}

class RenderMessage {
  SetupFunction setup;
  Uri requestUri;
  SendPort sendPort;

  RenderMessage(this.setup, this.requestUri, this.sendPort);
}

class HtmlRenderMessage extends RenderMessage {
  String html;

  HtmlRenderMessage(SetupFunction setup, Uri requestUri, SendPort sendPort, this.html)
      : super(setup, requestUri, sendPort);
}

/// Runs the app and returns the rendered html
void renderHtml(HtmlRenderMessage message) async {
  AppBinding._requestUri = message.requestUri;
  message.setup();
  var html = await AppBinding.ensureInitialized().render(message.html);
  message.sendPort.send(html);
}

/// Runs the app and returns the preloaded state data as json
void renderData(RenderMessage message) async {
  AppBinding._requestUri = message.requestUri;
  message.setup();
  var data = await AppBinding.ensureInitialized().data();
  message.sendPort.send(data);
}

/// Global component binding for the server
class AppBinding extends BindingBase with ComponentsBinding, SyncBinding, SchedulerBinding {
  static AppBinding ensureInitialized() {
    if (ComponentsBinding.instance == null) {
      AppBinding();
    }
    return ComponentsBinding.instance! as AppBinding;
  }

  static late Uri _requestUri;
  @override
  Uri get currentUri => _requestUri;

  String? _targetId;

  @override
  bool get isClient => false;

  final rootCompleter = Completer.sync();

  @override
  void didAttachRootElement(BuildScheduler element, {required String to}) {
    _targetId = to;
    rootCompleter.complete();
  }

  Future<String> render(String rawHtml) async {
    await rootCompleter.future;

    var document = parse(rawHtml);
    var appElement = document.querySelector(_targetId!)!;
    appElement.innerHtml = renderMarkup(builderFn: rootElement!.render);

    document.body!.attributes['state-data'] = stateCodec.encode(getStateData());
    return document.outerHtml;
  }

  Future<String> data() async {
    await rootCompleter.future;
    return jsonEncode(getStateData());
  }

  @override
  dynamic getRawState(String id) => null;

  @override
  Future<Map<String, String>> fetchState(String url) {
    throw 'Cannot fetch state on the server';
  }

  @override
  void updateRawState(String id, dynamic state) {}

  @override
  DomView registerView(dynamic root, DomBuilderFn builderFn, bool initialRender) {
    return NullDomView();
  }

  @override
  void scheduleBuild() {
    throw UnsupportedError('Scheduling a build is not supported on the server, and should never happen.');
  }
}

class NullDomView implements DomView {
  @override
  Future<void>? dispose() => null;

  @override
  Future<void>? invalidate() => null;

  @override
  void update() {}
}
