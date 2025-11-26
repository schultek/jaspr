import 'package:jaspr/server.dart';
import 'package:serverpod/serverpod.dart';

import 'main.server.g.dart';
import 'src/generated/endpoints.dart';
import 'src/generated/protocol.dart';
import 'src/web/routes/root.dart';

// This is the starting point of your Serverpod server. In most cases, you will
// only need to make additions to this file if you add future calls,  are
// configuring Relic (Serverpod's web-server), or need custom setup work.

void main(List<String> args) async {
  // Initialize Serverpod and connect it with your generated code.
  final pod = Serverpod(args, Protocol(), Endpoints());

  // If you are using any future calls, they need to be registered here.
  // pod.registerFutureCall(ExampleFutureCall(), 'exampleFutureCall');

  Jaspr.initializeApp(options: defaultServerOptions);

  // Let Jaspr render all routes.
  pod.webServer.addRoute(RootRoute(), '/*');

  // Start the server.
  await pod.start();
}
