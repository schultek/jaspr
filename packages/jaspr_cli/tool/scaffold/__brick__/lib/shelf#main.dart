import 'dart:io';

import 'package:jaspr/server.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import 'app.dart';
import 'jaspr_options.dart';
import 'styles.dart';

/// Initializes the custom shelf server.
///
/// The main() function will be called again during development when hot-reloading.
/// Custom backend implementations must take care of properly managing open http servers
/// and other resources that might be re-created when hot-reloading.
void main() async {
  Jaspr.initializeApp(
    options: defaultJasprOptions,
  );

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

  // Object to resolve async locking of reloads.
  var reloadLock = activeReloadLock = Object();

  var server = await shelf_io.serve(handler, InternetAddress.anyIPv4, 8080, shared: true);

  // If the reload lock changed, another reload happened and we should abort.
  if (reloadLock != activeReloadLock) {
    server.close();
    return;
  }

  // Else we can safely update the active server.
  activeServer?.close();
  activeServer = server;

  print('Serving at http://${server.address.host}:${server.port}');
}

/// Keeps track of the currently running http server.
HttpServer? activeServer;

/// Keeps track of the last created reload lock.
/// This is needed to track reloads which might happen in quick succession.
Object? activeReloadLock;
