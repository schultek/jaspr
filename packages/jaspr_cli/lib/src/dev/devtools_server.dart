import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_proxy/shelf_proxy.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:sse/server/sse_handler.dart';

import '../commands/base_command.dart';
import '../logging.dart';

mixin DevToolsHelper on BaseCommand {
  DevToolsController controller = DevToolsController();

  Future<HttpServer?> startDevToolsServer(int port) async {
    try {
      final Handler devtoolsHandler;
      if (Platform.environment['JASPR_DEVTOOLS_PROXY'] case final proxyPort?) {
        devtoolsHandler = proxyHandler('http://localhost:${proxyPort}');
      } else {
        final uri = await Isolate.resolvePackageUri(Uri.parse('package:jaspr_cli/src/devtools/web/'));
        if (uri == null) {
          logger.write('Could not resolve jaspr_cli package to serve DevTools.', level: Level.warning);
          return null;
        }
        final path = uri.toFilePath();
        if (!Directory(path).existsSync()) {
          logger.write('DevTools assets not found at $path.', level: Level.warning);
          return null;
        }

        devtoolsHandler = createStaticHandler(path, defaultDocument: 'index.html');
      }
      final sseHandler = SseHandler(Uri.parse('/\$jasprDevToolsEvents'));
      final sseSub = sseHandler.connections.rest.listen((connection) {
        connection.sink.add(jsonEncode(controller.info));
        final sub = controller.events.listen((event) {
          connection.sink.add(jsonEncode(event));
        });

        // sse package closes sinks when connection is terminated
        connection.sink.done.then((_) {
          sub.cancel();
        });
      });

      guardResource(() {
        sseSub.cancel();
      });

      final cascade = Cascade().add(sseHandler.handler).add(devtoolsHandler);

      final server = await shelf_io.serve(cascade.handler, InternetAddress.anyIPv4, port);
      logger.write('Serving DevTools at http://localhost:$port', tag: Tag.cli);
      return server;
    } catch (e) {
      logger.write('Failed to start DevTools Server: $e', level: Level.error);
      return null;
    }
  }
}

class DevToolsController {
  String? serverVmServiceUri;
  String? clientVmServiceUri;

  final _events = StreamController<Map<String, String?>>.broadcast();
  Stream<Map<String, String?>> get events => _events.stream;

  Map<String, String?> get info => {
    'serverVmServiceUri': serverVmServiceUri,
    'clientVmServiceUri': clientVmServiceUri,
  };

  void setServerVmServiceUri(String uri) {
    serverVmServiceUri = uri;
    _events.add(info);
  }

  void setClientVmServiceUri(String uri) {
    clientVmServiceUri = uri;
    _events.add(info);
  }
}
