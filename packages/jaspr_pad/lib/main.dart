import 'package:jaspr/server.dart' hide Router;
import 'package:shelf_router/shelf_router.dart';

import 'app.dart';
import 'providers/samples_provider.dart';
import 'server/samples.dart';
import 'server/server_api.dart';

void main() {
  runApp(() {
    return App(providerOverrides: [
      samplesProvider.overrideWithProvider(loadSamplesProvider),
    ]);
  }, id: 'playground')
    ..addMiddleware(logRequests())
    ..addMiddleware((handler) {
      var router = Router(notFoundHandler: handler);
      router.mount('/api', apiRouter);
      return router;
    });
}
