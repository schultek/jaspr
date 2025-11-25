@TestOn('browser')
library;

import 'package:jaspr/src/components/document/document_client.dart';
import 'package:jaspr_test/client_test.dart';

import 'head_app.dart';

void main() {
  group('head browser test', () {
    testClient('should serve component', (tester) async {
      tester.pumpComponent(App());

      var nodes = AttachAdapter.instanceFor(AttachTarget.head).liveNodes.toList();

      expect(nodes, [
        hasOuterHtml('<title>c</title>'),
        hasOuterHtml('<meta name="test" content="b">'),
        hasOuterHtml('<meta name="c" content="e">'),
      ]);

      await tester.click(find.tag('button'));

      nodes = AttachAdapter.instanceFor(AttachTarget.head).liveNodes.toList();

      expect(nodes, [
        hasOuterHtml('<title>d</title>'),
        hasOuterHtml('<meta name="test" content="b">'),
        hasOuterHtml('<meta name="c" content="d">'),
      ]);
    });
  });
}
