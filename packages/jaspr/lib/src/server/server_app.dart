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

  static Object? _runLock;
  static HttpServer? _server;
  static http.Client? _client;

  void _run() async {
    var isFirstStartup = _server == null;

    var lock = _runLock = Object();
    var (client, server) = await _createServer();

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
      _writePid();

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
    var port = int.parse(Platform.environment['PORT'] ?? '8080');
    var client = http.Client();
    var handler = createHandler((_, render) => render(_setup), client: client);
    return (client, await shelf_io.serve(handler, InternetAddress.anyIPv4, port, shared: true));
  }

  void _writePid() {
    // Workaround until https://github.com/dart-lang/sdk/issues/55219 is fixed.
    var file = File('.dart_tool/jaspr/server.pid');
    if (file.existsSync()) {
      file.writeAsStringSync('$pid');
    }
  }

  static void requestRouteGeneration(String route) async {
    if (kGenerateMode) {
      _sendDebugMessage({'route': route});
    }
  }

  static Future<void> _sendDebugMessage(Object message) async {
    await http.post(
      Uri.parse('http://localhost:$jasprProxyPort/\$jasprMessageHandler'),
      body: jsonEncode(message),
    );
  }
}
