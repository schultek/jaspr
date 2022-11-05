import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_backend/components/app.dart';
import 'package:dart_frog_backend/components/hello.dart';
import 'package:jaspr/server.dart' hide Middleware, Response;

/// Creates a dart_frog middleware to serve a jaspr app
Middleware serveJasprApp() {
  return fromShelfMiddleware((handler) {
    return serveApp((request, _) {
      return handler(request.change(
        context: {...request.context, '$_Base': () => _Base(request.handlerPath)},
      ));
    });
  });
}

/// Renders a jaspr component and returns a dart_frog response
Future<Response> renderJasprComponent(RequestContext context, Component child) async {

  // this is normally auto-generated, but does not work together with dart_frog
  // TODO: find a way to automate this
  ComponentRegistry.initialize('server', components: {
    App: ComponentEntry.app('components/app'),
    Hello: ComponentEntry<Hello>.app('components/hello', getParams: (c) => {'name': c.name}),
  });

  var base = context.read<_Base>();

  return Response(
    body: await renderComponent(
      Document.app(
        base: base.base,
        body: child,
      ),
    ),
    headers: {'Content-Type': 'text/html'},
  );
}

class _Base {
  _Base(this.base);
  final String base;
}
