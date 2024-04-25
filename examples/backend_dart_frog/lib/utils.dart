import 'package:dart_frog/dart_frog.dart';
import 'package:jaspr/server.dart' hide Response;
import 'package:backend_dart_frog/jaspr_options.dart';

/// Wraps jasprs [serveApp] as a dart_frog middleware.
///
/// This also keeps track of the base path in case this is
/// mounted under a different path than '/'.
Middleware serveJasprApp() {
  Jaspr.initializeApp(options: defaultJasprOptions);

  return fromShelfMiddleware((handler) {
    return serveApp((request, _) {
      return handler(request.change(
        context: {...request.context, '$BasePath': () => BasePath(request.handlerPath)},
      ));
    });
  });
}

/// Wraps jasprs [renderComponent] method to return a dart_frog response.
///
/// Renders the component wrapped in the default document and
/// uses the base path provided by the middleware.
Future<Response> renderJasprComponent(RequestContext context, Component child) async {
  var base = context.read<BasePath>();

  return Response(
    body: await renderComponent(
      Document(
        base: base.path,
        body: child,
      ),
    ),
    headers: {'Content-Type': 'text/html'},
  );
}

class BasePath {
  BasePath(this.path);
  final String path;
}
