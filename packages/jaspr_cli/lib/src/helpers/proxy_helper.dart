import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_proxy/shelf_proxy.dart';
import 'package:shelf_static/shelf_static.dart';

import '../commands/base_command.dart';
import '../dev/dev_proxy.dart';
import '../logging.dart';

mixin ProxyHelper on BaseCommand {
  Future<HttpServer> startProxy(
    String port, {
    DevProxy? devProxy,
    required String serverPort,
    String? flutterPort,
    bool redirectNotFound = false,
    void Function(Object?)? onMessage,
  }) async {
    final client = devProxy?.client ?? http.Client();
    final flutterHandler = flutterPort != null ? proxyHandler('http://localhost:$flutterPort/', client: client) : null;
    Directory('.dart_tool/jaspr/generated').createSync(recursive: true);
    final generatedHandler = noCachingHandler(createStaticHandler('.dart_tool/jaspr/generated'));
    final allowedFlutterPaths = RegExp(r'^assets|^canvaskit|^packages|.js$|.wasm$');
    final webdevHandler = devProxy?.handler ?? (req) => Response.notFound(null);

    final cascade = Cascade().add(generatedHandler).add((req) async {
      if (req.url.path == r'$jasprMessageHandler') {
        onMessage?.call(jsonDecode(await req.readAsString()));
        return Response.ok(null);
      }

      // Each proxyHandler will read the body, so we have to duplicate the stream beforehand,
      // or else this will throw.
      // This is also the reason why Cascade() won't work here.
      final body = req.read().asBroadcastStream();

      if (flutterHandler != null && req.url.path == 'flutter_bootstrap.js') {
        return await flutterHandler(req.change(body: body));
      }
      try {
        // First try to load the resource from the webdev handler.
        var res = await webdevHandler(req.change(body: body));

        // The bootstrap script hardcodes the host:port url for the dwds handler endpoint,
        // so we have to change it to our server url to be able to intercept it.
        if (res.statusCode == 200 && req.url.path.endsWith('.dart.bootstrap.js')) {
          var basePath = req.headers['jaspr_base_path'] ?? '/';
          if (!basePath.endsWith('/')) basePath += '/';
          if (!basePath.startsWith('/')) basePath = '/$basePath';
          final body = await res.readAsString();
          // Target line: 'window.$dwdsDevHandlerPath = "http://localhost:<port>/$dwdsSseHandler";'
          return res.change(body: body.replaceAll('http://localhost:$port/', 'http://localhost:$serverPort$basePath'));
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

        if (res.statusCode == 404 && redirectNotFound && path.extension(req.url.path).isEmpty) {
          return await webdevHandler(
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
        final isConnectionError =
            e is SocketException ||
            (e is http.ClientException &&
                (e.message.contains('Connection closed') || e.message.contains('Connection refused')));
        if (isConnectionError) {
          logger.write('Proxy connection to backend failed: $e', tag: Tag.cli, level: Level.verbose);
          return Response(
            503,
            headers: {
              'Retry-After': '1',
            },
          );
        } else {
          logger.write('Failed to proxy request: $e', tag: Tag.cli, level: Level.error);
          logger.write(st.toString(), tag: Tag.cli, level: Level.verbose);
          return Response.internalServerError();
        }
      }
    });

    final Completer<HttpServer> completer = Completer<HttpServer>();
    runZonedGuarded(
      () async {
        try {
          final server = await shelf_io.serve(cascade.handler, InternetAddress.anyIPv4, int.parse(port));
          completer.complete(server);
        } catch (e, st) {
          completer.completeError(e, st);
        }
      },
      (error, stackTrace) {
        if (error is SocketException) {
          return;
        }
        logger.write('Error in proxy server: $error', tag: Tag.cli, level: Level.error);
        logger.write(stackTrace.toString(), tag: Tag.cli, level: Level.verbose);
      },
    );
    final server = await completer.future;

    guardResource(() async {
      await server.close(force: true);
    });

    return server;
  }
}

Handler noCachingHandler(Handler handler) {
  return (request) async {
    final res = await handler(request);
    if (res.statusCode == 200) {
      final newHeaders = Map<String, String>.from(res.headers)
        ..remove('last-modified')
        ..remove('Last-Modified')
        ..remove('etag')
        ..remove('ETag')
        ..['Cache-Control'] = 'no-cache, no-store, must-revalidate'
        ..['Pragma'] = 'no-cache'
        ..['Expires'] = '0';
      return Response(
        res.statusCode,
        body: res.read(),
        headers: newHeaders,
        context: res.context,
      );
    }
    return res;
  };
}
