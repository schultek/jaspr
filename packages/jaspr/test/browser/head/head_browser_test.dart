@TestOn('browser')

import 'package:jaspr/src/components/document/document_client.dart';
import 'package:jaspr_test/browser_test.dart';
import 'package:web/web.dart';

import 'head_app.dart';

void main() {
  group('head browser test', () {
    testBrowser('should serve component', (tester) async {
      await tester.pumpComponent(App());

      var nodes = AttachAdapter.instanceFor(AttachTarget.head).liveNodes.toList();

      expect(nodes, [_hasOuterHtml('<title>c</title>'), _hasOuterHtml('<meta name="c" content="e">')]);

      await tester.click(find.tag('button'));

      nodes = AttachAdapter.instanceFor(AttachTarget.head).liveNodes.toList();

      expect(nodes, [_hasOuterHtml('<title>d</title>')]);
    });
  });
}

Matcher _hasOuterHtml(outer) {
  return isA<HTMLElement>().having((e) => e.outerHTML, 'outerHTML', outer);
}
