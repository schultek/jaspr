import 'dart:async';

import 'package:jaspr/server.dart' hide Router;
import 'package:shelf_router/shelf_router.dart';

import '../main.mapper.g.dart';
import 'analyzer.dart';
import 'compiler.dart';

Handler apiRouter(String sdkPath) {
  var router = Router();

  var analyzer = Analyzer(sdkPath);

  router.post('/compile', mappedHandler(Compiler().compile));
  router.post('/analyze', mappedHandler(analyzer.analyze));
  router.post('/format', mappedHandler(analyzer.format));
  router.post('/document', mappedHandler(analyzer.document));

  return router;
}

Handler mappedHandler<R, T>(FutureOr<R> Function(T request) handler) {
  return (Request request) async {
    var body = await request.readAsString();
    var result = await handler(Mapper.fromJson(body));
    return Response.ok(Mapper.toJson(result), headers: {'Content-Type': 'application/json'});
  };
}
