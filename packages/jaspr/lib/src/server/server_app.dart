import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:hotreloader/hotreloader.dart';
import 'package:http/http.dart' as http;
import 'package:shelf/shelf_io.dart' as shelf_io;

import '../../server.dart';
import 'server_handler.dart';

typedef SetupFunction = void Function(ServerAppBinding binding);

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

  static http.Client? _client;

  void _run() {
    Future.microtask(() async {
      Future<HttpServer> newServer() {
        var port = int.parse(Platform.environment['PORT'] ?? '8080');
        _client?.close();
        _client = http.Client();
        var handler = createHandler((_, render) => render(_setup), client: _client, fileHandler: _fileHandler);
        return shelf_io.serve(handler, InternetAddress.anyIPv4, port, shared: true);
      }

      if (kDevHotreload) {
        await _reload(this, newServer);
      } else {
        _server = await newServer();
      }

      print('[INFO] Running server in ${kDebugMode ? 'debug' : 'release'} mode');
      print('Serving at http://${kDebugMode ? 'localhost' : server!.address.host}:${server!.port}');

      if (kGenerateMode) {
        requestRouteGeneration('/');
      }
    });
  }

  Future<void> close() async {
    await _server?.close();
    await _reloader?.stop();
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

/// Wraps the http server creation and enables hotreload.
Future<void> _reload(ServerApp app, FutureOr<HttpServer> Function() init) async {
  app._server = await init();

  // ignore: prefer_function_declarations_over_variables
  var obtainNewServer = (FutureOr<HttpServer> Function() initializer) async {
    await app.server?.close(force: true);
    print('[INFO] Server application reloaded.');
    app._server = await initializer();
  };

  try {
    app._reloader = await HotReloader.create(
      debounceInterval: Duration.zero,
      onAfterReload: (ctx) => obtainNewServer(init),
    );
    print('[INFO] Server hot reload is enabled.');
  } on StateError catch (e) {
    if (e.message.contains('VM service not available')) {
      print('[WARNING] Server hot reload not enabled. Run with --enable-vm-service to enable hot reload.');
    } else {
      rethrow;
    }
  }
}
