@TestOn('vm')
library;

import 'package:jaspr_test/server_test.dart';

import 'head_app.dart';

void main() {
  group('head server test', () {
    testServer('should serve component', (tester) async {
      tester.pumpComponent(App());

      var response = await tester.request('/');

      expect(response.statusCode, equals(200));

      expect(response.document?.head, isNotNull);
      var head = response.document!.head!;

      expect(head.children, hasLength(4));

      expect(head.children.first.localName, equals('base'));
      expect(head.children[1].outerHtml, equals('<title>c</title>'));
      expect(head.children[2].outerHtml, equals('<meta name="test" content="b">'));
      expect(head.children[3].outerHtml, equals('<meta name="c" content="e">'));
    });
  });
}
