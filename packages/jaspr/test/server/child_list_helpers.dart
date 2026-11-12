import 'package:jaspr/server.dart';
import 'package:test/test.dart';

/// Expects the direct entries of [list] to match [expected], with consistent links.
///
/// Each expected entry is a render object or group, a matcher, or
/// a `(ChildGroup, List<Object>)` record to also check the entries of that group.
void expectStructure(ChildList list, List<Object> expected, {String? reason}) {
  final entries = _linkedEntries(list, reason: reason);
  expect(entries, hasLength(expected.length), reason: reason);
  for (final (index, entry) in entries.indexed) {
    if (expected[index] case (final ChildGroup group, final List<Object> contents)) {
      expect(entry, same(group), reason: reason);
      expectStructure(group.children, contents, reason: reason);
    } else {
      // A matcher, or a render object or group compared by identity.
      expect(entry, expected[index], reason: reason);
    }
  }
}

/// Expects iterating [list] to yield [expected],
/// with consistent links in [list] and all its groups.
void expectFlattened(ChildList list, List<MarkupRenderObject> expected, {String? reason}) {
  void checkLinks(ChildList list) {
    for (final entry in _linkedEntries(list, reason: reason)) {
      if (entry is ChildGroup) checkLinks(entry.children);
    }
  }

  checkLinks(list);
  expect(list.toList(), expected, reason: reason);
}

/// Returns the direct entries of [list],
/// checking their links independently of its iterator.
List<ChildNode> _linkedEntries(ChildList list, {String? reason}) {
  final entries = <ChildNode>[];
  final seen = Set<ChildNode>.identity();
  for (ChildNode? node = list.firstNode; node != null; node = node.next) {
    expect(seen.add(node), isTrue, reason: 'Linked entries must not form a cycle. ${reason ?? ''}');
    expect(node.owner, same(list), reason: reason);
    expect(node.prev, same(entries.lastOrNull), reason: reason);
    entries.add(node);
  }
  expect(list.lastNode, same(entries.lastOrNull), reason: reason);
  return entries;
}
