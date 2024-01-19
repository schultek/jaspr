// ignore_for_file: implicit_call_tearoffs

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:shelf_gzip/shelf_gzip.dart';
import 'package:shelf_proxy/shelf_proxy.dart';
import 'package:shelf_static/shelf_static.dart';

import '../../server.dart';
import 'render_functions.dart';

final String kDevProxy =
    String.fromEnvironment('jaspr.dev.proxy', defaultValue: Platform.environment['jaspr_dev_proxy'] ?? '');
final String kDevFlutter = String.fromEnvironment('jaspr.dev.flutter');
const bool kDevHotreload = bool.fromEnvironment('jaspr.dev.hotreload');
const String kDevWeb = String.fromEnvironment('jaspr.dev.web');

/// A [Handler] that can be refreshed to update any used resources
class RefreshableHandler {
  final Handler _handler;
  final void Function()? onRefresh;

  RefreshableHandler(this._handler, {this.onRefresh});

  void refresh() {
    if (_handler is RefreshableHandler) {
      (_handler as RefreshableHandler).refresh();
    }
    if (onRefresh != null) {
      onRefresh!();
    }
  }

  FutureOr<Response> call(Request request) => _handler(request);
}

FutureOr<Response> Function(Request, String) _proxyFileLoader(Handler proxyHandler) {
  return (Request req, String fileName) {
    final indexRequest = Request('GET', req.requestedUri.replace(path: '/$fileName'),
        context: req.context, encoding: req.encoding, headers: req.headers, protocolVersion: req.protocolVersion);
    return proxyHandler(indexRequest);
  };
}

// coverage:ignore-start

Handler _proxyHandler() {
  var client = http.Client();
  var webdevHandler = proxyHandler('http://localhost:$kDevProxy/', client: client);
  var flutterHandler = kDevFlutter.isNotEmpty ? proxyHandler('http://localhost:$kDevFlutter/', client: client) : null;
  return RefreshableHandler((Request req) async {
    if (posix.extension(req.url.path).isEmpty && !req.url.path.startsWith(r'$')) {
      return Response.notFound('');
    }

    // Each proxyHandler will read the body, so we have to duplicate the stream beforehand,
    // or else this will throw.
    // This is also the reason why Cascade() won't work here.
    var body = await req.read().toList();

    Response? res;

    // This dart sdk module must be loaded from the flutter process, because it contains the dart:ui library.
    if (flutterHandler != null && req.url.path == 'packages/build_web_compilers/src/dev_compiler/dart_sdk.js') {
      res = await flutterHandler!(req.change(path: 'packages/build_web_compilers/src/dev_compiler/', body: body));
    }

    // First try to load the resource from the webdev process.
    if (res == null || res.statusCode == 404) {
      res = await webdevHandler(req.change(body: body));
    }

    // The bootstrap script hardcodes the host:port url for the dwds handler endpoint,
    // so we have to change it to our server url to be able to intercept it.
    if (res.statusCode == 200 && req.url.path.endsWith('.dart.bootstrap.js')) {
      var body = await res.readAsString();
      // Target line: 'window.$dwdsDevHandlerPath = "http://localhost:5467/$dwdsSseHandler";'
      return res.change(body: body.replaceAll('http://localhost:$kDevProxy/', './'));
    }

    // Second try to load the resource from the flutter process.
    if (flutterHandler != null && res.statusCode == 404) {
      res = await flutterHandler!(req.change(body: body));
    }

    return res;
  }, onRefresh: () {
    client.close();
    client = http.Client();
    webdevHandler = proxyHandler('http://localhost:$kDevProxy/', client: client);
    if (flutterHandler != null) {
      flutterHandler = proxyHandler('http://localhost:$kDevFlutter/', client: client);
    }
  });
}

String _sseHeaders(String? origin) => 'HTTP/1.1 200 OK\r\n'
    'Content-Type: text/event-stream\r\n'
    'Cache-Control: no-cache\r\n'
    'Connection: keep-alive\r\n'
    'Access-Control-Allow-Credentials: true\r\n'
    'Access-Control-Allow-Origin: $origin\r\n'
    '\r\n';

Handler _sseProxyHandler() {
  var serverUri = Uri.parse('http://localhost:$kDevProxy');
  var proxyPath = r'$dwdsSseHandler';

  Handler? incomingMessageProxyHandler;
  var httpClient = http.Client();

  Future<Response> createSseConnection(Request req, String path) async {
    final serverReq = http.StreamedRequest(req.method, serverUri.replace(path: path, query: req.requestedUri.query))
      ..followRedirects = false
      ..headers.addAll(req.headers)
      ..headers['Host'] = serverUri.authority
      ..sink.close();

    final serverResponse = await httpClient.send(serverReq);

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

  Future<Response> handleIncomingMessage(Request req, String path) async {
    incomingMessageProxyHandler ??= proxyHandler(
      serverUri,
      client: httpClient,
    );
    return incomingMessageProxyHandler!(req);
  }

  return (Request req) async {
    var path = req.url.path;

    if (!path.endsWith(proxyPath)) {
      return Response.notFound('');
    }

    if (req.headers['accept'] == 'text/event-stream' && req.method == 'GET') {
      return createSseConnection(req, path);
    }

    if (req.headers['accept'] != 'text/event-stream' && req.method == 'POST') {
      return handleIncomingMessage(req, path);
    }

    return Response.notFound('');
  };
}

// coverage:ignore-end

final webDir = kDevWeb.isNotEmpty ? kDevWeb : join(_findRootProjectDir(), 'web');

String _findRootProjectDir() {
  var dir = dirname(Platform.script.toFilePath());
  if (Platform.resolvedExecutable == Platform.script.toFilePath()) return dir;
  while (dir.isNotEmpty && !File(join(dir, 'pubspec.yaml')).existsSync()) {
    dir = dirname(dir);
  }
  return dir;
}

final staticFileHandler = kDevProxy.isNotEmpty
    ? _proxyHandler()
    : Directory(webDir).existsSync()
        ? createStaticHandler(webDir, defaultDocument: 'index.html')
        : (_) => Response.notFound('');

typedef SetupHandler = FutureOr<Response> Function(Request, FutureOr<Response> Function(SetupFunction setup));

Handler createHandler(SetupHandler handle, {List<Middleware> middleware = const [], Handler? fileHandler}) {
  var staticHandler = fileHandler ?? staticFileHandler;

  var cascade = Cascade();

  if (kDevProxy.isNotEmpty) {
    cascade = cascade.add(_sseProxyHandler());
  }

  // We skip static file handling in generate mode to always generate fresh content on the server.
  if (!kGenerateMode) {
    cascade = cascade.add(gzipMiddleware(staticHandler));
  }

  var fileLoader = _proxyFileLoader(staticHandler);
  cascade = cascade.add((request) async {
    return handle(request, (setup) async {
      // We support two modes here, rendered-html and data-only
      // rendered-html does normal ssr, but data-only only returns the preloaded state data as json
      var isDataMode = request.headers['jaspr-mode'] == 'data-only';

      var requestUri = request.url.normalizePath();
      if (!requestUri.path.startsWith('/')) {
        requestUri = requestUri.replace(path: '/${requestUri.path}');
      }

      if (isDataMode) {
        return Response.ok(
          await renderData(setup, requestUri),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        return Response.ok(
          await renderHtml(setup, requestUri, (name) async {
            var response = await fileLoader(request, name);
            return response.readAsString();
          }),
          headers: {'Content-Type': 'text/html'},
        );
      }
    });
  });

  var pipeline = const Pipeline();
  for (var m in middleware) {
    pipeline = pipeline.addMiddleware(m);
  }

  return RefreshableHandler(pipeline.addHandler(cascade.handler), onRefresh: () {
    if (staticHandler is RefreshableHandler) {
      (staticHandler as RefreshableHandler).refresh();
    }
  });
}
