@MappableLib(generateInitializerForScope: InitializerScope.package)
library;

import 'dart:async';
import 'dart:io';

import 'package:dart_mappable/dart_mappable.dart';
import 'package:jaspr/server.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

import 'components/playground/playground.dart';
import 'main.server.init.dart';
import 'main.server.options.dart';
import 'providers/samples_provider.dart';
import 'server/analyzer.dart';
import 'server/compiler.dart';
import 'server/download.dart';
import 'server/samples.dart';
import 'server/tutorial.dart';

void main() async {
  Jaspr.initializeApp(options: defaultServerOptions);

  var router = Router();

  router.mount('/api', apiRouter);
  router.mount(
    '/',
    serveApp((r, render) {
      return render(
        Document.template(
          name: 'main',
          child: AsyncBuilder(
            builder: (context) async {
              return ProviderScope(
                overrides: [
                  syncSamplesProvider.overrideWithValue(await loadSamples()),
                ],
                child: Playground(),
              );
            },
          ),
        ),
      );
    }),
  );

  var handler = Pipeline().addHandler(router.call);

  var port = int.parse(Platform.environment['PORT'] ?? '8080');
  var server = await serve(handler, InternetAddress.anyIPv4, port, shared: true);

  print('Serving at http://${server.address.host}:${server.port}');
}

Handler get apiRouter {
  initializeMappers();
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

  return router.call;
}

Handler mappedHandler<R, T>(FutureOr<R> Function(T request) handler) {
  return (Request request) async {
    var body = await request.readAsString();
    var result = await handler(MapperContainer.globals.fromJson(body));
    return Response.ok(MapperContainer.globals.toJson(result), headers: {'Content-Type': 'application/json'});
  };
}
