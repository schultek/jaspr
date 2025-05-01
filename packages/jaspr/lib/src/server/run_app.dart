import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';

import '../foundation/options.dart';
import '../framework/framework.dart';
import 'render_functions.dart';
import 'server_app.dart';
import 'server_handler.dart';

/// Main entry point on the server
void runApp(Component app) {
  _checkInitialized('runApp');
  ServerApp.run(_createSetup(app));
}

typedef RenderFunction = FutureOr<Response> Function(Component);
typedef AppHandler = FutureOr<Response> Function(Request, RenderFunction render);

/// Returns a shelf handler that serves the provided component and related assets.
Handler serveApp(AppHandler handler) {
  _checkInitialized('serveApp');
  return createHandler((request, render) {
    return handler(request, (app) {
      return render(_createSetup(app));
    });
  });
}

/// Directly renders the provided component to HTML. Returns a [ResponseLike] object.
///
/// - Accepts a [request] object for getting the current url and headers.
/// - When [standalone] is false (default), the html output will always have a full document structure (html, head, body).
Future<ResponseLike> renderApp(Component app, {Request? request, bool standalone = false}) async {
  _checkInitialized('renderApp');
  request ??= Request('GET', Uri.parse('https://0.0.0.0/'));
  var fileLoader = proxyFileLoader(request, staticFileHandler());
  return render(_createSetup(app), request, fileLoader, standalone);
}

/// Directly renders the provided component to HTML. Returns a [String].
///
/// - Accepts a [request] object for getting the current url and headers.
/// - When [standalone] is false (default), the html output will have a full document structure (html, head, body).
Future<String> renderComponent(Component app, {Request? request, bool standalone = false}) async {
  final response = await renderApp(app, request: request, standalone: standalone);
  return response.body.content;
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

/// A record containing the status code, body, and headers for a response.
typedef ResponseLike = ({int statusCode, ResponseBody body, Map<String, List<String>> headers});

/// A class representing the body of a response. It can be either a string or bytes.
sealed class ResponseBody {
  const factory ResponseBody(String content) = ResponseBodyString;
  const factory ResponseBody.bytes(List<int> bytes) = ResponseBodyBytes;

  String get content;
}

class ResponseBodyString implements ResponseBody {
  const ResponseBodyString(this.content);

  @override
  final String content;
}

class ResponseBodyBytes implements ResponseBody {
  const ResponseBodyBytes(this.bytes);

  final List<int> bytes;

  @override
  String get content => utf8.decode(bytes);
}
