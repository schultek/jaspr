import 'dart:async';
import 'dart:io';

import 'package:jaspr/server.dart';
import 'package:serverpod/serverpod.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import '../jaspr_serverpod.dart';

/// A [JasprRoute] is the most convenient way to render Jaspr components in your server.
/// Override the [build] method and return a root [Component].
///
/// {@category Setup}
abstract class JasprRoute extends Route {
  JasprRoute() {
    handler = serveApp(_handleRenderCall);
  }

  late Handler handler;

  /// Override this method to build your root [Component] from the current [session] and [request].
  Future<Component> build(Session session, HttpRequest request);

  Future<Response> _handleRenderCall(Request request, FutureOr<Response> Function(Component) render) async {
    var session = request.context['session'] as Session;
    var req = request.context['request'] as HttpRequest;
    var component = await build(session, req);
    return render(InheritedSession(session: session, child: component));
  }

  @override
  Future<bool> handleCall(Session session, HttpRequest request) async {
    await shelf_io.handleRequest(request, (req) {
      return handler(req.change(context: {
        'session': session,
        'request': request,
      }));
    }, poweredByHeader: null);
    // Needed to flush hijacked requests before returning.
    await Future(() {});
    return true;
  }

  @override
  void setHeaders(HttpHeaders headers) {}
}
