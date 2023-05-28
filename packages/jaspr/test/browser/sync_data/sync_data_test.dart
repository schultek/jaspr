import 'package:jaspr_test/browser_test.dart';

import 'sync_data_app.dart';

void main() {
  group('preload data test', () {
    testBrowser('should preload data', (tester) async {
      await tester.pumpComponent(App(), initialSyncState: {'counter': 123});

      expect(find.text('Count: 123'), findsOneComponent);

      await tester.click(find.tag('button'));

      expect(find.text('Count: 124'), findsOneComponent);
    });
  });
}
