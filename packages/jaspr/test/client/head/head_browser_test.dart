@TestOn('browser')
library;

import 'package:jaspr_test/client_test.dart';
import 'package:universal_web/web.dart' as web;

import 'head_app.dart';

void main() {
  group('head browser test', () {
    testClient('should serve component', (tester) async {
      final initialNodes = _headElements().toSet();
      tester.pumpComponent(App());

      var nodes = _headElements().where((node) => !initialNodes.contains(node)).toList();

      expect(nodes, [
        hasOuterHtml('<title>c</title>'),
        hasOuterHtml('<meta name="test" content="b">'),
        hasOuterHtml('<meta name="c" content="e">'),
      ]);

      await tester.click(find.tag('button'));

      nodes = _headElements().where((node) => !initialNodes.contains(node)).toList();

      expect(nodes, [
        hasOuterHtml('<title>d</title>'),
        hasOuterHtml('<meta name="test" content="b">'),
        hasOuterHtml('<meta name="c" content="d">'),
      ]);
    });
  });
}

List<web.Element> _headElements() {
  final children = web.document.head!.children;
  return [for (var i = 0; i < children.length; i++) children.item(i)!];
}
