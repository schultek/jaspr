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
  ServerApp._(this._setup);

  factory ServerApp.run(SetupFunction setup) {
    return ServerApp._(setup).._run();
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

  final SetupFunction _setup;

  static Object? _runLock;
  static HttpServer? _server;
  static http.Client? _client;

  void _run() async {
    final isFirstStartup = _server == null;

    final lock = _runLock = Object();
    final (client, server) = await _createServer();

    if (_runLock != lock) {
      server.close(force: true);
      client.close();
      return;
    }

    _server?.close(force: true);
    _server = server;

    _client?.close();
    _client = client;

    _reassembleController.add(Object());

    if (isFirstStartup) {
      print('[INFO] Running server in ${kDebugMode ? 'debug' : 'release'} mode');
      print('Serving at http://${kDebugMode ? 'localhost' : _server!.address.host}:${_server!.port}');

      if (kGenerateMode) {
        requestRouteGeneration('/');
      }
    } else {
      print('[INFO] Server application reloaded.');
    }
  }

  Future<(http.Client, HttpServer)> _createServer() async {
    final port = int.parse(Platform.environment['PORT'] ?? '8080');
    final client = http.Client();
    var pipeline = const Pipeline();
    for (final middleware in _middleware) {
      pipeline = pipeline.addMiddleware(middleware);
    }
    _middleware.clear();
    final handler = createHandler((_, render) => render(_setup), client: client);
    return (client, await shelf_io.serve(pipeline.addHandler(handler), InternetAddress.anyIPv4, port, shared: true));
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
    final postWithClient = _client?.post ?? http.post;
    await postWithClient(Uri.http('localhost:$jasprProxyPort', r'$jasprMessageHandler'), body: jsonEncode(message));
  }
}
