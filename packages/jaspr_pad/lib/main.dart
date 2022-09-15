import 'dart:async';

import 'package:jaspr/server.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:shelf_router/shelf_router.dart';

import '../main.mapper.g.dart';
import 'components/playground/playground.dart';
import 'providers/samples_provider.dart';
import 'server/analyzer.dart';
import 'server/compiler.dart';
import 'server/download.dart';
import 'server/samples.dart';
import 'server/tutorial.dart';

void main() {
  runServer(Builder.single(builder: (context) {
    return ProviderScope(
      overrides: [samplesProvider.overrideWithProvider(loadSamplesProvider)],
      child: Playground(),
    );
  }))
    ..addMiddleware(logRequests())
    ..addMiddleware((handler) {
      var router = Router(notFoundHandler: handler);
      router.mount('/api', apiRouter);
      return router;
    });
}

Handler get apiRouter {
  var router = Router();

  var compiler = Compiler();
  var analyzer = Analyzer();

  router.post('/compile', mappedHandler(compiler.compile));
  router.post('/analyze', mappedHandler(analyzer.analyze));
  router.post('/format', mappedHandler(analyzer.format));
  router.post('/document', mappedHandler(analyzer.document));
  router.get('/sample/<id>', getSample);
  router.get('/tutorial/<stepId>', getTutorial);
  router.get('/download', downloadProject);

  return router;
}

Handler mappedHandler<R, T>(FutureOr<R> Function(T request) handler) {
  return (Request request) async {
    var body = await request.readAsString();
    var result = await handler(Mapper.fromJson(body));
    return Response.ok(Mapper.toJson(result), headers: {'Content-Type': 'application/json'});
  };
}
