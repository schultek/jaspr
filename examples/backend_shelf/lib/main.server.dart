import 'dart:io';

import 'package:jaspr/server.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import 'components/app.dart';
import 'components/hello.dart';
import 'main.server.g.dart';

void main() async {
  Jaspr.initializeApp(options: defaultServerOptions);

  HttpServer? server;

  final router = Router();

  router.get('/', (request) => Response.ok('Hello World from Shelf'));

  // binding to a different path than '/' only works because we set the
  // base: '/app' parameter on the document
  router.mount(
    '/app',
    serveApp((request, render) {
      // Optionally do something with `request`
      print("Request uri is ${request.requestedUri} (${request.url})");
      // Return a server-rendered response by calling `render()` with your root component
      return render(Document(base: '/app', body: App()));
    }),
  );

  router.get('/hello', (request) async {
    // Render a single component manually
    return Response.ok(
      await renderComponent(
        Document(
          // we still point to /app to correctly load all other resources,
          // like js, css or image files
          base: '/app',
          body: Hello(),
        ),
      ),
      headers: {'Content-Type': 'text/html'},
    );
  });

  final handler =
      const Pipeline() //
          .addMiddleware(logRequests())
          .addHandler(router.call);

  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port, shared: true);

  // Enable content compression
  server.autoCompress = true;

  print('Serving at http://${server.address.host}:${server.port}');
}
