import 'dart:async';

import 'package:shelf/shelf.dart';

import '../framework/framework.dart';
import 'server_app.dart';
import 'server_binding.dart';
import 'server_handler.dart';
import 'server_renderer.dart';

/// Main entry point on the server
/// TODO: Add hint about usage of global variables and isolate state
void runApp(Component app) {
  runServer(app);
}

/// Same as [runApp] but returns an instance of [ServerApp] to control aspects of the http server
ServerApp runServer(Component app) {
  return ServerApp.run(() {
    AppBinding.ensureInitialized().attachRootComponent(app, attachTo: '_');
  });
}


/// Returns a shelf handler that serves the provided component and related assets
Handler serveApp(AppHandler handler) {
  return createHandler((request, render) {
    return handler(request, (app) {
      return render(_createSetup(app));
    });
  });
}

typedef RenderFunction = FutureOr<Response> Function(Component);
typedef AppHandler = FutureOr<Response> Function(Request, RenderFunction render);

/// Directly renders the provided component into a html response
Future<Response> renderComponent(Component app) async {
  return renderApp(_createSetup(app), Request('get', Uri.parse('https://0.0.0.0/')), (name) async {
    var response = await staticFileHandler(Request('get', Uri.parse('https://0.0.0.0/$name')));
    return response.readAsString();
  });
}

SetupFunction _createSetup(Component app) {
  return () => AppBinding.ensureInitialized().attachRootComponent(app, attachTo: '_');
}