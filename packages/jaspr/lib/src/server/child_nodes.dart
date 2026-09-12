import 'package:meta/meta.dart';

import '../framework/framework.dart';
import 'markup_render_object.dart';

class ChildNodeData extends BaseChildNode {
  ChildNodeData(this.node);

  final MarkupRenderObject node;
}

class ChildNodeBoundary extends BaseChildNode {
  ChildNodeBoundary(this.element, [this.priority = 0]);

  final Element element;
  final int priority;
  late final ChildListRange range;
}

class BaseChildNode extends ChildNode {
  @override
  ChildNode? _prev;
  @override
  ChildNode? _next;
}

sealed class ChildNode {
  ChildNode? get _prev;
  set _prev(ChildNode? prev);
  ChildNode? get prev => _prev;

  ChildNode? get _next;
  set _next(ChildNode? next);
  ChildNode? get next => _next;

  ChildNode get _start => this;
  ChildNode get _end => this;

  void insertNext(ChildNode? node) {
    node?._prev = this;
    node?._next = next;
    next?._prev = node?._end;
    _next = node?._start;
  }

  void insertPrev(ChildNode? node) {
    node?._next = this;
    node?._prev = prev;
    prev?._next = node?._start;
    _prev = node?._end;
  }

  void remove() {
    prev?._next = next;
    next?._prev = prev;
    _prev = null;
    _next = null;
  }
}

class ChildListRange extends ChildNode with Iterable<MarkupRenderObject> {
  ChildListRange(this.start, this.end) {
    if (start case final ChildNodeBoundary s) s.range = this;
    if (end case final ChildNodeBoundary e) e.range = this;
  }

  final ChildNode start;
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
  Iterator<MarkupRenderObject> get iterator => ChildListIterator(start, end.next);

  Iterable<ChildNode> get nodes sync* {
    ChildNode? curr = start;

    while (curr != null && curr != end) {
      yield curr;
      curr = curr.next;
    }

    yield end;
  }
}

class ChildList with Iterable<MarkupRenderObject> {
  ChildList(this.parent) {
    _first.insertNext(_last);
  }

  final MarkupRenderObject parent;

  @visibleForTesting
  ChildNode get firstNode => _first;
  @visibleForTesting
  ChildNode get lastNode => _last;

  final ChildNode _first = BaseChildNode();
  final ChildNode _last = BaseChildNode();

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
  Iterator<MarkupRenderObject> get iterator => ChildListIterator(_first);

  ChildListRange range({ChildNode? startAfter, ChildNode? endBefore}) {
    final start = BaseChildNode();
    final end = BaseChildNode();

    (startAfter ?? _first).insertNext(start);
    (endBefore ?? _last).insertPrev(end);

    return ChildListRange(start, end);
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
  /// Ranges around the same output nest by element depth,
  /// so ancestor ranges enclose descendant ranges.
  /// For the same element, higher [priority] ranges enclose lower ones,
  /// and at equal priority the newest range is outermost.
  ChildListRange wrapElement(Element element, [int priority = 0]) {
    final node = find(element.slot.target!.renderObject as MarkupRenderObject);
    assert(node != null, 'Element not found in child list');

    /// Whether the new range should enclose the adjacent existing [boundary].
    bool encloses(ChildNodeBoundary boundary) {
      if (boundary.element == element) return priority >= boundary.priority;
      assert(boundary.element.depth != element.depth);
      return element.depth <= boundary.element.depth;
    }

    // Walk backward past adjacent range starts to find where the new range should open.
    ChildNode startBefore = node!;
    while (true) {
      final prev = startBefore.prev;
      if (prev is! ChildNodeBoundary || prev.range.start != prev || !encloses(prev)) break;
      startBefore = prev;
    }

    // Walk forward past adjacent range ends to find where the new range should close.
    ChildNode endAfter = node;
    while (true) {
      final next = endAfter.next;
      if (next is! ChildNodeBoundary || next.range.end != next || !encloses(next)) break;
      endAfter = next;
    }

    final start = ChildNodeBoundary(element, priority);
    final end = ChildNodeBoundary(element, priority);

    startBefore.insertPrev(start);
    endAfter.insertNext(end);

    return ChildListRange(start, end);
  }
}

class ChildListIterator implements Iterator<MarkupRenderObject> {
  ChildListIterator(ChildNode? first, [this._end]) : _current = first;

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
