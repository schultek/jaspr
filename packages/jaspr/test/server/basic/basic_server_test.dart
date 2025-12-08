@TestOn('vm')
library;

import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/server_test.dart';

import 'basic_app.dart';

void main() {
  group('basic server test', () {
    testServer('should serve component', (tester) async {
      tester.pumpComponent(
        Builder(
          builder: (context) {
            Counter.initialValue = 101;
            return App();
          },
        ),
      );

      final response = await tester.request('/');

      expect(response.statusCode, equals(200));
      expect(response.document?.body, isNotNull);

      final appHtml = '<div>App<button>Click Me</button>Count: 101</div>\n';

      expect(response.document!.body!.innerHtml, equals(appHtml));
    });
  });
}
