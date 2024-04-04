import 'dart:io';

import 'package:jaspr/server.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import 'app.dart';{{#hydration}}
import 'jaspr_options.dart';{{/hydration}}
import 'styles.dart';

void main() async {
  Jaspr.initializeApp({{#hydration}}
    options: defaultJasprOptions,
  {{/hydration}});

  var router = Router();

  // Route your api requests to your own endpoint.
  router.mount('/api', (request) {
    return Response.ok("Hello Api");
  });

  // Use [serveApp] instead of [runApp] to get a shelf handler you can mount.
  router.mount('/', serveApp((request, render) {
    // Optionally do something with `request`
    print("Request uri is ${request.requestedUri} (${request.url})");
    // Return a server-rendered response by calling `render()` with your root component
    return render(Document(
      title: '{{name}}',
      styles: styles,{{^hydration}}
      head: [
        script(defer: true, src: 'main.dart.js', []),{{#flutter}}
        link(rel: 'manifest', href: 'manifest.json'),{{/flutter}}
      ],{{/hydration}}{{#hydration}}{{#flutter}}
      head: [
        link(rel: 'manifest', href: 'manifest.json'),
      ],{{/flutter}}{{/hydration}}
      body: App(),
    ));
  }));

  var handler = const Pipeline() //
      .addMiddleware(logRequests())
      .addHandler(router);

  var server = await shelf_io.serve(handler, InternetAddress.anyIPv4, 8080, shared: true);

  print('Serving at http://${server.address.host}:${server.port}');
}
