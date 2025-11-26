@TestOn('browser')
library;

import 'package:jaspr_test/client_test.dart';

import 'basic_app.dart';

void main() {
  group('basic browser test', () {
    testClient('should render component', (tester) async {
      tester.pumpComponent(App());

      expect(find.text('Count: 0'), findsOneComponent);

      await tester.click(find.tag('button'));

      expect(find.text('Count: 1'), findsOneComponent);
    });
  });
}
