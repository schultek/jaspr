import 'package:jaspr/server.dart';
import 'package:jaspr_test/server_test.dart';

import 'preload_data_app.dart';

void main() {
  group('preload data test', () {
    testMiddleware(Handler innerHandler) {
      return (Request request) {
        if (request.url.path.startsWith('api')) {
          return Response.ok('{"data": "123"}');
        }
        return innerHandler(request);
      };
    }

    testServer('should preload data', (tester) async {
      tester.pumpComponent(Document(body: App()));

      var response = await tester.request('/');

      expect(response.statusCode, equals(200));

      var body = response.document?.body;
      expect(body, isNotNull);

      var appHtml = '<div>App<button>Click Me</button>Count: 202</div>';
      expect(body!.innerHtml.trim(), equals(appHtml));
    });

    testServer('should fetch data', (tester) async {
      tester.pumpComponent(Document(body: App()));

      var response = await tester.fetchData('/');

      expect(response.statusCode, equals(200));
      expect(response.data, equals({'counter': 202}));
    });

    testServer('should fetch api', middleware: [testMiddleware], (tester) async {
      var response = await tester.request('/api');

      expect(response.statusCode, equals(200));
      expect(response.body, equals('{"data": "123"}'));
    });
  });
}
