import 'dart:async';

import '../../framework/framework.dart';
import '../child_nodes.dart';
import '../markup_render_object.dart';
import '../server_binding.dart';

abstract class ElementBoundaryAdapter extends RenderAdapter {
  ElementBoundaryAdapter(this.element);

  final Element element;

  late ChildListRange range;

  @override
  FutureOr<void> prepare() {
    var parent = element.parentRenderObjectElement!.renderObject as MarkupRenderObject;
    range = parent.children.wrapElement(element);
  }

  @override
  void apply(MarkupRenderObject root) {
    return processBoundary(range);
  }

  void processBoundary(ChildListRange range);
}
