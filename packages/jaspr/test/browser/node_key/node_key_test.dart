@TestOn('browser')

import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/browser_test.dart';
import 'package:universal_web/web.dart';

void main() {
  group('node_key test', () {
    testBrowser('should access node from GlobalNodeKey', (tester) async {
      final key = GlobalNodeKey<HTMLInputElement>();

      tester.pumpComponent(input(key: key, type: InputType.checkbox, []));

      expect(key.currentNode, isNotNull);

      final node = key.currentNode!;

      expect(node.type, 'checkbox');
      expect(node.checked, false);
    });
  });
}
