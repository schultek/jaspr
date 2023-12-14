// server specific import
import 'package:jaspr/server.dart';

import 'app.dart';

void main() async {
  // Uses [runServer] in place of [runApp] to retrieve the [ServerApp] instance.
  ServerApp app = runServer(Document(body: App()));

  // Adds the standard shelf logging middleware to print out any incoming request.
  app.addMiddleware(logRequests());

  // Adds a custom middleware that reroutes requests to `/api` to a custom handler.
  app.addMiddleware((handler) {
    return (request) {
      // reroute all api paths to a custom handler
      if (request.url.path.startsWith('api')) {
        return handleApi(request.change(path: 'api'));
      }

      // otherwise this will continue with the server side rendering
      return handler(request);
    };
  });
}

Future<Response> handleApi(Request request) async {
  return Response.ok('Hello from the API.');
}
