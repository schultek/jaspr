import 'dart:async';

// server specific import
import 'package:jaspr/jaspr_server.dart';

import 'app.dart';

void main() async {
  runServer(App())
    ..addMiddleware(logRequests()) // add any shelf middleware
    ..addMiddleware((handler) {
      return (request) {
        // reroute to a custom handler
        if (request.url.path.startsWith('api')) {
          return handleApi(request.change(path: 'api'));
        }
        // this will continue with the server side rendering
        return handler(request);
      };
    });
}

FutureOr<Response> handleApi(Request request) {
  return Response.ok('FROM API');
}
