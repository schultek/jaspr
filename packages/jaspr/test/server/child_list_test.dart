@TestOn('vm')
library;

import 'dart:async';

import 'package:jaspr/server.dart';
import 'package:jaspr_test/jaspr_test.dart';
import 'package:jaspr_test/server_test.dart';

// ignore: implementation_imports
import 'package:shelf/src/headers.dart';

import 'child_list_helpers.dart';

void main() {
  group('child list', () {
    Future<RenderObjectElement> renderServerApp(Component app) async {
      final binding = ServerAppBinding((
        url: '/',
        basePath: '/',
        headers: Headers.empty(),
      ), loadFile: (_) async => null);
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

      expectStructure(root.children, [hasTag('html')]);

      // Using findWhere
      expect(
        root.children.first.children.findWhere<MarkupRenderElement>((e) => e.tag == 'body'),
        hasTag('body'),
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
        hasTag('head'),
      );
      expect(
        root.children.first.children.findWhere<MarkupRenderElement>((e) => e.tag == 'head', visitFragments: false),
        isNull,
      );
    });

    for (final insertAtStart in [false, true]) {
      test('keeps boundaries nested with content at the ${insertAtStart ? 'start' : 'end'} boundary', () async {
        final r = await renderServerApp(.element(tag: 'div', children: []));
        final root = r.renderObject as MarkupRenderObject;
        final element = findTag(r, 'div')!;
        final inner = root.children.wrapElement(element);
        final marker = MarkupRenderText('marker', false);
        if (insertAtStart) {
          inner.children.insertAfter(marker);
        } else {
          inner.children.insertBefore(marker);
        }

        final outer = root.children.wrapElement(element, 1);
        expect(outer.children.firstNode, same(inner));
        expect(outer.children.lastNode, same(inner));
        expect(inner.owner, same(outer.children));
      });
    }

    test('wraps only inside the list it is called on', () async {
      final r = await renderServerApp(.element(tag: 'div', children: []));
      final root = (r.renderObject as MarkupRenderObject).children;
      final element = findTag(r, 'div')!;
      final boundary = root.wrapElement(element);
      // A higher priority would enclose the boundary if wrapped from the root list.
      final inner = boundary.children.wrapElement(element, 10);
      expectStructure(root, [
        (
          boundary,
          [
            (inner, [hasTag('div')]),
          ],
        ),
      ]);
    });

    test('encloses boundaries around plain groups that it should enclose', () async {
      final r = await renderServerApp(.element(tag: 'div', children: []));
      final root = (r.renderObject as MarkupRenderObject).children;
      final element = findTag(r, 'div')!;
      final boundary = root.wrapElement(element, 5);
      final captured = boundary.children.capture();
      boundary.children.insertAfter(captured);
      final outer = root.wrapElement(element, 10);
      final inner = root.wrapElement(element, 0);
      expectStructure(root, [
        (
          outer,
          [
            (
              boundary,
              [
                (
                  captured,
                  [
                    (inner, [hasTag('div')]),
                  ],
                ),
              ],
            ),
          ],
        ),
      ]);
      expect(root.findWithBoundaries(element.renderObject as MarkupRenderObject), same(outer));
    });

    test('does not enclose unrelated entries of plain groups', () async {
      final r = await renderServerApp(.element(tag: 'div', children: []));
      final root = (r.renderObject as MarkupRenderObject).children;
      final element = findTag(r, 'div')!;
      final captured = root.capture();
      root.insertBefore(captured);
      final unrelated = MarkupRenderText('unrelated', false);
      captured.children.insertBefore(unrelated);
      final boundary = root.wrapElement(element, 10);
      expectStructure(root, [
        (
          captured,
          [
            (boundary, [hasTag('div')]),
            unrelated,
          ],
        ),
      ]);
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

      expectStructure(children, [hasTag('head'), hasTag('body')]);

      final element = findTag(r, 'body')!;
      expect(element.renderObject, hasTag('body'));

      final boundary = children.wrapElement(element);

      // Check boundary using iterator
      expect(boundary.children.toList(), [hasTag('body')]);

      expectStructure(children, [
        hasTag('head'),
        (boundary, [hasTag('body')]),
      ]);

      // Check the lookup returns the outermost boundary
      expect(children.findWithBoundaries(element.renderObject as MarkupRenderObject), same(boundary));
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

      expectStructure(children, [hasTag('head'), hasTag('body')]);

      final element = findTag(r, 'body')!.parent!;
      expect(element, isA<BuildableElement>().having((e) => e.component, 'component', isA<Builder>()));

      final boundary = children.wrapElement(element);

      // Check boundary using iterator
      expect(boundary.children.toList(), [hasTag('body')]);

      expectStructure(children, [
        hasTag('head'),
        (boundary, [hasTag('body')]),
      ]);
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

      expectStructure(children, [hasTag('head'), hasTag('body')]);

      final bodyElement = findTag(r, 'body')!;
      final builderElement = bodyElement.parent!;

      expect(bodyElement.renderObject, hasTag('body'));
      expect(builderElement, isA<BuildableElement>().having((e) => e.component, 'component', isA<Builder>()));

      final boundary = children.wrapElement(builderElement);

      // Check boundary using iterator
      expect(boundary.children.toList(), [hasTag('body')]);

      expectStructure(children, [
        hasTag('head'),
        (boundary, [hasTag('body')]),
      ]);

      final boundary2 = children.wrapElement(bodyElement);

      // Check boundary using iterator
      expect(boundary2.children.toList(), [hasTag('body')]);

      expectStructure(children, [
        hasTag('head'),
        (
          boundary,
          [
            (boundary2, [hasTag('body')]),
          ],
        ),
      ]);

      // Check the lookup returns the outermost boundary
      expect(children.findWithBoundaries(bodyElement.renderObject as MarkupRenderObject), same(boundary));
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

      expectStructure(children, [hasTag('head'), hasTag('body')]);

      final bodyElement = findTag(r, 'body')!;
      final builderElement = bodyElement.parent!;

      expect(bodyElement.renderObject, hasTag('body'));
      expect(builderElement, isA<BuildableElement>().having((e) => e.component, 'component', isA<Builder>()));

      final boundary = children.wrapElement(bodyElement);

      // Check boundary using iterator
      expect(boundary.children.toList(), [hasTag('body')]);

      expectStructure(children, [
        hasTag('head'),
        (boundary, [hasTag('body')]),
      ]);

      final boundary2 = children.wrapElement(builderElement);

      // Check boundary using iterator
      expect(boundary2.children.toList(), [hasTag('body')]);

      expectStructure(children, [
        hasTag('head'),
        (
          boundary2,
          [
            (boundary, [hasTag('body')]),
          ],
        ),
      ]);

      // Check the lookup returns the outermost boundary
      expect(children.findWithBoundaries(bodyElement.renderObject as MarkupRenderObject), same(boundary2));
    });

    test('wraps same element multiple times with default priority', () async {
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

      expectStructure(children, [hasTag('head'), hasTag('body')]);

      final bodyElement = findTag(r, 'body')!;

      expect(bodyElement.renderObject, hasTag('body'));

      final boundary = children.wrapElement(bodyElement);

      // Check boundary using iterator
      expect(boundary.children.toList(), [hasTag('body')]);

      expectStructure(children, [
        hasTag('head'),
        (boundary, [hasTag('body')]),
      ]);

      final boundary2 = children.wrapElement(bodyElement);

      // Check boundary using iterator
      expect(boundary2.children.toList(), [hasTag('body')]);

      expectStructure(children, [
        hasTag('head'),
        (
          boundary2,
          [
            (boundary, [hasTag('body')]),
          ],
        ),
      ]);

      // Check the lookup returns the outermost boundary
      expect(children.findWithBoundaries(bodyElement.renderObject as MarkupRenderObject), same(boundary2));
    });

    test('wraps same element multiple times with out-of-order priority', () async {
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

      expectStructure(children, [hasTag('head'), hasTag('body')]);

      final bodyElement = findTag(r, 'body')!;

      expect(bodyElement.renderObject, hasTag('body'));

      final boundary = children.wrapElement(bodyElement, 1);

      // Check boundary using iterator
      expect(boundary.children.toList(), [hasTag('body')]);

      expectStructure(children, [
        hasTag('head'),
        (boundary, [hasTag('body')]),
      ]);

      final boundary2 = children.wrapElement(bodyElement, 0);

      // Check boundary using iterator
      expect(boundary2.children.toList(), [hasTag('body')]);

      expectStructure(children, [
        hasTag('head'),
        (
          boundary,
          [
            (boundary2, [hasTag('body')]),
          ],
        ),
      ]);

      // Check the lookup returns the outermost boundary
      expect(children.findWithBoundaries(bodyElement.renderObject as MarkupRenderObject), same(boundary));
    });

    // The ancestor boundary has the lowest priority,
    // the high boundary wraps the descendant with a higher priority,
    // and the low-a and low-b boundaries wrap the descendant with equal priorities.
    for (final order in _permutations(['ancestor', 'low-a', 'high', 'low-b'])) {
      test('nests boundaries by ancestry and priority for capture order ${order.join(', ')}', () async {
        late Element ancestor;
        late Element descendant;
        final r = await renderServerApp(
          Builder(
            builder: (context) {
              ancestor = context as Element;
              return Builder(
                builder: (context) {
                  descendant = context as Element;
                  return .element(tag: 'body', children: []);
                },
              );
            },
          ),
        );

        final root = r.renderObject as MarkupRenderObject;
        final boundaries = {
          for (final name in order)
            name: root.children.wrapElement(
              name == 'ancestor' ? ancestor : descendant,
              name == 'high' ? 10 : 0,
            ),
        };

        // Like render adapters, markers are inserted after all boundaries are captured and in reverse order.
        for (final name in order.reversed) {
          final boundary = boundaries[name]!;
          boundary.children.insertAfter(MarkupRenderText('<!--$name-->', true));
          boundary.children.insertBefore(MarkupRenderText('<!--/$name-->', true));
        }

        // Ancestry takes precedence over priority,
        // and the later of two equal-priority captures wraps the earlier one.
        final nesting = order.indexOf('low-a') < order.indexOf('low-b')
            ? ['ancestor', 'high', 'low-b', 'low-a']
            : ['ancestor', 'high', 'low-a', 'low-b'];
        final expected = [
          for (final name in nesting) '<!--$name-->',
          '<body></body>',
          for (final name in nesting.reversed) '<!--/$name-->',
        ];
        expect(root.children.map((node) => node.renderToHtml()), expected);

        final destination = MarkupRenderFragment();
        destination.children.insertBefore(boundaries['ancestor']!);
        expect(root.children, isEmpty);
        expect(destination.children.map((node) => node.renderToHtml()), expected);
        for (final (depth, name) in nesting.indexed) {
          expect(
            boundaries[name]!.children.map((node) => node.renderToHtml()),
            expected.sublist(depth, expected.length - depth),
            reason: 'Boundary $name must retain exactly its own contents after the move.',
          );
        }
      });
    }

    test('finds render objects with their outermost boundaries', () async {
      late Element aside;
      late Element outer;
      late Element inner;
      final r = await renderServerApp(
        .element(
          tag: 'html',
          children: [
            Builder(
              builder: (context) {
                aside = context as Element;
                return .element(tag: 'aside', children: []);
              },
            ),
            Builder(
              builder: (context) {
                outer = context as Element;
                return Builder(
                  builder: (context) {
                    inner = context as Element;
                    return .element(tag: 'head', children: []);
                  },
                );
              },
            ),
            .element(tag: 'main', children: []),
          ],
        ),
      );

      final root = r.renderObject as MarkupRenderObject;
      final children = root.children.first.children;
      final asideBoundary = children.wrapElement(aside);
      final innerBoundary = children.wrapElement(inner);
      final outerBoundary = children.wrapElement(outer);

      // Like render adapters, markers are inserted inside the boundaries.
      for (final boundary in [outerBoundary, innerBoundary, asideBoundary]) {
        boundary.children.insertAfter(MarkupRenderText('<!--marker-->', true));
        boundary.children.insertBefore(MarkupRenderText('<!--/marker-->', true));
      }

      MarkupRenderObject renderObjectOf(String tag) => findTag(r, tag)!.renderObject as MarkupRenderObject;

      expect(children.findWithBoundaries(renderObjectOf('aside')), same(asideBoundary));
      expect(children.findWithBoundaries(renderObjectOf('head')), same(outerBoundary));
      expect(children.findWithBoundaries(renderObjectOf('main')), same(renderObjectOf('main')));
      expect(children.findWithBoundaries(MarkupRenderText('missing', false)), isNull);
    });
  });
}

Matcher hasTag(String tag) => isA<MarkupRenderElement>().having((e) => e.tag, 'tag', tag);

Iterable<List<T>> _permutations<T>(List<T> values) sync* {
  if (values.isEmpty) {
    yield [];
    return;
  }
  for (final value in values) {
    for (final rest in _permutations(values.where((v) => v != value).toList())) {
      yield [value, ...rest];
    }
  }
}
