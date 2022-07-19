import 'dart:io';

import 'package:jaspr/jaspr_server.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import 'components/app.dart';
import 'components/hello.dart';

void main() async {
  HttpServer? server;

  var router = Router(notFoundHandler: serveApp((request, render) {
    print("Request uri is ${request.requestedUri}");
    return render(App());
  }));

  router.get('/hello', (request) {
    return renderComponent(Hello());
  });

  var handler = const Pipeline() //
      .addMiddleware(logRequests())
      .addHandler(router);

  server = await shelf_io.serve(handler, InternetAddress.anyIPv4, 8080);

  // Enable content compression
  server.autoCompress = true;

  print('Serving at http://${server.address.host}:${server.port}');
}
