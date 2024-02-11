import 'dart:async';

import '../../framework/framework.dart';
import '../markup_render_object.dart';
import '../server_binding.dart';

abstract class ElementBoundaryAdapter extends RenderAdapter {
  ElementBoundaryAdapter(this.element);

  final Element element;

  @override
  FutureOr<void> apply(MarkupRenderObject root) {
    Element? prevElem = element.prevAncestorSibling;
    while (prevElem != null && prevElem.lastRenderObjectElement == null) {
      prevElem = prevElem.prevAncestorSibling;
    }

    var parent = element.parentRenderObjectElement!.renderObject as MarkupRenderObject;
    var beforeFirst = prevElem?.lastRenderObjectElement?.renderObject as MarkupRenderObject?;
    var last = element.lastRenderObjectElement?.renderObject as MarkupRenderObject?;

    assert((beforeFirst?.parent ?? parent) == parent && (last?.parent ?? parent) == parent);

    var startIndex = beforeFirst == null ? 0 : parent.children.indexOf(beforeFirst) + 1;
    var endIndex = last == null ? parent.children.length : parent.children.indexOf(last) + 1;

    return processBoundary(parent, startIndex, endIndex);
  }

  FutureOr<void> processBoundary(MarkupRenderObject parent, int start, int end);
}
