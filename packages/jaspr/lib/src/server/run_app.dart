import 'dart:async';

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

/// Directly renders the provided component into a html string
Future<String> renderComponent(Component app) async {
  _checkInitialized('renderComponent');
  final fileHandler = staticFileHandler();
  return render(RenderMode.html, _createSetup(app), Uri.parse('https://0.0.0.0/'), (name) async {
    final response = await fileHandler(Request('get', Uri.parse('https://0.0.0.0/$name')));
    return response.statusCode == 200 ? response.readAsString() : null;
  });
}

void _checkInitialized(String method) {
  assert(() {
    if (!Jaspr.isInitialized) {
      // ignore: avoid_print
      print('[WARNING] Jaspr was not initialized. Call Jaspr.initializeApp() before calling $method(). '
          'This will be required in a future version of jaspr and result in an error.');
    }
    return true;
  }());
}

SetupFunction _createSetup(Component app) {
  final options = Jaspr.options;
  return (binding) {
    binding.initializeOptions(options);
    binding.attachRootComponent(app);
  };
}
