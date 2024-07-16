import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shelf/shelf_io.dart' as shelf_io;

import '../../server.dart';
import 'server_handler.dart';

typedef SetupFunction = void Function(ServerAppBinding binding);

/// An object to be returned from runApp on the server and provide access to the internal http server
class ServerApp {
  ServerApp._(this._setup);

  factory ServerApp.run(SetupFunction setup) {
    return ServerApp._(setup).._run();
  }

  static const createTestHandler = createHandler;

  final SetupFunction _setup;

  static Object? _runLock;
  static HttpServer? _server;
  static http.Client? _client;

  Future<void> _run() async {
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

    if (isFirstStartup) {
      // ignore: avoid_print
      print('[INFO] Running server in ${kDebugMode ? 'debug' : 'release'} mode\n'
          'Serving at http://${kDebugMode ? 'localhost' : _server!.address.host}:${_server!.port}');

      if (kGenerateMode) {
        requestRouteGeneration('/');
      }
    } else {
      // ignore: avoid_print
      print('[INFO] Server application reloaded.');
    }
  }

  Future<(http.Client, HttpServer)> _createServer() async {
    final port = int.parse(Platform.environment['PORT'] ?? '8080');
    final client = http.Client();
    final handler = createHandler((_, render) => render(_setup), client: client);
    return (client, await shelf_io.serve(handler, InternetAddress.anyIPv4, port, shared: true));
  }

  static Future<void> requestRouteGeneration(String route) async {
    if (kGenerateMode) {
      await _sendDebugMessage({'route': route});
    }
  }

  static Future<void> _sendDebugMessage(Object message) async {
    await http.post(
      Uri.parse('http://localhost:$jasprProxyPort/\$jasprMessageHandler'),
      body: jsonEncode(message),
    );
  }
}
