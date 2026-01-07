import 'dart:async';

import '../../framework/framework.dart';
import '../child_nodes.dart';
import '../markup_render_object.dart';
import '../server_binding.dart';

export '../child_nodes.dart' show ChildListRange, ChildNodeData;

abstract class ElementBoundaryAdapter extends RenderAdapter {
  ElementBoundaryAdapter(this.element, {this.priority = 0});

  final Element element;
  final int priority;

  late ChildListRange range;

  @override
  FutureOr<void> prepare() {
    final parent = element.parentRenderObjectElement!.renderObject as MarkupRenderObject;
    range = parent.children.wrapElement(element, priority);
    prepareBoundary(range);
  }

  @override
  void apply(MarkupRenderObject root) {
    return applyBoundary(range);
  }

  void prepareBoundary(ChildListRange range) {}
  void applyBoundary(ChildListRange range) {}
}
