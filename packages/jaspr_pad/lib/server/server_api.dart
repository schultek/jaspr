import 'dart:async';

import 'package:jaspr/server.dart' hide Router;
import 'package:shelf_router/shelf_router.dart';

import '../main.mapper.g.dart';
import 'analyzer.dart';
import 'compiler.dart';

Handler get apiRouter {
  var router = Router();

  router.post('/compile', mappedHandler(Compiler().compile));
  router.post('/analyze', mappedHandler(Analyzer().analyze));

  return router;
}

Handler mappedHandler<R, T>(FutureOr<R> Function(T request) handler) {
  return (Request request) async {
    var body = await request.readAsString();
    var result = await handler(Mapper.fromJson(body));
    return Response.ok(Mapper.toJson(result), headers: {'Content-Type': 'application/json'});
  };
}
