import 'package:meta/meta.dart';

import '../framework/framework.dart';
import 'markup_render_object.dart';

/// A child-list node containing a render object.
final class ChildNodeData extends _BaseChildNode {
  ChildNodeData(this.node);

  final MarkupRenderObject node;
}

final class _ChildNodeBoundary extends _BaseChildNode {
  _ChildNodeBoundary(this.element, this.priority);

  final Element element;
  final int priority;
  late final ChildListRange range;
}

final class _BaseChildNode extends ChildNode {
  @override
  ChildNode? _prev;
  @override
  ChildNode? _next;
}

/// A node or contiguous range in a server render object's child list.
///
/// Child-list mutations do not update [MarkupRenderObject.parent].
sealed class ChildNode {
  ChildNode? get _prev;
  set _prev(ChildNode? prev);
  ChildNode? get prev => _prev;

  ChildNode? get _next;
  set _next(ChildNode? next);
  ChildNode? get next => _next;

  ChildNode get _start => this;
  ChildNode get _end => this;

  void insertNext(ChildNode node) {
    node._prev = this;
    node._next = next;
    next?._prev = node._end;
    _next = node._start;
  }

  void insertPrev(ChildNode node) {
    node._next = this;
    node._prev = prev;
    prev?._next = node._start;
    _prev = node._end;
  }

  void remove() {
    prev?._next = next;
    next?._prev = prev;
    _prev = null;
    _next = null;
  }
}

/// A range of child nodes that can be moved or removed together.
///
/// Created by [ChildList.range] or [ChildList.wrapElement].
/// Iteration yields render objects and skips boundary nodes.
final class ChildListRange extends ChildNode with Iterable<MarkupRenderObject> {
  ChildListRange._(this.start, this.end) {
    if (start case final _ChildNodeBoundary s) s.range = this;
    if (end case final _ChildNodeBoundary e) e.range = this;
  }

  /// The start boundary. Use [ChildNode.insertNext] to insert inside the range.
  final ChildNode start;

  /// The end boundary. Use [ChildNode.insertPrev] to insert inside the range.
  final ChildNode end;

  @override
  ChildNode? get _prev => start._prev;
  @override
  set _prev(ChildNode? prev) => start._prev = prev;

  @override
  ChildNode? get _next => end._next;
  @override
  set _next(ChildNode? next) => end._next = next;

  @override
  ChildNode get _start => start;
  @override
  ChildNode get _end => end;

  @override
  Iterator<MarkupRenderObject> get iterator => _ChildListIterator(start, end.next);
}

final class ChildList with Iterable<MarkupRenderObject> {
  @internal
  ChildList() {
    _first.insertNext(_last);
  }

  @visibleForTesting
  ChildNode get firstNode => _first;
  @visibleForTesting
  ChildNode get lastNode => _last;

  final ChildNode _first = _BaseChildNode();
  final ChildNode _last = _BaseChildNode();

  void insertAfter(MarkupRenderObject child, {MarkupRenderObject? after}) {
    insertNodeAfter(find(child) ?? ChildNodeData(child), after: after);
  }

  void insertNodeAfter(ChildNode node, {MarkupRenderObject? after}) {
    node.remove();
    final afterNode = find(after);
    if (afterNode == null) {
      _first.insertNext(node);
    } else {
      afterNode.insertNext(node);
    }
    assert(_first.prev == null && _last.next == null);
  }

  void insertBefore(MarkupRenderObject child, {MarkupRenderObject? before}) {
    insertNodeBefore(find(child) ?? ChildNodeData(child), before: before);
  }

  void insertNodeBefore(ChildNode node, {MarkupRenderObject? before}) {
    node.remove();
    final beforeNode = find(before);
    if (beforeNode == null) {
      _last.insertPrev(node);
    } else {
      beforeNode.insertPrev(node);
    }
    assert(_first.prev == null && _last.next == null);
  }

  ChildNodeData? find(MarkupRenderObject? child) {
    if (child == null) return null;
    return findWhere((n) => n == child, visitFragments: false);
  }

  void remove(MarkupRenderObject child) {
    find(child)?.remove();
  }

  @override
  Iterator<MarkupRenderObject> get iterator => _ChildListIterator(_first);

  ChildListRange range({ChildNode? startAfter, ChildNode? endBefore}) {
    final start = _BaseChildNode();
    final end = _BaseChildNode();

    (startAfter ?? _first).insertNext(start);
    (endBefore ?? _last).insertPrev(end);

    return ChildListRange._(start, end);
  }

  ChildNodeData? findWhere<T extends MarkupRenderObject>(bool Function(T) fn, {bool visitFragments = true}) {
    ChildNode? curr = _first;
    while (curr != null) {
      if (curr case ChildNodeData(:final node)) {
        if (node is T && fn(node)) {
          return curr;
        } else if (visitFragments && node is MarkupRenderFragment) {
          final found = node.children.findWhere<T>(fn);
          if (found != null) {
            return found;
          }
        }
      }
      curr = curr.next;
    }
    return null;
  }

  /// Wraps [element]'s rendered output in a new range and returns it.
  ///
  /// The output must already be a direct child of this list,
  /// not nested in a fragment.
  ///
  /// Adjacent ranges around the same output nest by element depth,
  /// so ancestor ranges enclose descendant ranges.
  /// For the same element, higher [priority] ranges enclose lower ones,
  /// and at equal priority the newest range is outermost.
  /// Nodes inserted next to the output, such as markers,
  /// can hide ranges from this ordering, so wrap before inserting them.
  @internal
  ChildListRange wrapElement(Element element, [int priority = 0]) {
    final node = find(element.slot.target!.renderObject as MarkupRenderObject);
    assert(node != null, 'Element not found in child list');

    /// Whether the new range should enclose the adjacent existing [boundary].
    bool encloses(_ChildNodeBoundary boundary) {
      // When wrapping the same element, higher priority wraps lower priority.
      if (boundary.element == element) return priority >= boundary.priority;
      assert(boundary.element.depth != element.depth);
      // Outer elements wrap inner elements.
      return element.depth <= boundary.element.depth;
    }

    // Expand both endpoints together to keep complete ranges enclosed,
    // even when extra contents make only one of their boundaries adjacent.
    ChildNode startBefore = node!;
    ChildNode endAfter = node;
    while (true) {
      if (startBefore.prev case final _ChildNodeBoundary prev when prev.range.start == prev && encloses(prev)) {
        startBefore = prev;
        endAfter = prev.range.end;
        continue;
      }

      if (endAfter.next case final _ChildNodeBoundary next when next.range.end == next && encloses(next)) {
        startBefore = next.range.start;
        endAfter = next;
        continue;
      }

      break;
    }

    final start = _ChildNodeBoundary(element, priority);
    final end = _ChildNodeBoundary(element, priority);

    startBefore.insertPrev(start);
    endAfter.insertNext(end);

    return ChildListRange._(start, end);
  }

  /// Returns [child]'s node together with the element boundaries around it.
  ///
  /// This is the outermost range created by [wrapElement] around [child],
  /// or [child]'s own node if it has no boundaries.
  /// Returns `null` if [child] isn't a direct child of this list.
  ChildNode? findWithBoundaries(MarkupRenderObject child) {
    final node = find(child);
    if (node == null) return null;

    ChildNode outermost = node;
    for (var curr = node.prev; curr != null; curr = curr.prev) {
      if (curr case final _ChildNodeBoundary boundary when boundary.element.slot.target?.renderObject == child) {
        outermost = boundary.range;
      }
    }
    return outermost;
  }
}

final class _ChildListIterator implements Iterator<MarkupRenderObject> {
  _ChildListIterator(ChildNode? first, [this._end]) : _current = first;

  ChildNode? _current;
  final ChildNode? _end;

  @override
  late MarkupRenderObject current;

  @override
  bool moveNext() {
    while (_current != null) {
      if (_current == _end) {
        return false;
      }
      try {
        if (_current case ChildNodeData(:final node)) {
          current = node;
          return true;
        }
      } finally {
        _current = _current!.next;
      }
    }
    return false;
  }
}
