/// Utilities for using Jaspr with Dart Frog. 
///
/// The `.server.dart` suffix is only needed to trigger generation of the server options file.
/// The actual server entrypoint is managed by Dart Frog.
/// 
/// See also `build.yaml` for further configuration related to the generated server options.
library;

import 'package:dart_frog/dart_frog.dart';
import 'package:jaspr/server.dart' hide Response;
import 'package:shelf/shelf.dart' as shelf;

import 'utils.server.g.dart';

/// Wraps jasprs [serveApp] as a dart_frog middleware.
///
/// This also keeps track of the base path in case this is
/// mounted under a different path than '/'.
Middleware serveJasprApp() {
  Jaspr.initializeApp(options: defaultServerOptions);

  return fromShelfMiddleware((handler) {
    return serveApp((request, _) {
      return handler(request.change(context: {...request.context, '$BasePath': () => BasePath(request.handlerPath)}));
    });
  });
}

/// Wraps jasprs [renderComponent] method to return a dart_frog response.
///
/// Renders the component wrapped in the default document and
/// uses the base path provided by the middleware.
Future<Response> renderJasprComponent(RequestContext context, Component child) async {
  final base = context.read<BasePath>();

  final response = await renderComponent(
    Document(base: base.path, body: child),
    request: shelf.Request(context.request.method.name, context.request.url, headers: context.request.headers),
  );

  return Response.bytes(statusCode: response.statusCode, body: response.body, headers: response.headers);
}

class BasePath {
  BasePath(this.path);
  final String path;
}
