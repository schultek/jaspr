@TestOn('vm')

import 'package:jaspr/server.dart';
import 'package:jaspr_test/server_test.dart';

import 'preload_data_app.dart';

void main() {
  group('preload data test', () {
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
  });
}
