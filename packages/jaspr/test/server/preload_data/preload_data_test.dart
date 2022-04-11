import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/server_test.dart';
import 'package:shelf/shelf.dart';

import 'preload_data_app.dart';

void main() {
  group('preload data test', () {
    late ServerTester tester;

    testMiddleware(Handler innerHandler) {
      return (Request request) {
        if (request.url.path.startsWith('api')) {
          return Response.ok('{"data": "123"}');
        }
        return innerHandler(request);
      };
    }

    setUp(() async {
      tester = await ServerTester.setUp(App.new, middleware: [testMiddleware]);
    });

    tearDown(() async {
      await tester.tearDown();
    });

    test('should preload data', () async {
      var response = await tester.request('/');

      expect(response.statusCode, equals(200));

      var body = response.document?.body;
      expect(body, isNotNull);

      var appHtml = '<div id="app"><div>App<button>Click Me</button>Count: 202</div></div>';
      expect(body!.innerHtml, equals(appHtml));

      expect(
          body.attributes,
          equals({
            'state-data': stateCodec.encode({'counter': 202})
          }));
    });

    test('should fetch data', () async {
      var response = await tester.fetchData('/');

      expect(response.statusCode, equals(200));
      expect(response.data, equals({'counter': 202}));
    });

    test('should fetch api', () async {
      var response = await tester.request('/api');

      expect(response.statusCode, equals(200));
      expect(response.body, equals('{"data": "123"}'));
    });
  });
}
