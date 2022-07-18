import 'dart:io';

// server specific import
import 'package:jaspr/jaspr_server.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import 'app.dart';

void main() async {
  HttpServer? server;

  var handler = const Pipeline() //
      .addMiddleware(logRequests())
      .addHandler(serveApp(App()));

  server = await shelf_io.serve(handler, InternetAddress.anyIPv4, 8080);

  // Enable content compression
  server.autoCompress = true;

  print('Serving at http://${server.address.host}:${server.port}');
}
