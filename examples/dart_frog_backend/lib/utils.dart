import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_backend/components/app.dart';
import 'package:dart_frog_backend/components/hello.dart';
import 'package:jaspr/server.dart' hide Middleware, Response;

/// Creates a dart_frog middleware to serve a jaspr app
Middleware serveJasprApp() {
  return fromShelfMiddleware((handler) {
    return serveApp((request, _) {
      return handler(request.change(
        context: {...request.context, '$BasePath': () => BasePath(request.handlerPath)},
      ));
    });
  });
}

/// Renders a jaspr component and returns a dart_frog response
Future<Response> renderJasprComponent(RequestContext context, Component child) async {
  var base = context.read<BasePath>();

  return Response(
    body: await renderComponent(
      Document.app(
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
