part of 'markup_render_object.dart';

/// An entry in a [ChildList]. Either a [MarkupRenderObject] or a [ChildGroup].
///
/// An entry is in at most one list, and inserting it elsewhere moves it.
/// The list containing an entry is independent of its logical
/// [MarkupRenderObject.parent], which only [MarkupRenderObject.attach],
/// [MarkupRenderObject.remove], and the `createChildRender*` methods change.
sealed class ChildNode {
  ChildList? _owner;
  ChildNode? _prev;
  ChildNode? _next;

  /// The list directly containing this entry, or `null` if it is detached.
  ChildList? get owner => _owner;

  /// The entry before this one in [owner], or `null` if this is the first.
  ChildNode? get prev => _prev;

  /// The entry after this one in [owner], or `null` if this is the last.
  ChildNode? get next => _next;

  /// Removes this entry from its list. Does nothing if it is detached.
  void detach() {
    final owner = _owner;
    if (owner == null) return;
    if (_prev case final prev?) {
      prev._next = _next;
    } else {
      owner._first = _next;
    }
    if (_next case final next?) {
      next._prev = _prev;
    } else {
      owner._last = _prev;
    }
    _owner = null;
    _prev = null;
    _next = null;
  }
}

/// A transparent, movable sequence of entries.
///
/// Iterating a [ChildList] flattens groups without
/// adding output or changing formatting, unlike a [MarkupRenderFragment].
/// Groups can be nested and moved as a unit.
final class ChildGroup extends ChildNode {
  /// Creates an empty, detached group.
  ChildGroup();

  /// The entries of this group.
  late final ChildList children = ChildList._(this);
}

/// A group created by [ChildList.wrapElement] to wrap the output of [element].
final class _BoundaryGroup extends ChildGroup {
  _BoundaryGroup(this.element, this.subject, this.priority);

  /// The element whose output this group wraps.
  final Element element;

  /// The render object of [element] that this group was created around.
  final MarkupRenderObject subject;

  /// The priority [element] was wrapped with,
  /// which orders the groups wrapping the same element.
  final int priority;
}

/// The children of a render object or group, flattening groups during iteration.
///
/// Mutation during iteration is unsupported.
final class ChildList with Iterable<MarkupRenderObject> {
  ChildList._(this._host);

  final ChildNode _host;
  ChildNode? _first;
  ChildNode? _last;

  /// The first direct entry of this list, or `null` if it is empty.
  @visibleForTesting
  ChildNode? get firstNode => _first;

  /// The last direct entry of this list, or `null` if it is empty.
  @visibleForTesting
  ChildNode? get lastNode => _last;

  /// Inserts [node] after [after], or at the start if [after] is `null`.
  ///
  /// A non-null [after] must be in this list, possibly inside groups,
  /// and [node] is inserted into the same group.
  /// If [node] is already in a list, it's moved.
  /// Inserting [node] next to itself does nothing.
  ///
  /// Throws a [StateError] before changing anything if
  /// [after] isn't in this list or if this list is inside [node].
  void insertAfter(ChildNode node, {ChildNode? after}) {
    if (_prepareInsert(node, after) case final list?) {
      list._link(node, after, after == null ? list._first : after._next);
    }
  }

  /// Inserts [node] before [before], or at the end if [before] is `null`.
  ///
  /// Otherwise the same as [insertAfter].
  void insertBefore(ChildNode node, {ChildNode? before}) {
    if (_prepareInsert(node, before) case final list?) {
      list._link(node, before == null ? list._last : before._prev, before);
    }
  }

  /// Validates inserting [node] next to [anchor], detaches it,
  /// and returns the list directly containing [anchor].
  /// Returns `null` if [node] is [anchor], which is a no-op.
  ChildList? _prepareInsert(ChildNode node, ChildNode? anchor) {
    if (anchor != null && !_contains(anchor)) {
      throw StateError('Anchor is not in this child list.');
    }
    if (identical(node, anchor)) return null;
    final list = anchor?._owner ?? this;
    for (ChildNode? host = list._host; host != null; host = host._owner?._host) {
      if (identical(host, node)) throw StateError('Cannot move output into its own subtree.');
    }
    node.detach();
    return list;
  }

  /// Links the detached [node] into this list between [prev] and [next].
  void _link(ChildNode node, ChildNode? prev, ChildNode? next) {
    node._owner = this;
    node._prev = prev;
    node._next = next;
    if (prev == null) {
      _first = node;
    } else {
      prev._next = node;
    }
    if (next == null) {
      _last = node;
    } else {
      next._prev = node;
    }
  }

  /// Whether [node] is in this list, possibly inside groups.
  ///
  /// Takes time proportional to the group nesting depth.
  bool _contains(ChildNode node) {
    for (var list = node._owner; list != null;) {
      if (identical(list, this)) return true;
      final host = list._host;
      if (host is! ChildGroup) return false;
      list = host._owner;
    }
    return false;
  }

  /// Whether [element] is in this list, possibly inside groups, but not inside fragments.
  ///
  /// Takes time proportional to the group nesting depth.
  @override
  bool contains(Object? element) => element is MarkupRenderObject && _contains(element);

  /// Detaches [node] if it is in this list, possibly inside groups.
  void remove(ChildNode node) {
    if (_contains(node)) node.detach();
  }

  /// Moves all entries of this list into a new detached group,
  /// leaving this list empty.
  ChildGroup capture() {
    final group = ChildGroup();
    final target = group.children;
    for (var node = _first; node != null; node = node._next) {
      node._owner = target;
    }
    target._first = _first;
    target._last = _last;
    _first = null;
    _last = null;
    return group;
  }

  @override
  Iterator<MarkupRenderObject> get iterator => _ChildListIterator(_first);

  /// Returns the first render object of type [T] that satisfies [test].
  ///
  /// Searches inside groups and, if [visitFragments] is `true`, inside fragments.
  T? findWhere<T extends MarkupRenderObject>(bool Function(T) test, {bool visitFragments = true}) {
    for (final node in this) {
      if (node is T && test(node)) return node;
      if (visitFragments && node is MarkupRenderFragment) {
        if (node.children.findWhere<T>(test) case final found?) return found;
      }
    }
    return null;
  }

  /// Wraps [element]'s output in a new group and returns it.
  ///
  /// The output must be in this list, possibly inside groups, but not in a fragment.
  /// Groups around the same output nest by element depth, so ancestors enclose
  /// descendants. For the same element, higher [priority] groups enclose lower ones,
  /// and at equal priority the newest group is outermost.
  /// Entries already inserted into those groups, such as markers, don't affect this.
  @internal
  ChildGroup wrapElement(Element element, [int priority = 0]) {
    final subject = element.slot.target!.renderObject as MarkupRenderObject;
    if (!_contains(subject)) throw StateError('Element not found in child list.');

    // Enclose the groups around the same output that this group should enclose.
    ChildNode inner = subject;
    for (var list = subject._owner!; !identical(list, this); list = list._host._owner!) {
      if (list._host case final _BoundaryGroup group) {
        if (!identical(group.subject, subject)) break;
        final other = group.element;
        final encloses = identical(other, element) ? priority >= group.priority : element.depth <= other.depth;
        if (!encloses) break;
        inner = group;
      }
    }

    final group = _BoundaryGroup(element, subject, priority);
    insertBefore(group, before: inner);
    group.children.insertAfter(inner);
    return group;
  }

  /// Returns the outermost group created by [wrapElement] around [child],
  /// or [child] itself if it has none.
  ///
  /// Returns `null` if [child] isn't in this list, possibly inside groups.
  ChildNode? findWithBoundaries(MarkupRenderObject child) {
    if (!_contains(child)) return null;
    ChildNode outermost = child;
    for (var list = child._owner!; !identical(list, this); list = list._host._owner!) {
      if (list._host case final _BoundaryGroup group when identical(group.subject, child)) {
        outermost = group;
      }
    }
    return outermost;
  }
}

/// Iterates render objects, flattening groups without recursion.
final class _ChildListIterator implements Iterator<MarkupRenderObject> {
  _ChildListIterator(this._next);

  ChildNode? _next;
  List<ChildNode>? _pending;

  @override
  late MarkupRenderObject current;

  @override
  bool moveNext() {
    while (true) {
      switch (_next) {
        case null:
          final pending = _pending;
          if (pending == null || pending.isEmpty) return false;
          _next = pending.removeLast();
        case final MarkupRenderObject node:
          _next = node._next;
          current = node;
          return true;
        case final ChildGroup group:
          if (group._next case final next?) (_pending ??= []).add(next);
          _next = group.children._first;
      }
    }
  }
}
