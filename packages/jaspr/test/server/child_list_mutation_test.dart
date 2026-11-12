@TestOn('vm')
library;

import 'dart:math';

import 'package:jaspr/server.dart';
import 'package:test/test.dart';

import 'child_list_helpers.dart';

void main() {
  group('child list mutations', () {
    test('inserts and moves children, rejecting missing anchors atomically', () {
      final list = MarkupRenderFragment().children;
      final a = MarkupRenderText('a', false);
      final b = MarkupRenderText('b', false);
      final c = MarkupRenderText('c', false);
      final missing = MarkupRenderText('missing', false);

      list.insertAfter(a);
      list.insertAfter(b, after: a);
      list.insertBefore(c, before: b);
      expectFlattened(list, [a, c, b]);
      expect(() => list.insertAfter(b, after: missing), throwsStateError);
      expectFlattened(list, [a, c, b]);
      expect(() => list.insertBefore(b, before: missing), throwsStateError);
      expectFlattened(list, [a, c, b]);
      list.insertAfter(b, after: b);
      list.insertBefore(b, before: b);
      expectFlattened(list, [a, c, b]);

      b.detach();
      b.detach();
      list.remove(missing);
      expectFlattened(list, [a, c]);
      list.insertBefore(b, before: c);
      expect(list.contains(b), isTrue);
      expectFlattened(list, [a, b, c]);
    });

    test('moves a child inserted in another list without changing its logical parent', () {
      final logical = MarkupRenderFragment();
      final source = logical.children;
      final target = MarkupRenderFragment().children;
      final child = logical.createChildRenderText('child');
      source.insertAfter(child);
      target.insertAfter(child);
      expect(source.contains(child), isFalse);
      expect(target.contains(child), isTrue);
      expect(child.owner, same(target));
      expect(child.parent, same(logical));
      source.remove(child);
      expect(target.contains(child), isTrue);
      expectFlattened(source, []);
      expectFlattened(target, [child]);
      child.detach();
      child.detach();
      expect(child.owner, isNull);
      expect(child.parent, same(logical));
    });

    test('tracks low-level insertions and keeps insertion inside groups', () {
      final list = MarkupRenderFragment().children;
      final a = MarkupRenderText('a', false);
      final b = MarkupRenderText('b', false);
      final start = MarkupRenderText('<!--start-->', true);
      final end = MarkupRenderText('<!--end-->', true);
      list.insertAfter(a);
      final captured = list.capture();
      list.insertAfter(captured);
      captured.children.insertAfter(start);
      captured.children.insertBefore(end);
      expect(list.contains(start), isTrue);
      expect(list.contains(end), isTrue);

      list.insertAfter(b, after: a);
      expect(captured.children.toList(), [start, a, b, end]);
      expectFlattened(list, [start, a, b, end]);
      start.detach();
      end.detach();
      expectFlattened(list, [a, b]);
    });

    test('transfers nested groups and supports mutation while detached', () {
      final parent = MarkupRenderFragment();
      final source = parent.children;
      final target = MarkupRenderFragment().children;
      final children = List.generate(5, (i) => parent.createChildRenderText('$i'));
      // Build nested output structurally instead of capturing arbitrary intervals.
      final nested = ChildGroup()..children.insertBefore(children[2]);
      final group = ChildGroup();
      group.children
        ..insertBefore(children[1])
        ..insertBefore(nested)
        ..insertBefore(children[3]);
      source
        ..insertBefore(children[0])
        ..insertBefore(group)
        ..insertBefore(children[4]);

      target.insertAfter(group);
      expectFlattened(source, [children[0], children[4]]);
      expectFlattened(target, children.sublist(1, 4));
      // Transferring a group doesn't update the `parent` of the render objects it contains.
      // That's the responsibility of `MarkupRenderObject.attach` and `remove`,
      // so it isn't asserted here.

      nested.detach();
      expect(target.contains(children[2]), isFalse);
      final marker = MarkupRenderText('<!--nested-->', true);
      nested.children.insertAfter(marker);
      expect(target.contains(marker), isFalse);
      source.insertBefore(nested);
      expectFlattened(source, [children[0], children[4], marker, children[2]]);
      expectFlattened(target, [children[1], children[3]]);
      expect(source.contains(marker), isTrue);

      // Entries inserted into a moved group must be found in its new list.
      final nextMarker = MarkupRenderText('<!--next-->', true);
      nested.children.insertBefore(nextMarker);
      expect(source.contains(nextMarker), isTrue);
      expect(target.contains(nextMarker), isFalse);
      source.insertAfter(children[1], after: children[0]);
      expect(target.contains(children[1]), isFalse);
      expectFlattened(source, [children[0], children[1], children[4], marker, children[2], nextMarker]);
      expectFlattened(target, [children[3]]);
    });

    test('preserves nested group handles when an enclosing group is detached', () {
      final source = MarkupRenderFragment().children;
      final target = MarkupRenderFragment().children;
      final children = List.generate(5, (i) => MarkupRenderText('$i', false));
      // Build nested output structurally instead of capturing arbitrary intervals.
      final inner = ChildGroup()..children.insertBefore(children[2]);
      final outer = ChildGroup();
      outer.children
        ..insertBefore(children[1])
        ..insertBefore(inner)
        ..insertBefore(children[3]);
      source
        ..insertBefore(children[0])
        ..insertBefore(outer)
        ..insertBefore(children[4]);
      target.insertAfter(outer);
      expectFlattened(source, [children[0], children[4]]);
      expectFlattened(target, children.sublist(1, 4));

      outer.detach();
      expectFlattened(target, []);
      final marker = MarkupRenderText('<!--detached-->', true);
      inner.children.insertAfter(marker);
      expect(inner.children.toList(), [marker, children[2]]);
      expect(outer.children.toList(), [children[1], marker, children[2], children[3]]);
      expect(source.contains(marker), isFalse);
      expect(target.contains(marker), isFalse);

      target.insertBefore(outer);
      expectFlattened(source, [children[0], children[4]]);
      expectFlattened(target, [children[1], marker, children[2], children[3]]);
      expect(target.contains(marker), isTrue);
    });

    test('moves groups within a list', () {
      final list = MarkupRenderFragment().children;
      final children = List.generate(4, (i) => MarkupRenderText('$i', false));
      final group = ChildGroup();
      group.children
        ..insertBefore(children[1])
        ..insertBefore(children[2]);
      list
        ..insertBefore(children[0])
        ..insertBefore(group)
        ..insertBefore(children[3]);
      list.insertAfter(group, after: children[3]);
      expectFlattened(list, [children[0], children[3], children[1], children[2]]);
      list.insertBefore(group, before: children[0]);
      expectFlattened(list, [children[1], children[2], children[0], children[3]]);
      list.insertAfter(group, after: children[0]);
      expectFlattened(list, children);

      expect(() => list.insertAfter(group, after: children[1]), throwsStateError);
      expect(() => list.insertBefore(group, before: children[2]), throwsStateError);
      expectFlattened(list, children);
    });

    test('transfers empty groups and supports inserting children after transfer', () {
      final source = MarkupRenderFragment().children;
      final target = MarkupRenderFragment().children;
      final captured = source.capture();
      target.insertAfter(captured);
      expectFlattened(source, []);
      expectFlattened(target, []);

      final a = MarkupRenderText('a', false);
      final b = MarkupRenderText('b', false);
      source.insertAfter(a);
      captured.children.insertAfter(b);
      expect(source.contains(a), isTrue);
      expect(target.contains(b), isTrue);
      source.insertAfter(captured);
      expect(source.contains(a), isTrue);
      expect(source.contains(b), isTrue);
      expect(target.contains(b), isFalse);
      expectFlattened(source, [b, a]);
      target.insertBefore(captured);
      expect(source.contains(a), isTrue);
      expect(target.contains(b), isTrue);
      expectFlattened(source, [a]);
      expectFlattened(target, [b]);
    });

    test('supports inserting into an empty group after transfer and detachment', () {
      final source = MarkupRenderFragment().children;
      final target = MarkupRenderFragment().children;
      final captured = source.capture();
      target.insertAfter(captured);
      expectFlattened(source, []);
      expectFlattened(target, []);

      captured.detach();
      expectFlattened(target, []);
      final child = MarkupRenderText('detached', false);
      captured.children.insertBefore(child);
      expect(captured.children.toList(), [child]);
      expect(source.contains(child), isFalse);
      expect(target.contains(child), isFalse);

      source.insertBefore(captured);
      expectFlattened(source, [child]);
      expectFlattened(target, []);
      expect(source.contains(child), isTrue);
    });

    test('contains looks inside groups but not fragments, unlike findWhere', () {
      final list = MarkupRenderFragment().children;
      final group = ChildGroup();
      final fragment = MarkupRenderFragment();
      final child = MarkupRenderText('child', false);
      fragment.children.insertAfter(child);
      group.children.insertAfter(fragment);
      list.insertAfter(group);
      expect(list.toList(), [fragment]);
      expect(list.contains(child), isFalse);
      expect(list.contains(fragment), isTrue);
      expect(list.findWhere((node) => node == child), same(child));
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
        final operation = random.nextInt(3);
        if (operation == 2) {
          list.remove(child);
          expected.remove(child);
        } else if (anchor != null && !expected.contains(anchor)) {
          expect(
            () => operation == 0 ? list.insertAfter(child, after: anchor) : list.insertBefore(child, before: anchor),
            throwsStateError,
          );
        } else if (anchor == child) {
          if (operation == 0) {
            list.insertAfter(child, after: anchor);
          } else {
            list.insertBefore(child, before: anchor);
          }
        } else {
          expected.remove(child);
          final index = anchor == null ? -1 : expected.indexOf(anchor);
          if (operation == 0) {
            list.insertAfter(child, after: anchor);
            expected.insert(index + 1, child);
          } else {
            list.insertBefore(child, before: anchor);
            expected.insert(index < 0 ? expected.length : index, child);
          }
        }
        expectFlattened(list, expected, reason: 'step $step');
      }
    });

    test('failed attach leaves both logical parent and physical owner unchanged', () {
      final source = MarkupRenderFragment();
      final target = MarkupRenderFragment();
      final child = source.createChildRenderText('child');
      source.attach(child);
      expect(() => target.attach(child, after: MarkupRenderText('missing', false)), throwsStateError);
      expect(child.parent, same(source));
      expect(child.owner, same(source.children));
      expect(source.children.toList(), [child]);
      expect(target.children, isEmpty);
    });

    test('capture moves all output into a detached group', () {
      final source = MarkupRenderFragment().children;
      final inner = ChildGroup();
      final leaf = MarkupRenderText('leaf', false);
      inner.children.insertBefore(leaf);
      source.insertBefore(inner);
      final captured = source.capture();
      expect(source, isEmpty);
      expect(source.firstNode, isNull);
      expect(source.lastNode, isNull);
      expect(captured.owner, isNull);
      expect(captured.children.toList(), [leaf]);
      expect(inner.owner, same(captured.children));
      expect(leaf.owner, same(inner.children));
      final empty = source.capture();
      captured.children.insertBefore(empty);
      final second = MarkupRenderText('second', false);
      empty.children.insertBefore(second);
      expect(captured.children.toList(), [leaf, second]);
      source.insertBefore(captured);
      expect(source.toList(), [leaf, second]);
    });

    test('rejects cycles through groups and render objects atomically', () {
      final root = MarkupRenderFragment();
      final outer = ChildGroup();
      final inner = ChildGroup();
      final element = MarkupRenderElement('div');
      root.children.insertBefore(outer);
      outer.children.insertBefore(inner);
      inner.children.insertBefore(element);
      expect(() => inner.children.insertBefore(outer), throwsStateError);
      expect(() => outer.children.insertBefore(outer), throwsStateError);
      expect(() => element.children.insertBefore(outer), throwsStateError);
      expect(() => element.children.insertBefore(root), throwsStateError);
      expect(root.children.toList(), [element]);
      expect(outer.owner, same(root.children));
      expect(inner.owner, same(outer.children));
      expect(element.children, isEmpty);
    });

    for (final tag in ['div', 'p', 'pre']) {
      test('groups do not change $tag formatting or significant whitespace', () {
        MarkupRenderElement build(bool grouped) {
          final element = MarkupRenderElement(tag);
          final output = grouped ? ChildGroup().children : element.children;
          output.insertBefore(MarkupRenderText('  first\n second ', false));
          final span = MarkupRenderElement('span');
          span.children.insertBefore(MarkupRenderText('x' * 110, false));
          output.insertBefore(span);
          output.insertBefore(MarkupRenderText(' tail ', false));
          if (grouped) element.children.insertBefore(output.capture());
          return element;
        }

        expect(build(true).renderToHtml(), build(false).renderToHtml());
      });
    }

    test('empty groups add no root lines or parsed-text formatting changes', () {
      RootMarkupRenderObject build(bool grouped) {
        final root = RootMarkupRenderObject();
        final div = MarkupRenderElement('div');
        div.children.insertBefore(MarkupRenderText('\n  ', false));
        div.children.insertBefore(MarkupRenderText('<escaped> & text', false));
        div.children.insertBefore(MarkupRenderText('<!--raw-->\n', true));
        root.children.insertBefore(div);
        root.children.insertBefore(MarkupRenderText('tail', false));
        if (grouped) {
          final captured = root.children.capture();
          root.children.insertBefore(ChildGroup());
          root.children.insertBefore(captured);
          root.children.insertBefore(ChildGroup());
          final inside = div.children.capture();
          div.children.insertBefore(ChildGroup());
          div.children.insertBefore(inside);
        }
        return root;
      }

      expect(build(true).renderToHtml(), build(false).renderToHtml());
    });

    test('deep structural groups iterate without recursive traversal', () {
      final text = MarkupRenderText('deep', false);
      ChildNode current = text;
      for (var depth = 0; depth < 12000; depth++) {
        final group = ChildGroup();
        group.children.insertBefore(current);
        current = group;
      }
      final root = RootMarkupRenderObject();
      root.children.insertBefore(current);
      expect(root.children.toList(), [text]);
      expect(root.children.contains(text), isTrue);
      expect(root.renderToHtml(), 'deep\n');
      final captured = root.children.capture();
      expect(root.children.contains(text), isFalse);
      expect(captured.children.toList(), [text]);
      expect(captured.children.contains(text), isTrue);
    });

    test('seeded group forest mutations match a separate ownership model', () {
      final random = Random(43781);
      final roots = List.generate(3, (_) => MarkupRenderFragment().children);
      final groups = List.generate(8, (_) => ChildGroup());
      final nodes = <ChildNode>[...groups, for (var i = 0; i < 24; i++) MarkupRenderText('$i', false)];
      final lists = [...roots, for (final group in groups) group.children];
      final expected = {for (final list in lists) list: <ChildNode>[]};
      final owners = <ChildNode, ChildList>{};
      bool containsList(ChildNode node, ChildList target) =>
          node is ChildGroup &&
          (identical(node.children, target) || expected[node.children]!.any((child) => containsList(child, target)));
      List<MarkupRenderObject> flatten(ChildList list) => [
        for (final child in expected[list]!)
          if (child is MarkupRenderObject) child else ...flatten((child as ChildGroup).children),
      ];
      for (var step = 0; step < 1200; step++) {
        final node = nodes[random.nextInt(nodes.length)];
        final target = lists[random.nextInt(lists.length)];
        if (containsList(node, target)) {
          expect(() => target.insertBefore(node), throwsStateError, reason: 'cycle at step $step');
        } else {
          final operation = random.nextInt(3);
          if (operation == 0) {
            node.detach();
            expected[owners.remove(node)]?.remove(node);
          } else {
            expected[owners[node]]?.remove(node);
            owners[node] = target;
            if (operation == 1) {
              target.insertBefore(node);
              expected[target]!.add(node);
            } else {
              target.insertAfter(node);
              expected[target]!.insert(0, node);
            }
          }
        }
        for (final list in lists) {
          expectStructure(list, expected[list]!, reason: 'step $step');
          expect(list.toList(), flatten(list), reason: 'flatten at step $step');
        }
      }
    });
  });
}
