import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import '../../server.dart';
import 'server_handler.dart';

typedef SetupFunction = void Function(ServerAppBinding binding);

/// An object to be returned from [runApp] on the server and
/// provide access to the internal http server.
final class ServerApp {
  static ServerApp? _instance;

  ServerApp._(this._setup);

  factory ServerApp.run(SetupFunction setup) {
    if (_instance case final instance?) {
      instance._reload(setup);
      return instance;
    } else {
      return (_instance = ServerApp._(setup)).._run();
    }
  }

  static final createTestHandler = createHandler;

  static final StreamController<Object> _reassembleController = StreamController.broadcast();
  static Stream<Object> get onReassemble => _reassembleController.stream;

  static final List<Middleware> _middleware = [];

  /// Adds a shelf middleware to the server application.
  ///
  /// This will be applied the next time `runApp` is called.
  static void addMiddleware(Middleware middleware) {
    _middleware.add(middleware);
  }

  SetupFunction _setup;
  Handler? _handler;

  static final http.Client _client = http.Client();
  static HttpServer? _server;

  Future<void> _run() async {
    assert(_server == null);

    _handler = _createHandler();
    final server = await _createServer();
    _server = server;

    if (kGenerateMode) {
      requestRouteGeneration('/');
    }
  }

  void _reload(SetupFunction setup) {
    _setup = setup;
    if (_middleware.isNotEmpty) {
      _handler = _createHandler();
    }
    _reassembleController.add(Object());
    reloadClients();
  }

  Handler _createHandler() {
    var pipeline = const Pipeline();
    for (final middleware in _middleware) {
      pipeline = pipeline.addMiddleware(middleware);
    }
    _middleware.clear();
    return createHandler((_, render) => render(_setup), client: _client);
  }

  Future<HttpServer> _createServer() async {
    final port = int.parse(Platform.environment['PORT'] ?? '8080');
    return await shelf_io.serve(
      (req) => _handler?.call(req) ?? Response(503, headers: {'Retry-After': '1'}),
      InternetAddress.anyIPv4,
      port,
      shared: true,
    );
  }

  static final _requestedRoutes = <String, (String?, String?, double?)>{};

  static Future<void> requestRouteGeneration(
    String route, {
    String? lastMod,
    String? changefreq,
    double? priority,
  }) async {
    if (kGenerateMode) {
      final settings = (lastMod, changefreq, priority);
      if (_requestedRoutes[route] == settings) {
        // Skip if the route is already requested with the same settings.
        return;
      }

      _requestedRoutes[route] = settings;
      await _sendDebugMessage({'route': route, 'lastmod': lastMod, 'changefreq': changefreq, 'priority': priority});
    }
  }

  static Future<void> _sendDebugMessage(Object message) async {
    await _client.post(Uri.http('localhost:$jasprProxyPort', r'$jasprMessageHandler'), body: jsonEncode(message));
  }

  static void reloadClients([String? route]) {
    _sendDebugMessage({'reload': route ?? true});
  }
}
