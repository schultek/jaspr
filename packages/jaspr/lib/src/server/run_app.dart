import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf.dart';

import '../foundation/options.dart';
import '../framework/framework.dart';
import 'render_functions.dart';
import 'server_app.dart';
import 'server_handler.dart';

/// Main entry point on the server
/// TODO: Add hint about usage of global variables and isolate state
void runApp(Component app) {
  _checkInitialized('runApp');
  ServerApp.run(_createSetup(app));
}

/// Returns a shelf handler that serves the provided component and related assets
Handler serveApp(AppHandler handler) {
  _checkInitialized('serveApp');
  return createHandler((request, render) {
    return handler(request, (app) {
      return render(_createSetup(app));
    });
  });
}

typedef RenderFunction = FutureOr<Response> Function(Component);
typedef AppHandler = FutureOr<Response> Function(Request, RenderFunction render);

/// Directly renders the provided component into a html string.
///
/// When [standalone] is false (default), the html output will have a full document structure (html, head, body).
Future<ResponseLike> renderComponent(Component app, {Request? request, bool standalone = false}) async {
  _checkInitialized('renderComponent');
  request ??= Request('GET', Uri.parse('https://0.0.0.0/'));
  var fileLoader = proxyFileLoader(request, staticFileHandler());
  return render(_createSetup(app), request, fileLoader, standalone);
}

void _checkInitialized(String method) {
  if (!Jaspr.isInitialized) {
    stderr.write("Error: Jaspr was not initialized. Call Jaspr.initializeApp() before calling $method()");
    exit(-1);
  }
}

SetupFunction _createSetup(Component app) {
  var options = Jaspr.options;
  return (binding) {
    binding.initializeOptions(options);
    binding.attachRootComponent(app);
  };
}
