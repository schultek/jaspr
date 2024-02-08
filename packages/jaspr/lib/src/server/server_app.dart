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

  static final createTestHandler = createHandler;

  final SetupFunction _setup;

  static HttpServer? _server;
  static http.Client? _client;

  void _run() async {
    var isFirstStartup = _server == null;

    await _server?.close(force: true);
    _server = await _createServer();

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

  Future<HttpServer> _createServer() {
    var port = int.parse(Platform.environment['PORT'] ?? '8080');
    _client?.close();
    _client = http.Client();
    var handler = createHandler((_, render) => render(_setup), client: _client);
    return shelf_io.serve(handler, InternetAddress.anyIPv4, port, shared: true);
  }

  static void requestRouteGeneration(String route) async {
    if (kGenerateMode) {
      _sendDebugMessage({'route': route});
    }
  }

  static Future<void> _sendDebugMessage(Object message) async {
    assert(_client != null, 'No server running, did you call "runApp()"?');
    await _client!.post(
      Uri.parse('http://localhost:$jasprProxyPort/\$jasprMessageHandler'),
      body: jsonEncode(message),
    );
  }
}
