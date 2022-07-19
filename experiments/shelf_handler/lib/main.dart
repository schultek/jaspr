import 'dart:io';

import 'package:jaspr/jaspr_server.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import 'components/app.dart';
import 'components/hello.dart';

void main() async {
  HttpServer? server;

  var router = Router();

  router.get('/', (request) => Response.ok('Hello World from Shelf'));

  // binding to a different path than '/' only works because we set the
  // <base href="/app/"> tag in index.html
  router.mount('/app', serveApp((request, render) {
    // Optionally do something with `request`
    print("Request uri is ${request.requestedUri} (${request.url})");
    // Return a server-rendered response by calling `render()` with your root component
    return render(App());
  }));

  router.get('/hello', (request) {
    // Render a single component
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
