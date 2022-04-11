import 'package:jaspr_test/browser_test.dart';

import 'sync_data_app.dart';

void main() {
  group('preload data test', () {
    late BrowserTester tester;

    setUp(() {
      tester = BrowserTester.setUp(
        initialStateData: {'counter': 123},
      );
    });

    test('should preload data', () async {
      await tester.pumpComponent(App());

      expect(find.text('Count: 123'), findsOneComponent);

      await tester.click(find.tag('button'));

      expect(find.text('Count: 124'), findsOneComponent);
    });
  });
}
