// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:jaspr/jaspr.dart';

/// Provides an iterable that efficiently returns all the elements
/// rooted at the given element.
Iterable<Element> collectAllElementsFrom(Element element) {
  return _DepthFirstChildIterator(element).collect();
}

extension CollectIterator<E> on Iterator<E> {
  Iterable<E> collect() {
    final l = <E>[];
    while (moveNext()) {
      l.add(current);
    }
    return l;
  }
}

/// Provides a recursive, efficient, depth first search of an element tree.
class _DepthFirstChildIterator implements Iterator<Element> {
  _DepthFirstChildIterator(Element element) {
    _fillChildren(element);
  }

  late Element _current;

  final List<Element> _stack = <Element>[];

  @override
  Element get current => _current;

  @override
  bool moveNext() {
    if (_stack.isEmpty) return false;

    _current = _stack.removeLast();
    _fillChildren(_current);

    return true;
  }

  void _fillChildren(Element element) {
    final List<Element> reversed = <Element>[];
    element.visitChildren(reversed.add);
    while (reversed.isNotEmpty) {
      _stack.add(reversed.removeLast());
    }
  }
}
