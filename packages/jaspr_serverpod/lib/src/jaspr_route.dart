import 'dart:async';
import 'dart:typed_data';

import 'package:jaspr/server.dart' hide Request, Response, Handler;
import 'package:serverpod/serverpod.dart';
import 'package:shelf/shelf.dart' as shelf;
// ignore: depend_on_referenced_packages
import 'package:stream_channel/stream_channel.dart';

import '../jaspr_serverpod.dart';

/// A [JasprRoute] is the most convenient way to render Jaspr components in your server.
/// Override the [build] method and return a root [Component].
///
/// {@category Setup}
abstract class JasprRoute extends Route {
  JasprRoute() : super(methods: Method.values.toSet()) {
    handler = serveApp(_handleRenderCall);
  }

  late shelf.Handler handler;

  /// Override this method to build your root [Component] from the current [session] and [request].
  Future<Component> build(Session session, Request request);

  Future<shelf.Response> _handleRenderCall(
    shelf.Request request,
    FutureOr<shelf.Response> Function(Component) render,
  ) async {
    final session = request.context['session'] as Session;
    final req = request.context['request'] as Request;
    final component = await build(session, req);
    return render(InheritedSession(session: session, child: component));
  }

  @override
  FutureOr<Result> handleCall(Session session, Request request) async {
    final hijackCompleter = Completer<void Function(StreamChannel<List<int>>)>.sync();
    final shelf.Request shelfRequest = shelf.Request(
      request.method.value,
      request.url,
      protocolVersion: request.protocolVersion,
      headers: request.headers,
      handlerPath: request.matchedPath.path,
      body: request.body.read(),
      encoding: request.encoding,
      context: {'session': session, 'request': request},
      onHijack: (callback) => hijackCompleter.complete(callback),
    );
    final shelf.Response shelfResponse;
    try {
      shelfResponse = await handler(shelfRequest);
    } on shelf.HijackException catch (error, stackTrace) {
      // A HijackException should bypass the response-writing logic entirely.
      if (!shelfRequest.canHijack) {
        final callback = await hijackCompleter.future;
        return Hijack(callback);
      }

      // If the request wasn't hijacked, we shouldn't be seeing this exception.
      return Response.internalServerError();
    } catch (error, stackTrace) {
      return Response.internalServerError();
    }

    final response = Response(
      shelfResponse.statusCode,
      body: Body.fromDataStream(
        shelfResponse.read().map(Uint8List.fromList),
        encoding: shelfResponse.encoding,
        mimeType: shelfResponse.mimeType != null ? MimeType.parse(shelfResponse.mimeType!) : null,
        contentLength: shelfResponse.contentLength,
      ),
      headers: Headers.fromMap(shelfResponse.headersAll),
    );

    return response;
  }
}
