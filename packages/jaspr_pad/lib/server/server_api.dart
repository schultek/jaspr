import 'dart:async';

import 'package:jaspr/server.dart' hide Router;
import 'package:shelf_router/shelf_router.dart';

import '../main.mapper.g.dart';
import 'analyzer.dart';
import 'compiler.dart';
import 'download.dart';
import 'samples.dart';

Handler get apiRouter {
  var router = Router();

  var compiler = Compiler();
  var analyzer = Analyzer();

  router.post('/compile', mappedHandler(compiler.compile));
  router.post('/analyze', mappedHandler(analyzer.analyze));
  router.post('/format', mappedHandler(analyzer.format));
  router.post('/document', mappedHandler(analyzer.document));
  router.get('/sample/<id>', getSample);
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
