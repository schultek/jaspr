@TestOn('browser')
library;

import 'dart:html';

import 'package:jaspr/src/components/head/head_client.dart';
import 'package:jaspr_test/browser_test.dart';

import 'head_app.dart';

void main() {
  group('head browser test', () {
    testBrowser('should serve component', (tester) async {
      await tester.pumpComponent(App());

      var nodes = HeadAdapter.liveHeadNodes.toList();

      expect(nodes, hasLength(3));
      expect((nodes[0] as Element).outerHtml, equals('<title>c</title>'));
      expect((nodes[1] as Element).outerHtml, equals('<meta name="test" content="b">'));
      expect((nodes[2] as Element).outerHtml, equals('<meta name="c" content="e">'));

      await tester.click(find.tag('button'));

      nodes = HeadAdapter.liveHeadNodes.toList();

      expect((nodes[0] as Element).outerHtml, equals('<title>d</title>'));
      expect((nodes[1] as Element).outerHtml, equals('<meta name="test" content="b">'));
      expect((nodes[2] as Element).outerHtml, equals('<meta name="c" content="d">'));
    });
  });
}
