import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_proxy/shelf_proxy.dart';

import '../commands/base_command.dart';
import '../logging.dart';

mixin ProxyHelper on BaseCommand {
  /// Active WebSocket connections from the DevTools UI.
  final List<WebSocket> _devToolsClients = [];

  /// The single WebSocket connection from the running app.
  WebSocket? _appSocket;

  Future<HttpServer> startProxy(
    String port, {
    required String webPort,
    required String serverPort,
    String? flutterPort,
    bool redirectNotFound = false,
    void Function(Object?)? onMessage,
  }) async {
    final client = http.Client();
    final webdevHandler = proxyHandler(Uri.parse('http://localhost:$webPort'), client: client);
    final flutterHandler = flutterPort != null ? proxyHandler('http://localhost:$flutterPort/', client: client) : null;
    final allowedFlutterPaths = RegExp(r'^assets|^canvaskit|^packages|.js$|.wasm$');

    final cascade = Cascade().add(_sseProxyHandler(client, webPort, logger)).add((req) async {
      if (req.url.path == r'$jasprMessageHandler') {
        onMessage?.call(jsonDecode(await req.readAsString()));
        return Response.ok(null);
      }

      if (req.url.path == r'$jasprProjectInfo') {
        final info = jsonEncode(_buildProjectInfo());
        return Response.ok(info, headers: {'content-type': 'application/json'});
      }

      // Each proxyHandler will read the body, so we have to duplicate the stream beforehand,
      // or else this will throw.
      // This is also the reason why Cascade() won't work here.
      final body = req.read().asBroadcastStream();

      if (flutterHandler != null && req.url.path == 'flutter_bootstrap.js') {
        return await flutterHandler(req.change(body: body));
      }
      try {
        // First try to load the resource from the webdev process.
        var res = await webdevHandler(req.change(body: body));

        // The bootstrap script hardcodes the host:port url for the dwds handler endpoint,
        // so we have to change it to our server url to be able to intercept it.
        if (res.statusCode == 200 && req.url.path.endsWith('.dart.bootstrap.js')) {
          var basePath = req.headers['jaspr_base_path'] ?? '/';
          if (!basePath.endsWith('/')) basePath += '/';
          if (!basePath.startsWith('/')) basePath = '/$basePath';
          var body = await res.readAsString();
          // Target line: 'window.$dwdsDevHandlerPath = "http://localhost:<webPort>/$dwdsSseHandler";'
          body = body.replaceAll('http://localhost:$webPort/', 'http://localhost:$serverPort$basePath');
          // Inject the DevTools WebSocket URL for the client app to connect to.
          final wsUrl = 'ws://localhost:$port/\$jasprDevTools?role=app';
          body = 'window.\$jasprDevToolsUrl = "$wsUrl";\n$body';
          return res.change(body: body);
        }

        // Temporary fix for Safari until build_web_compilers is fixed.
        if (res.statusCode == 200 && req.url.path.endsWith('.dart.js')) {
          final body = await res.readAsString();
          return res.change(
            body: body.replaceFirst(
              '// Safari.\n    return lines[0].match(/(.+):\\d+:\\d+\$/)[1];',
              '// Safari.\n    return lines[0].match(/[@](.+):\\d+:\\d+\$/)[1];',
            ),
          );
        }

        // Second try to load the resource from the flutter process.
        if (flutterHandler != null && res.statusCode == 404 && allowedFlutterPaths.hasMatch(req.url.path)) {
          res = await flutterHandler(req.change(body: body));
        }

        if (res.statusCode == 404 && redirectNotFound) {
          return webdevHandler(
            Request(
              req.method,
              req.requestedUri.replace(path: '/'),
              protocolVersion: req.protocolVersion,
              headers: req.headers,
              body: body,
              encoding: req.encoding,
            ),
          );
        }

        return res;
      } catch (e, st) {
        if (e is HijackException) {
          rethrow;
        }
        logger.write('Failed to proxy request: $e', tag: Tag.cli, level: Level.error);
        logger.write(st.toString(), tag: Tag.cli, level: Level.verbose);

        return Response.internalServerError();
      }
    });

    // Bind the server manually so we can intercept WebSocket upgrades before
    // shelf processes the request.
    final handler = cascade.handler;
    final server = await HttpServer.bind(InternetAddress.anyIPv4, int.parse(port));

    server.listen((HttpRequest request) {
      // Intercept DevTools WebSocket upgrade requests at the raw HTTP level.
      if (request.uri.path == r'/$jasprDevTools' && WebSocketTransformer.isUpgradeRequest(request)) {
        _handleDevToolsWebSocket(request);
        return;
      }
      // Everything else goes through shelf.
      shelf_io.handleRequest(request, handler);
    });

    guardResource(() async {
      client.close();
      await server.close(force: true);
    });

    return server;
  }

  /// Upgrades an HTTP request to a WebSocket and registers it in the relay.
  Future<void> _handleDevToolsWebSocket(HttpRequest request) async {
    try {
      final socket = await WebSocketTransformer.upgrade(request);
      final role = request.uri.queryParameters['role'] ?? 'devtools';
      _registerDevToolsSocket(socket, role);
    } catch (e) {
      logger.write('Failed to upgrade DevTools WebSocket: $e', tag: Tag.cli, level: Level.warning);
    }
  }

  /// Registers a WebSocket as either the app side or a DevTools client,
  /// and relays messages between them.
  void _registerDevToolsSocket(WebSocket socket, String role) {
    if (role == 'app') {
      _appSocket = socket;
      socket.listen(
        (data) {
          // Relay app messages to all DevTools clients.
          for (final client in _devToolsClients) {
            client.add(data);
          }
        },
        onDone: () {
          _appSocket = null;
        },
      );
    } else {
      _devToolsClients.add(socket);
      socket.listen(
        (data) {
          // Relay DevTools messages to the app.
          _appSocket?.add(data);
        },
        onDone: () {
          _devToolsClients.remove(socket);
        },
      );
    }
  }
}

Handler _sseProxyHandler(http.Client client, String webPort, Logger logger) {
  final serverUri = Uri.parse('http://localhost:$webPort');

  Future<Response> createSseConnection(Request req) async {
    final serverReq =
        http.StreamedRequest(req.method, serverUri.replace(path: req.url.path, query: req.requestedUri.query))
          ..followRedirects = false
          ..headers.addAll(req.headers)
          ..headers['Host'] = serverUri.authority
          ..sink.close();

    final serverResponse = await client.send(serverReq);

    req.hijack((channel) {
      final sink = utf8.encoder.startChunkedConversion(channel.sink)
        ..add(
          'HTTP/1.1 200 OK\r\n'
          'Content-Type: text/event-stream\r\n'
          'Cache-Control: no-cache\r\n'
          'Connection: keep-alive\r\n'
          'Access-Control-Allow-Credentials: true\r\n'
          'Access-Control-Allow-Origin: ${req.headers['origin']}\r\n'
          '\r\n',
        );

      StreamSubscription<void>? serverSseSub;
      StreamSubscription<void>? reqChannelSub;

      serverSseSub = utf8.decoder
          .bind(serverResponse.stream)
          .listen(
            sink.add,
            onDone: () {
              reqChannelSub?.cancel();
              sink.close();
            },
          );

      reqChannelSub = channel.stream.listen(
        (_) {
          // SSE is unidirectional.
        },
        onDone: () {
          serverSseSub?.cancel();
          sink.close();
        },
      );
    });
  }

  return (Request req) async {
    if (req.headers['accept'] == 'text/event-stream' && req.method == 'GET') {
      return await createSseConnection(req);
    }

    return Response.notFound('');
  };
}

/// Reads .dart_tool/package_config.json and builds a map of
/// package name → absolute lib path for all packages.
// NOTE: Keep in sync with the parallel implementation in
// packages/jaspr/lib/src/server/server_handler.dart
Map<String, Object> _buildProjectInfo() {
  final packages = <String, String>{};
  final configFile = _findPackageConfig(Directory.current.path);
  if (configFile != null) {
    final configDir = p.dirname(configFile.path);
    final config = jsonDecode(configFile.readAsStringSync()) as Map<String, dynamic>;
    final pkgList = config['packages'] as List<dynamic>? ?? [];
    for (final entry in pkgList) {
      final pkg = entry as Map<String, dynamic>;
      final name = pkg['name'] as String;
      final rootUri = pkg['rootUri'] as String;
      final packageUri = pkg['packageUri'] as String? ?? 'lib/';
      final String rootDir;
      if (rootUri.startsWith('file:')) {
        rootDir = Uri.parse(rootUri).toFilePath();
      } else {
        rootDir = p.normalize(p.join(configDir, rootUri));
      }
      final libDir = p.normalize(p.join(rootDir, packageUri));
      packages[name] = libDir;
    }
  }
  return {'packages': packages};
}

File? _findPackageConfig(String startDir) {
  var dir = startDir;
  while (true) {
    final f = File(p.join(dir, '.dart_tool', 'package_config.json'));
    if (f.existsSync()) return f;
    final parent = p.dirname(dir);
    if (parent == dir) return null;
    dir = parent;
  }
}
