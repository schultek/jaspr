@TestOn('vm')
library;

import 'package:jaspr_test/jaspr_test.dart';

import 'basic_app.dart';

void main() {
  group('basic component test', () {
    testComponents('should render component', (tester) async {
      tester.pumpComponent(App());

      expect(find.text('Count: 0'), findsOneComponent);

      await tester.click(find.tag('button'));

      expect(find.text('Count: 1'), findsOneComponent);
    });
  });
}
