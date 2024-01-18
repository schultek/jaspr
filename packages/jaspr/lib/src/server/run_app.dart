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
  runServer(app);
}

void initializeApp({JasprOptions options = const JasprOptions()}) {
  _globalOptions = options;
}

/// Same as [runApp] but returns an instance of [ServerApp] to control aspects of the http server
ServerApp runServer(Component app) {
  return ServerApp.run(_createSetup(app));
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

/// Directly renders the provided component into a html string
Future<String> renderComponent(Component app) async {
  return renderHtml(_createSetup(app), Uri.parse('https://0.0.0.0/'), (name) async {
    var response = await staticFileHandler(Request('get', Uri.parse('https://0.0.0.0/$name')));
    return response.readAsString();
  });
}

JasprOptions? _globalOptions;

SetupFunction _createSetup(Component app) {
  assert(_globalOptions != null, '[initializeApp] must be called before [runApp]');
  var options = _globalOptions!;
  return (binding) {
    binding.initializeOptions(options);
    binding.attachRootComponent(app);
  };
}
