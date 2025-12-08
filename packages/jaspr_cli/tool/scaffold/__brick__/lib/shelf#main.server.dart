/// The entrypoint for the **server** environment.
///
/// The [main] method will only be executed on the server during pre-rendering.
/// To run code on the client, check the `main.client.dart` file.
library;

import 'dart:io';

import 'package:jaspr/dom.dart';
// Server-specific Jaspr import.
import 'package:jaspr/server.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

// Imports the [App] component.
import 'app.dart';

// This file is generated automatically by Jaspr, do not remove or edit.
import 'main.server.options.dart';

/// Initializes the custom shelf server.
///
/// The main() function will be called again during development when hot-reloading.
/// Custom backend implementations must take care of properly managing open http servers
/// and other resources that might be re-created when hot-reloading.
void main() async {
  Jaspr.initializeApp(
    options: defaultServerOptions,
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
      styles: [
        // Special import rule to include to another css file.
        css.import('https://fonts.googleapis.com/css?family=Roboto'),
        // Each style rule takes a valid css selector and a set of styles.
        // Styles are defined using type-safe css bindings and can be freely chained and nested.
        css('html, body').styles(
          width: 100.percent,
          minHeight: 100.vh,
          padding: .zero,
          margin: .zero,
          fontFamily: const .list([FontFamily('Roboto'), FontFamilies.sansSerif]),
        ),
        css('h1').styles(
          margin: .unset,
          fontSize: 4.rem,
        ),
      ],{{#flutter}}
      head: [
        // The generated flutter manifest and bootstrap script.
        link(rel: 'manifest', href: 'manifest.json'),
        script(src: "flutter_bootstrap.js", async: true),
      ],{{/flutter}}
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
