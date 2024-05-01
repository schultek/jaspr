import '../framework/framework.dart';
import 'markup_render_object.dart';

class ChildNodeData extends BaseChildNode {
  ChildNodeData(this.node);

  final MarkupRenderObject node;
}

class ChildNodeBoundary extends BaseChildNode {
  ChildNodeBoundary(this.element);

  final Element element;
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
    if (start case ChildNodeBoundary s) s.range = this;
    if (end case ChildNodeBoundary e) e.range = this;
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
}

class ChildList with Iterable<MarkupRenderObject> {
  ChildList(this.parent) {
    _first.insertNext(_last);
  }

  final MarkupRenderObject parent;

  final ChildNode _first = BaseChildNode();
  final ChildNode _last = BaseChildNode();

  void insertAfter(MarkupRenderObject child, {MarkupRenderObject? after}) {
    insertNodeAfter(find(child) ?? ChildNodeData(child), after: after);
  }

  void insertNodeAfter(ChildNode node, {MarkupRenderObject? after}) {
    node.remove();
    var afterNode = find(after);
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
    var beforeNode = find(before);
    if (beforeNode == null) {
      _last.insertPrev(node);
    } else {
      beforeNode.insertPrev(node);
    }
    assert(_first.prev == null && _last.next == null);
  }

  ChildNodeData? find(MarkupRenderObject? child) {
    if (child == null) return null;
    return findWhere((n) => n == child);
  }

  void remove(MarkupRenderObject child) {
    find(child)?.remove();
  }

  @override
  Iterator<MarkupRenderObject> get iterator => ChildListIterator(_first);

  ChildListRange range({ChildNode? startAfter, ChildNode? endBefore}) {
    var start = BaseChildNode();
    var end = BaseChildNode();

    (startAfter ?? _first).insertNext(start);
    (endBefore ?? _last).insertPrev(end);

    return ChildListRange(start, end);
  }

  ChildNodeData? findWhere(bool Function(MarkupRenderObject) fn) {
    ChildNode? curr = _first;
    while (curr != null) {
      if (curr case ChildNodeData(:var node) when fn(node)) {
        return curr;
      }
      curr = curr.next;
    }
    return null;
  }

  ChildListRange wrapElement(Element element) {
    Element? prevElem = element.prevAncestorSibling;
    while (prevElem != null && prevElem.lastRenderObjectElement == null) {
      prevElem = prevElem.prevAncestorSibling;
    }

    var startAfter = findWhere((n) => n == prevElem?.lastRenderObjectElement?.renderObject) ?? _first;
    var endAfter = findWhere((n) => n == element.lastRenderObjectElement?.renderObject) ?? _last.prev!;

    while (true) {
      if (startAfter.next case ChildNodeBoundary startNext) {
        if (startNext.element.depth < element.depth) {
          startAfter = startNext;
          continue;
        } else if (startNext.element.depth == element.depth) {
          if (isOrdered(startNext.element, element)) {
            startAfter = startNext.range.end;
            continue;
          }
        }
      }
      break;
    }
    while (true) {
      if (endAfter.next case ChildNodeBoundary endNext) {
        if (endNext.element.depth > element.depth) {
          endAfter = endNext;
          continue;
        } else if (endNext.element.depth == element.depth) {
          if (isOrdered(endNext.element, element)) {
            endAfter = endNext.range.end;
            continue;
          }
        }
      }
      break;
    }

    var start = ChildNodeBoundary(element);
    var end = ChildNodeBoundary(element);

    startAfter.insertNext(start);
    endAfter.insertNext(end);

    var range = ChildListRange(start, end);
    return range;
  }

  bool isOrdered(Element a, Element b) {
    assert(a.depth == b.depth);
    late Element parentA, parentB;
    a.visitAncestorElements((e) {
      parentA = e;
      return false;
    });
    b.visitAncestorElements((e) {
      parentB = e;
      return false;
    });
    if (parentA != parentB) {
      return isOrdered(parentA, parentB);
    }

    Element currA = a, currB = b;
    while (true) {
      var prevA = currA.prevSibling, prevB = currB.prevSibling;
      if (prevB == a || prevA == null) {
        return true;
      }
      if (prevA == b || prevB == null) {
        return false;
      }
      currA = prevA;
      currB = prevB;
    }
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
        if (_current case ChildNodeData(:var node)) {
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
