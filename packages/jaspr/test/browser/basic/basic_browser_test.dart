import 'package:jaspr_test/browser_test.dart';

import 'basic_app.dart';

void main() {
  group('basic browser test', () {
    late BrowserTester tester;

    setUp(() {
      tester = BrowserTester.setUp();
    });

    test('should render component', () async {
      await tester.pumpComponent(App());

      expect(find.text('Count: 0'), findsOneComponent);

      await tester.click(find.tag('button'));

      expect(find.text('Count: 1'), findsOneComponent);
    });
  });
}
