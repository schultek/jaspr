import '../framework/framework.dart';
import 'markup_render_object.dart';

class ChildNodeData extends ChildNode {
  ChildNodeData(this.node);

  final MarkupRenderObject node;

  @override
  String get self => '<${node.tag ?? 'txt'}>';
}

class ChildNodeBoundary extends ChildNode {
  ChildNodeBoundary(this.element);

  final Element element;

  @override
  String get self => '{${element.depth}:${element.runtimeType}}';
}

class ChildNode {
  ChildNode? _prev;
  ChildNode? get prev => _prev;

  ChildNode? _next;
  ChildNode? get next => _next;

  void insertNext(ChildNode? node) {
    node?._prev = this;
    node?._next = next;
    next?._prev = node;
    _next = node;
  }

  void insertPrev(ChildNode? node) {
    node?._next = this;
    node?._prev = prev;
    prev?._next = node;
    _prev = node;
  }

  void insertRangeNext(ChildListRange range) {
    range.start._prev = this;
    range.end._next = next;
    next?._prev = range.end;
    _next = range.start;
  }

  void remove() {
    prev?._next = next;
    next?._prev = prev;
    _prev = null;
    _next = null;
  }

  String get str => '$self${next != null ? ', ${next!.str}' : ''}';
  String get self => '($hashCode)';
}

class ChildListRange {
  ChildListRange(this.start, this.end);

  final ChildNode start;
  final ChildNode end;

  String get str {
    var l = <String>[];
    var curr = start;
    while (curr != end) {
      l.add(curr.self);
      curr = curr.next!;
    }
    l.add(curr.self);
    return '[${l.join(', ')}]';
  }

  void remove() {
    start.prev?._next = end.next;
    end.next?._prev = start.prev;
    start._prev = null;
    end._next = null;
  }
}

class ChildList with Iterable<MarkupRenderObject> {
  ChildList(this.parent) {
    _first.insertNext(_last);
  }

  final MarkupRenderObject parent;

  final ChildNode _first = ChildNode();
  final ChildNode _last = ChildNode();

  String get str => '[${_first.str}]';

  void insertAfter(MarkupRenderObject child, {MarkupRenderObject? after}) {
    var node = find(child);
    if (node != null) {
      node.remove();
    } else {
      node = ChildNodeData(child);
    }
    var afterNode = find(after);
    if (afterNode == null) {
      _first.insertNext(node);
    } else {
      afterNode.insertNext(node);
    }
    assert(_first.prev == null && _last.next == null);
  }

  void insertBefore(MarkupRenderObject child, {MarkupRenderObject? before}) {
    var node = find(child);
    if (node != null) {
      node.remove();
    } else {
      node = ChildNodeData(child);
    }
    var beforeNode = find(before);
    if (beforeNode == null) {
      _last.insertPrev(node);
    } else {
      beforeNode.insertPrev(node);
    }
    assert(_first.prev == null && _last.next == null);
  }

  void insertRangeAfter(ChildListRange range, {MarkupRenderObject? after}) {
    range.remove();
    var afterNode = find(after);
    if (afterNode == null) {
      _first.insertRangeNext(range);
    } else {
      afterNode.insertRangeNext(range);
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
    var start = ChildNode();
    var end = ChildNode();

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
    var endBefore = findWhere((n) => n == element.lastRenderObjectElement?.renderObject)?.next ?? _last;

    while (true) {
      if (startAfter.next case ChildNodeBoundary n when n.element.depth < element.depth) {
        startAfter = n;
      } else {
        break;
      }
    }
    while (true) {
      if (endBefore.next case ChildNodeBoundary n when n.element.depth > element.depth) {
        endBefore = n;
      } else {
        break;
      }
    }

    var start = ChildNodeBoundary(element);
    var end = ChildNodeBoundary(element);

    startAfter.insertNext(start);
    endBefore.insertPrev(end);

    return ChildListRange(start, end);
  }
}

class ChildListIterator implements Iterator<MarkupRenderObject> {
  ChildListIterator(ChildNode? first) : _current = first;

  ChildNode? _current;

  @override
  late MarkupRenderObject current;

  @override
  bool moveNext() {
    while (_current != null) {
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
