import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_gzip/shelf_gzip.dart';
import 'package:shelf_proxy/shelf_proxy.dart';
import 'package:shelf_static/shelf_static.dart';

import '../foundation/constants.dart';
import 'render_functions.dart';
import 'server_app.dart';

final String? jasprProxyPort = Platform.environment['JASPR_PROXY_PORT'];
const String kDevWeb = String.fromEnvironment('jaspr.dev.web');

final webDir = kDevWeb.isNotEmpty ? kDevWeb : join(_findRootProjectDir(), 'web');

String _findRootProjectDir() {
  final executableDir = dirname(Platform.script.toFilePath());
  final workingDir = Directory.current.path;

  if (Platform.resolvedExecutable == Platform.script.toFilePath()) {
    return executableDir;
  }

  final foundDir = _tryFindRootProjectDir(executableDir) ?? _tryFindRootProjectDir(workingDir);

  if (foundDir == null) {
    throw Exception('Could not resolve project directory containing pubspec.yaml');
  }

  return foundDir;
}

String? _tryFindRootProjectDir(String startingDir) {
  if (File(join(startingDir, 'pubspec.yaml')).existsSync()) {
    return startingDir;
  }

  final parentDir = dirname(startingDir);
  if (startingDir == parentDir) {
    return null;
  }

  return _tryFindRootProjectDir(parentDir);
}

Handler staticFileHandler([http.Client? client]) => jasprProxyPort != null
    ? proxyHandler('http://localhost:$jasprProxyPort/', client: client)
    : Directory(webDir).existsSync()
        ? createStaticHandler(webDir, defaultDocument: 'index.html')
        : (_) => Response.notFound('');

typedef SetupHandler = FutureOr<Response> Function(Request, FutureOr<Response> Function(SetupFunction setup));

final _allowedRenderPaths = RegExp(r'\.html?$|^[^.]*$');

Handler createHandler(SetupHandler handle, {http.Client? client, Handler? fileHandler}) {
  client ??= http.Client();
  var staticHandler = fileHandler ?? staticFileHandler(client);

  var cascade = Cascade();

  if (jasprProxyPort != null) {
    cascade = cascade.add(_sseProxyHandler(client, jasprProxyPort!));
  }

  // We skip static file handling in generate mode to always generate fresh content on the server.
  if (!kGenerateMode) {
    cascade = cascade.add(gzipMiddleware(staticHandler));
  }

  cascade = cascade.add((request) async {
    if (!_allowedRenderPaths.hasMatch(request.url.pathSegments.lastOrNull ?? '')) {
      return Response(404);
    }

    var fileLoader = proxyFileLoader(request, staticHandler);
    return handle(request, (setup) async {
      final (:body, :headers, :statusCode) = await render(setup, request, fileLoader, false);
      return Response(statusCode, body: body, headers: headers);
    });
  });

  return cascade.handler;
}

Future<String?> Function(String) proxyFileLoader(Request req, Handler proxyHandler) {
  return (name) async {
    final indexRequest = Request('GET', req.requestedUri.replace(path: '/$name'),
        context: req.context, encoding: req.encoding, headers: req.headers, protocolVersion: req.protocolVersion);
    var response = await proxyHandler(indexRequest);
    return response.statusCode == 200 ? response.readAsString() : null;
  };
}

// coverage:ignore-start

Handler _sseProxyHandler(http.Client client, String webPort) {
  var serverUri = Uri.parse('http://localhost:$webPort');

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
        ..add('HTTP/1.1 200 OK\r\n'
            'Content-Type: text/event-stream\r\n'
            'Cache-Control: no-cache\r\n'
            'Connection: keep-alive\r\n'
            'Access-Control-Allow-Credentials: true\r\n'
            'Access-Control-Allow-Origin: ${req.headers['origin']}\r\n'
            '\r\n');

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

  return (Request req) async {
    if (req.headers['accept'] == 'text/event-stream' && req.method == 'GET') {
      return await createSseConnection(req);
    }

    return Response.notFound('');
  };
}

// coverage:ignore-end
