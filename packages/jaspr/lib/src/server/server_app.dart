import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:hotreloader/hotreloader.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_gzip/shelf_gzip.dart';
import 'package:shelf_proxy/shelf_proxy.dart';
import 'package:shelf_static/shelf_static.dart';

import '../../server.dart';
import 'server_handler.dart';
import 'server_renderer.dart';

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

      var handler = createHandler((_, render) => render(_setup), middleware: _middleware, fileHandler: _fileHandler);

      if (kDevHotreload) {
        await _reload(this, () {
          if (handler is RefreshableHandler) {
            (handler as RefreshableHandler).refresh();
          }
          return _createServer(this, handler);
        });
      } else {
        _server = await _createServer(this, handler);
        _listener?.call(_server!);
      }

      print('[INFO] Running app in ${kDebugMode ? 'debug' : 'release'} mode');
      print('[INFO] Serving at http://${server!.address.host}:${server!.port}');
    });
  }

  Future<void> close() async {
    await _server?.close();
    await _reloader?.stop();
  }
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
Future<HttpServer> _createServer(ServerApp app, Handler handler) async {
  if (app._builder != null) {
    return app._builder!.call(handler);
  } else {
    var port = int.parse(Platform.environment['PORT'] ?? '8080');
    return shelf_io.serve(handler, InternetAddress.anyIPv4, port, shared: true);
  }
}
