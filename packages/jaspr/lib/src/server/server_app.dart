library server;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:hotreloader/hotreloader.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_gzip/shelf_gzip.dart';
import 'package:shelf_proxy/shelf_proxy.dart';
import 'package:shelf_static/shelf_static.dart';

import '../bindings/server_bindings.dart';
import '../framework/framework.dart';
import 'document.dart';

part 'server_renderer.dart';

const kServerDebugMode = bool.fromEnvironment('jaspr.debug');
const kServerHotReload = bool.fromEnvironment('jaspr.hotreload');

/// Returns a shelf handler that serves the provided component and related assets
Handler serveApp(AppHandler handler) {
  return _createHandler((request, render) {
    return handler(request, (app) {
      return render(_createSetup(app));
    });
  });
}

/// Directly renders the provided component into a html response
Future<Response> renderComponent(Component app) async {
  return _renderApp(_createSetup(app), Request('get', Uri.parse('https://0.0.0.0/')), (name) async {
    var response = await staticFileHandler(Request('get', Uri.parse('https://0.0.0.0/$name')));
    return response.readAsString();
  });
}

typedef RenderFunction = FutureOr<Response> Function(Component);
typedef AppHandler = FutureOr<Response> Function(Request, RenderFunction render);

SetupFunction _createSetup(Component app) {
  return () => AppBinding.ensureInitialized().attachRootComponent(app, attachTo: '_');
}

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

  // The server origin. Must be set when the server was started, before the first incoming request
  String? origin;

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

      var handler = _createHandler((_, render) => render(_setup), middleware: _middleware, fileHandler: _fileHandler);

      if (kServerHotReload) {
        await _reload(this, () => _createServer(this, handler));
      } else {
        _server = await _createServer(this, handler);
        _listener?.call(_server!);
      }

      print('[INFO] Running app in ${kServerDebugMode ? 'debug' : 'release'} mode');
      print('[INFO] Serving at http://${server!.address.host}:${server!.port}');
    });
  }

  Future<void> close() async {
    await _server?.close();
    await _reloader?.stop();
  }
}

FutureOr<Response> Function(Request, String) _proxyFileLoader(Handler proxyHandler) {
  return (Request req, String fileName) {
    final indexRequest = Request('GET', req.requestedUri.replace(path: '/$fileName'),
        context: req.context, encoding: req.encoding, headers: req.headers, protocolVersion: req.protocolVersion);
    return proxyHandler(indexRequest);
  };
}

// coverage:ignore-start

Handler _webdevProxyHandler(String port) {
  var handler = proxyHandler('http://localhost:$port/');
  return (Request req) async {
    var res = await handler(req);
    if (res.statusCode == 200 && res.headers['content-type'] == 'application/javascript') {
      var body = await res.readAsString();
      res = res.change(body: body.replaceAll('http://localhost:$port/', ''));
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

Handler _sseProxyHandler(Uri proxyUri, Uri serverUri) {
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
    var path = req.url.path;
    if (!path.startsWith('/')) path = '/$path';
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

final portToProxy = Platform.environment['JASPR_PROXY_PORT'];

final staticFileHandler = kServerDebugMode
    ? _webdevProxyHandler(portToProxy ?? '5467')
    : createStaticHandler(join(dirname(Platform.script.path), 'web'), defaultDocument: 'index.html');

typedef _SetupHandler = FutureOr<Response> Function(Request, FutureOr<Response> Function(SetupFunction setup));

Handler _createHandler(_SetupHandler handle, {List<Middleware> middleware = const [], Handler? fileHandler}) {
  var portToProxy = Platform.environment['JASPR_PROXY_PORT'];

  var staticHandler = fileHandler ?? staticFileHandler;

  var cascade = Cascade();

  if (kServerDebugMode) {
    final serverUri = Uri.parse('http://localhost:$portToProxy');
    final serverSseUri = serverUri.replace(path: r'/$dwdsSseHandler');
    final sseUri = Uri.parse(r'/$dwdsSseHandler');

    cascade = cascade.add(_sseProxyHandler(sseUri, serverSseUri));
  }

  var fileLoader = _proxyFileLoader(staticHandler);
  cascade = cascade.add(gzipMiddleware(staticHandler)).add((request) async {
    return handle(request, (setup) => _renderApp(setup, request, (name) async {
      var response = await fileLoader(request, name);
      return response.readAsString();
    }));
  });

  var pipeline = const Pipeline();
  for (var m in middleware) {
    pipeline = pipeline.addMiddleware(m);
  }

  return pipeline.addHandler(cascade.handler);
}

/// Creates and runs the http server
Future<HttpServer> _createServer(ServerApp app, Handler handler) async {
  if (app._builder != null) {
    return app._builder!.call(handler);
  } else {
    var port = int.parse(Platform.environment['PORT'] ?? '8080');
    return shelf_io.serve(handler, InternetAddress.anyIPv4, port, shared: true);
  }
}
