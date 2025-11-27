@TestOn('vm')
library;

import 'dart:async';

import 'package:jaspr/server.dart';
import 'package:jaspr/src/server/child_nodes.dart';
import 'package:jaspr_test/jaspr_test.dart';
import 'package:jaspr_test/server_test.dart';

// ignore: implementation_imports
import 'package:shelf/src/headers.dart';

void main() {
  group('child list', () {
    Future<RenderObjectElement> renderServerApp(Component app) async {
      final binding = ServerAppBinding((url: '/', headers: Headers.empty()), loadFile: (_) async => null);
      binding.initializeOptions(ServerOptions());
      binding.attachRootComponent(app);

      if (binding.rootElement!.owner.isFirstBuild) {
        final completer = Completer<void>.sync();
        binding.rootElement!.binding.addPostFrameCallback(completer.complete);
        await completer.future;
      }

      return binding.rootElement!;
    }

    RenderObjectElement? findTag(Element root, String tag) {
      RenderObjectElement? result;
      root.visitChildren((e) {
        if (result != null) return;
        if (e is RenderObjectElement && (e.renderObject as MarkupRenderElement).tag == tag) {
          result = e;
        } else {
          result = findTag(e, tag);
        }
      });
      return result;
    }

    test('contains render objects', () async {
      final r = await renderServerApp(
        Component.element(
          tag: 'html',
          children: [
            Component.element(tag: 'head', children: []),
            Component.element(
              tag: 'body',
              children: [
                Component.element(tag: 'div', children: []),
                Component.element(tag: 'span', children: []),
              ],
            ),
          ],
        ),
      );

      final root = r.renderObject as MarkupRenderObject;

      // Using the iterator
      expect(root.children, hasLength(1));
      expect(root.children.first, hasTag('html'));
      expect(root.children.first.children, hasLength(2));
      expect(root.children.first.children.first, hasTag('head'));
      expect(root.children.first.children.last, hasTag('body'));
      expect(root.children.first.children.last.children, hasLength(2));
      expect(root.children.first.children.last.children.first, hasTag('div'));
      expect(root.children.first.children.last.children.last, hasTag('span'));

      // Using the underlying linked list
      ChildNode? node = root.children.firstNode;
      expect(node, isA<ChildNode>().having((n) => n.prev, 'prev', isNull));
      node = node.next;
      expect(node, isA<ChildNodeData>().having((n) => n.node, 'node', hasTag('html')));
      node = node?.next;
      expect(node, equals(root.children.lastNode));
      expect(node, isA<ChildNode>().having((n) => n.next, 'next', isNull));

      // Using findWhere
      expect(
        root.children.first.children.findWhere<MarkupRenderElement>((e) => e.tag == 'body'),
        isA<ChildNodeData>().having((n) => n.node, 'node', hasTag('body')),
      );
    });

    test('finds render objects with fragments', () async {
      final r = await renderServerApp(
        Component.element(
          tag: 'html',
          children: [
            Component.fragment([Component.element(tag: 'head', children: [])]),
            Component.element(
              tag: 'body',
              children: [
                Component.element(tag: 'div', children: []),
                Component.element(tag: 'span', children: []),
              ],
            ),
          ],
        ),
      );

      final root = r.renderObject as MarkupRenderObject;

      // Using the iterator
      expect(root.children, hasLength(1));
      expect(root.children.first, hasTag('html'));
      expect(root.children.first.children, hasLength(2));
      expect(root.children.first.children.first, isA<MarkupRenderFragment>());
      expect(root.children.first.children.first.children, hasLength(1));
      expect(root.children.first.children.first.children.first, hasTag('head'));
      expect(root.children.first.children.last, hasTag('body'));

      // Using findWhere
      expect(
        root.children.first.children.findWhere<MarkupRenderElement>((e) => e.tag == 'head'),
        isA<ChildNodeData>().having((n) => n.node, 'node', hasTag('head')),
      );
      expect(
        root.children.first.children.findWhere<MarkupRenderElement>((e) => e.tag == 'head', visitFragments: false),
        isNull,
      );
    });

    test('wraps render element', () async {
      final r = await renderServerApp(
        Component.element(
          tag: 'html',
          children: [
            Component.element(tag: 'head', children: []),
            Component.element(tag: 'body', children: []),
          ],
        ),
      );

      final root = r.renderObject as MarkupRenderObject;
      final children = root.children.first.children;

      // Check children using the underlying linked list
      ChildNode? node = children.firstNode;
      expect(node, isA<ChildNode>().having((n) => n.prev, 'prev', isNull));
      node = node.next;
      expect(node, isA<ChildNodeData>().having((n) => n.node, 'node', hasTag('head')));
      node = node?.next;
      expect(node, isA<ChildNodeData>().having((n) => n.node, 'node', hasTag('body')));
      node = node?.next;
      expect(node, equals(children.lastNode));
      expect(node, isA<ChildNode>().having((n) => n.next, 'next', isNull));

      final element = findTag(r, 'body')!;
      expect(element.renderObject, hasTag('body'));

      final range = children.wrapElement(element);

      // Check range using iterator
      expect(range, hasLength(1));
      expect(range.first, hasTag('body'));

      // Check changed children using the underlying linked list
      node = children.firstNode;
      expect(node, isA<ChildNode>().having((n) => n.prev, 'prev', isNull));
      node = node.next;
      expect(node, isA<ChildNodeData>().having((n) => n.node, 'node', hasTag('head')));
      node = node?.next;
      expect(node, equals(range.start));
      expect(
        node,
        isA<ChildNodeBoundary>().having((n) => n.element, 'element', element).having((n) => n.range, 'range', range),
      );
      node = node?.next;
      expect(node, isA<ChildNodeData>().having((n) => n.node, 'node', hasTag('body')));
      node = node?.next;
      expect(node, equals(range.end));
      expect(
        node,
        isA<ChildNodeBoundary>().having((n) => n.element, 'element', element).having((n) => n.range, 'range', range),
      );
      node = node?.next;
      expect(node, equals(children.lastNode));
      expect(node, isA<ChildNode>().having((n) => n.next, 'next', isNull));
    });

    test('wraps buildable element', () async {
      final r = await renderServerApp(
        Component.element(
          tag: 'html',
          children: [
            Component.element(tag: 'head', children: []),
            Builder(
              builder: (context) {
                return Component.element(tag: 'body', children: []);
              },
            ),
          ],
        ),
      );

      final root = r.renderObject as MarkupRenderObject;
      final children = root.children.first.children;

      // Check children using the underlying linked list
      ChildNode? node = children.firstNode;
      expect(node, isA<ChildNode>().having((n) => n.prev, 'prev', isNull));
      node = node.next;
      expect(node, isA<ChildNodeData>().having((n) => n.node, 'node', hasTag('head')));
      node = node?.next;
      expect(node, isA<ChildNodeData>().having((n) => n.node, 'node', hasTag('body')));
      node = node?.next;
      expect(node, equals(children.lastNode));
      expect(node, isA<ChildNode>().having((n) => n.next, 'next', isNull));

      final element = findTag(r, 'body')!.parent!;
      expect(element, isA<BuildableElement>().having((e) => e.component, 'component', isA<Builder>()));

      final range = children.wrapElement(element);

      // Check range using iterator
      expect(range, hasLength(1));
      expect(range.first, hasTag('body'));

      // Check changed children using the underlying linked list
      node = children.firstNode;
      expect(node, isA<ChildNode>().having((n) => n.prev, 'prev', isNull));
      node = node.next;
      expect(node, isA<ChildNodeData>().having((n) => n.node, 'node', hasTag('head')));
      node = node?.next;
      expect(node, equals(range.start));
      expect(
        node,
        isA<ChildNodeBoundary>().having((n) => n.element, 'element', element).having((n) => n.range, 'range', range),
      );
      node = node?.next;
      expect(node, isA<ChildNodeData>().having((n) => n.node, 'node', hasTag('body')));
      node = node?.next;
      expect(node, equals(range.end));
      expect(
        node,
        isA<ChildNodeBoundary>().having((n) => n.element, 'element', element).having((n) => n.range, 'range', range),
      );
      node = node?.next;
      expect(node, equals(children.lastNode));
      expect(node, isA<ChildNode>().having((n) => n.next, 'next', isNull));
    });

    test('wraps element multiple times (low then high)', () async {
      final r = await renderServerApp(
        Component.element(
          tag: 'html',
          children: [
            Component.element(tag: 'head', children: []),
            Builder(
              builder: (context) {
                return Component.element(tag: 'body', children: []);
              },
            ),
          ],
        ),
      );

      final root = r.renderObject as MarkupRenderObject;
      final children = root.children.first.children;

      // Check children using the underlying linked list
      ChildNode? node = children.firstNode;
      expect(node, isA<ChildNode>().having((n) => n.prev, 'prev', isNull));
      node = node.next;
      expect(node, isA<ChildNodeData>().having((n) => n.node, 'node', hasTag('head')));
      node = node?.next;
      expect(node, isA<ChildNodeData>().having((n) => n.node, 'node', hasTag('body')));
      node = node?.next;
      expect(node, equals(children.lastNode));
      expect(node, isA<ChildNode>().having((n) => n.next, 'next', isNull));

      final bodyElement = findTag(r, 'body')!;
      final builderElement = bodyElement.parent!;

      expect(bodyElement.renderObject, hasTag('body'));
      expect(builderElement, isA<BuildableElement>().having((e) => e.component, 'component', isA<Builder>()));

      final range = children.wrapElement(builderElement);

      // Check range using iterator
      expect(range, hasLength(1));
      expect(range.first, hasTag('body'));

      // Check changed children using the underlying linked list
      node = children.firstNode;
      expect(node, isA<ChildNode>().having((n) => n.prev, 'prev', isNull));
      node = node.next;
      expect(node, isA<ChildNodeData>().having((n) => n.node, 'node', hasTag('head')));
      node = node?.next;
      expect(node, equals(range.start));
      expect(
        node,
        isA<ChildNodeBoundary>()
            .having((n) => n.element, 'element', builderElement)
            .having((n) => n.range, 'range', range),
      );
      node = node?.next;
      expect(node, isA<ChildNodeData>().having((n) => n.node, 'node', hasTag('body')));
      node = node?.next;
      expect(node, equals(range.end));
      expect(
        node,
        isA<ChildNodeBoundary>()
            .having((n) => n.element, 'element', builderElement)
            .having((n) => n.range, 'range', range),
      );
      node = node?.next;
      expect(node, equals(children.lastNode));
      expect(node, isA<ChildNode>().having((n) => n.next, 'next', isNull));

      final range2 = children.wrapElement(bodyElement);

      // Check range using iterator
      expect(range2, hasLength(1));
      expect(range2.first, hasTag('body'));

      // Check changed children using the underlying linked list
      node = children.firstNode;
      expect(node, isA<ChildNode>().having((n) => n.prev, 'prev', isNull));
      node = node.next;
      expect(node, isA<ChildNodeData>().having((n) => n.node, 'node', hasTag('head')));
      node = node?.next;
      expect(node, equals(range.start));
      expect(
        node,
        isA<ChildNodeBoundary>()
            .having((n) => n.element, 'element', builderElement)
            .having((n) => n.range, 'range', range),
      );
      node = node?.next;
      expect(node, equals(range2.start));
      expect(
        node,
        isA<ChildNodeBoundary>()
            .having((n) => n.element, 'element', bodyElement)
            .having((n) => n.range, 'range', range2),
      );
      node = node?.next;
      expect(node, isA<ChildNodeData>().having((n) => n.node, 'node', hasTag('body')));
      node = node?.next;
      expect(node, equals(range2.end));
      expect(
        node,
        isA<ChildNodeBoundary>()
            .having((n) => n.element, 'element', bodyElement)
            .having((n) => n.range, 'range', range2),
      );
      node = node?.next;
      expect(node, equals(range.end));
      expect(
        node,
        isA<ChildNodeBoundary>()
            .having((n) => n.element, 'element', builderElement)
            .having((n) => n.range, 'range', range),
      );
      node = node?.next;
      expect(node, equals(children.lastNode));
      expect(node, isA<ChildNode>().having((n) => n.next, 'next', isNull));
    });

    test('wraps element multiple times (high then low)', () async {
      final r = await renderServerApp(
        Component.element(
          tag: 'html',
          children: [
            Component.element(tag: 'head', children: []),
            Builder(
              builder: (context) {
                return Component.element(tag: 'body', children: []);
              },
            ),
          ],
        ),
      );

      final root = r.renderObject as MarkupRenderObject;
      final children = root.children.first.children;

      // Check children using the underlying linked list
      ChildNode? node = children.firstNode;
      expect(node, isA<ChildNode>().having((n) => n.prev, 'prev', isNull));
      node = node.next;
      expect(node, isA<ChildNodeData>().having((n) => n.node, 'node', hasTag('head')));
      node = node?.next;
      expect(node, isA<ChildNodeData>().having((n) => n.node, 'node', hasTag('body')));
      node = node?.next;
      expect(node, equals(children.lastNode));
      expect(node, isA<ChildNode>().having((n) => n.next, 'next', isNull));

      final bodyElement = findTag(r, 'body')!;
      final builderElement = bodyElement.parent!;

      expect(bodyElement.renderObject, hasTag('body'));
      expect(builderElement, isA<BuildableElement>().having((e) => e.component, 'component', isA<Builder>()));

      final range = children.wrapElement(bodyElement);

      // Check range using iterator
      expect(range, hasLength(1));
      expect(range.first, hasTag('body'));

      // Check changed children using the underlying linked list
      node = children.firstNode;
      expect(node, isA<ChildNode>().having((n) => n.prev, 'prev', isNull));
      node = node.next;
      expect(node, isA<ChildNodeData>().having((n) => n.node, 'node', hasTag('head')));
      node = node?.next;
      expect(node, equals(range.start));
      expect(
        node,
        isA<ChildNodeBoundary>()
            .having((n) => n.element, 'element', bodyElement)
            .having((n) => n.range, 'range', range),
      );
      node = node?.next;
      expect(node, isA<ChildNodeData>().having((n) => n.node, 'node', hasTag('body')));
      node = node?.next;
      expect(node, equals(range.end));
      expect(
        node,
        isA<ChildNodeBoundary>()
            .having((n) => n.element, 'element', bodyElement)
            .having((n) => n.range, 'range', range),
      );
      node = node?.next;
      expect(node, equals(children.lastNode));
      expect(node, isA<ChildNode>().having((n) => n.next, 'next', isNull));

      final range2 = children.wrapElement(builderElement);

      // Check range using iterator
      expect(range2, hasLength(1));
      expect(range2.first, hasTag('body'));

      // Check changed children using the underlying linked list
      node = children.firstNode;
      expect(node, isA<ChildNode>().having((n) => n.prev, 'prev', isNull));
      node = node.next;
      expect(node, isA<ChildNodeData>().having((n) => n.node, 'node', hasTag('head')));
      node = node?.next;
      expect(node, equals(range2.start));
      expect(
        node,
        isA<ChildNodeBoundary>()
            .having((n) => n.element, 'element', builderElement)
            .having((n) => n.range, 'range', range2),
      );
      node = node?.next;
      expect(node, equals(range.start));
      expect(
        node,
        isA<ChildNodeBoundary>()
            .having((n) => n.element, 'element', bodyElement)
            .having((n) => n.range, 'range', range),
      );
      node = node?.next;
      expect(node, isA<ChildNodeData>().having((n) => n.node, 'node', hasTag('body')));
      node = node?.next;
      //expect(node, equals(range.end));
      expect(
        node,
        isA<ChildNodeBoundary>()
            .having((n) => n.element, 'element', bodyElement)
            .having((n) => n.range, 'range', range),
      );
      node = node?.next;
      expect(node, equals(range2.end));
      expect(
        node,
        isA<ChildNodeBoundary>()
            .having((n) => n.element, 'element', builderElement)
            .having((n) => n.range, 'range', range2),
      );
      node = node?.next;
      expect(node, equals(children.lastNode));
      expect(node, isA<ChildNode>().having((n) => n.next, 'next', isNull));
    });
  });
}

Matcher hasTag(String tag) => isA<MarkupRenderElement>().having((e) => e.tag, 'tag', tag);
