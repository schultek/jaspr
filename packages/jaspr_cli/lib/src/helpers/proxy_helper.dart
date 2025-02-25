import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_proxy/shelf_proxy.dart';

import '../commands/base_command.dart';
import '../logging.dart';

mixin ProxyHelper on BaseCommand {
  Future<HttpServer> startProxy(String port,
      {required String webPort,
      String? flutterPort,
      bool redirectNotFound = false,
      void Function(dynamic)? onMessage}) async {
    var client = http.Client();
    var webdevHandler = proxyHandler(Uri.parse('http://localhost:$webPort'), client: client);
    var flutterHandler = flutterPort != null ? proxyHandler('http://localhost:$flutterPort/', client: client) : null;
    var allowedFlutterPaths = RegExp(r'^assets|^canvaskit|^packages|.js$|.wasm$');

    var cascade = Cascade().add(_sseProxyHandler(client, webPort, logger)).add((req) async {
      if (req.url.path == r'$jasprMessageHandler') {
        onMessage?.call(jsonDecode(await req.readAsString()));
        return Response.ok(null);
      }

      // Each proxyHandler will read the body, so we have to duplicate the stream beforehand,
      // or else this will throw.
      // This is also the reason why Cascade() won't work here.
      var body = req.read().asBroadcastStream();

      if (flutterHandler != null && req.url.path == 'flutter_bootstrap.js') {
        return await flutterHandler(req.change(body: body));
      }

      // First try to load the resource from the webdev process.
      var res = await webdevHandler(req.change(body: body));

      // The bootstrap script hardcodes the host:port url for the dwds handler endpoint,
      // so we have to change it to our server url to be able to intercept it.
      if (res.statusCode == 200 && req.url.path.endsWith('.dart.bootstrap.js')) {
        var body = await res.readAsString();
        // Target line: 'window.$dwdsDevHandlerPath = "http://localhost:<webPort>/$dwdsSseHandler";'
        return res.change(body: body.replaceAll('http://localhost:$webPort/', './'));
      }

      // Second try to load the resource from the flutter process.
      if (flutterHandler != null && res.statusCode == 404 && allowedFlutterPaths.hasMatch(req.url.path)) {
        res = await flutterHandler(req.change(body: body));
      }

      if (res.statusCode == 404 && redirectNotFound) {
        return webdevHandler(Request(
          req.method,
          req.requestedUri.replace(path: '/'),
          protocolVersion: req.protocolVersion,
          headers: req.headers,
          body: body,
          encoding: req.encoding,
        ));
      }

      return res;
    });

    var server = await shelf_io.serve(cascade.handler, InternetAddress.anyIPv4, int.parse(port));

    guardResource(() async {
      client.close();
      await server.close(force: true);
    });

    return server;
  }
}

Handler _sseProxyHandler(http.Client client, String webPort, Logger logger) {
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
