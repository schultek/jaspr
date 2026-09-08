@TestOn('vm')
library;

import 'dart:math';

import 'package:jaspr/server.dart';
import 'package:jaspr/src/server/child_nodes.dart';
import 'package:test/test.dart';

void main() {
  group('child list mutations', () {
    test('inserts, moves, and removes children with missing anchors', () {
      final list = MarkupRenderFragment().children;
      final a = MarkupRenderText('a', false);
      final b = MarkupRenderText('b', false);
      final c = MarkupRenderText('c', false);
      final missing = MarkupRenderText('missing', false);

      list.insertAfter(a);
      list.insertAfter(b, after: a);
      list.insertBefore(c, before: b);
      _expectList(list, [a, c, b]);
      list.insertAfter(b, after: missing);
      _expectList(list, [b, a, c]);
      list.insertBefore(b, before: missing);
      _expectList(list, [a, c, b]);

      // TODO: Decide how inserting a child relative to itself should behave, then test it here.
      // The child is currently detached before its anchor is resolved,
      // so it behaves like a missing anchor and is inserted at the start or end of the list.
      // Other options are leaving the list unchanged or asserting against it.

      final node = list.find(b)!;
      node.remove();
      node.remove();
      list.remove(missing);
      _expectList(list, [a, c]);
      list.insertNodeBefore(node, before: c);
      expect(list.find(b), same(node));
      _expectList(list, [a, b, c]);
    });

    test('tracks membership separately when an object occurs in different lists', () {
      final source = MarkupRenderFragment().children;
      final target = MarkupRenderFragment().children;
      final child = MarkupRenderText('child', false);
      source.insertAfter(child);
      target.insertAfter(child);
      final targetNode = target.find(child)!;
      source.remove(child);
      expect(target.find(child), same(targetNode));
      _expectList(source, []);
      _expectList(target, [child]);
    });

    test('tracks low-level insertions and keeps insertion inside range boundaries', () {
      final list = MarkupRenderFragment().children;
      final a = MarkupRenderText('a', false);
      final b = MarkupRenderText('b', false);
      final start = ChildNodeData(MarkupRenderText('<!--start-->', true));
      final end = ChildNodeData(MarkupRenderText('<!--end-->', true));
      list.insertAfter(a);
      final range = list.range();
      range.start.insertNext(start);
      range.end.insertPrev(end);
      expect(list.find(start.node), same(start));
      expect(list.find(end.node), same(end));

      list.insertAfter(b, after: a);
      expect(range.toList(), [start.node, a, b, end.node]);
      _expectList(list, [start.node, a, b, end.node]);
      start.remove();
      end.remove();
      _expectList(list, [a, b]);
    });

    test('transfers nested ranges and supports mutation while detached', () {
      final parent = MarkupRenderFragment();
      final source = parent.children;
      final target = MarkupRenderFragment().children;
      final children = List.generate(5, (i) => parent.createChildRenderText('$i'));
      for (final child in children) {
        source.insertBefore(child);
      }
      final range = source.range(startAfter: source.find(children[0]), endBefore: source.find(children[4]));
      final nested = source.range(startAfter: source.find(children[1]), endBefore: source.find(children[3]));

      target.insertNodeAfter(range);
      _expectList(source, [children[0], children[4]]);
      _expectList(target, children.sublist(1, 4));
      // Transferring a range doesn't update the `parent` of the render objects it contains.
      // That's the responsibility of `MarkupRenderObject.attach` and `remove`,
      // so it isn't asserted here.

      nested.remove();
      expect(target.find(children[2]), isNull);
      final marker = ChildNodeData(MarkupRenderText('<!--nested-->', true));
      nested.start.insertNext(marker);
      expect(target.find(marker.node), isNull);
      source.insertNodeBefore(nested);
      _expectList(source, [children[0], children[4], marker.node, children[2]]);
      _expectList(target, [children[1], children[3]]);
      expect(source.find(marker.node), same(marker));

      // Nodes inserted through transferred boundaries must be found in the destination list.
      final nextMarker = ChildNodeData(MarkupRenderText('<!--next-->', true));
      nested.end.insertPrev(nextMarker);
      expect(source.find(nextMarker.node), same(nextMarker));
      expect(target.find(nextMarker.node), isNull);
      source.insertNodeAfter(target.find(children[1])!, after: children[0]);
      expect(target.find(children[1]), isNull);
      _expectList(source, [children[0], children[1], children[4], marker.node, children[2], nextMarker.node]);
      _expectList(target, [children[3]]);
    });

    test('moves ranges within a list', () {
      final list = MarkupRenderFragment().children;
      final children = List.generate(4, (i) => MarkupRenderText('$i', false));
      for (final child in children) {
        list.insertBefore(child);
      }
      final range = list.range(startAfter: list.find(children[0]), endBefore: list.find(children[3]));
      list.insertNodeAfter(range, after: children[3]);
      _expectList(list, [children[0], children[3], children[1], children[2]]);
      list.insertNodeBefore(range, before: children[0]);
      _expectList(list, [children[1], children[2], children[0], children[3]]);
      list.insertNodeAfter(range, after: children[0]);
      _expectList(list, children);

      // TODO: Decide how moving a range relative to an anchor
      // inside that range should behave, then test it here.
      // The range is currently detached before its anchor is resolved,
      // so it behaves like a missing anchor and is inserted at the start or end of the list.
      // Other options are leaving the list unchanged or asserting against it.
    });

    test('transfers empty ranges and supports inserting children after transfer', () {
      final source = MarkupRenderFragment().children;
      final target = MarkupRenderFragment().children;
      final range = source.range();
      target.insertNodeAfter(range);
      _expectList(source, []);
      _expectList(target, []);

      final a = ChildNodeData(MarkupRenderText('a', false));
      final b = ChildNodeData(MarkupRenderText('b', false));
      source.insertNodeAfter(a);
      range.start.insertNext(b);
      expect(source.find(a.node), same(a));
      expect(target.find(b.node), same(b));
      source.insertNodeAfter(range);
      expect(source.find(a.node), same(a));
      expect(source.find(b.node), same(b));
      expect(target.find(b.node), isNull);
      _expectList(source, [b.node, a.node]);
      target.insertNodeBefore(range);
      expect(source.find(a.node), same(a));
      expect(target.find(b.node), same(b));
      _expectList(source, [a.node]);
      _expectList(target, [b.node]);
    });

    test('find remains shallow while findWhere visits fragments', () {
      final list = MarkupRenderFragment().children;
      final fragment = MarkupRenderFragment();
      final child = MarkupRenderText('child', false);
      fragment.children.insertAfter(child);
      list.insertAfter(fragment);
      expect(list.find(child), isNull);
      expect(list.find(fragment)?.node, same(fragment));
      expect(list.findWhere((node) => node == child)?.node, same(child));
      expect(list.findWhere((node) => node == child, visitFragments: false), isNull);
    });

    test('matches a list model through repeated insertions, moves, and removals', () {
      final random = Random(42);
      final list = MarkupRenderFragment().children;
      final objects = List.generate(32, (i) => MarkupRenderText('$i', false));
      final expected = <MarkupRenderObject>[];
      for (var step = 0; step < 1000; step++) {
        final child = objects[random.nextInt(objects.length)];
        final anchor = random.nextInt(4) == 0 ? null : objects[random.nextInt(objects.length)];
        // TODO: Model inserting a child relative to itself once its behavior is decided.
        // The child is currently detached before its anchor is resolved,
        // so it behaves like a missing anchor and is inserted at the start or end of the list.
        if (anchor == child) continue;
        expected.remove(child);
        final index = anchor == null ? -1 : expected.indexOf(anchor);
        switch (random.nextInt(3)) {
          case 0:
            list.insertAfter(child, after: anchor);
            expected.insert(index + 1, child);
          case 1:
            list.insertBefore(child, before: anchor);
            expected.insert(index < 0 ? expected.length : index, child);
          case 2:
            list.remove(child);
        }
        _expectList(list, expected, reason: 'step $step');
      }
    });
  });
}

void _expectList(ChildList list, List<MarkupRenderObject> expected, {String? reason}) {
  final visited = Set<ChildNode>.identity();
  ChildNode? previous;
  ChildNode? current = list.firstNode;
  while (current != null) {
    expect(visited.add(current), isTrue, reason: 'linked list contains a cycle');
    expect(current.prev, same(previous), reason: reason);
    previous = current;
    current = current.next;
  }
  expect(previous, same(list.lastNode), reason: reason);
  // Render objects don't override `==`, so `equals` compares them by identity.
  expect(list.toList(), equals(expected), reason: reason);
}
