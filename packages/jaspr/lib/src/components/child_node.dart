import '../../jaspr.dart';

class FindChildNode extends ChildNodeComponent {
  FindChildNode({this.onNodeRendered, this.onNodeAttached, required super.child});

  final void Function(RenderElement)? onNodeRendered;
  final void Function(RenderElement)? onNodeAttached;

  @override
  void didRenderNode(RenderElement node) => onNodeRendered?.call(node);

  @override
  void didAttachNode(RenderElement node) => onNodeAttached?.call(node);

  @override
  bool hasChanged(covariant ChildNodeComponent oldComponent) {
    return false;
  }
}

abstract class ChildNodeComponent extends StatelessComponent {
  const ChildNodeComponent({required this.child, super.key});

  final Component child;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield RenderScope(
      delegate: ChildNodeDelegate(this),
      child: child,
    );
  }

  void didRenderNode(RenderElement node);
  void didAttachNode(RenderElement node);

  bool hasChanged(covariant ChildNodeComponent oldComponent);
}

class ChildNodeDelegate extends RenderDelegate {
  ChildNodeDelegate(this.component);

  final ChildNodeComponent component;

  @override
  void renderNode(RenderElement node, String tag, String? id, List<String>? classes, Map<String, String>? styles,
      Map<String, String>? attributes, Map<String, EventCallback>? events) {
    super.renderNode(node, tag, id, classes, styles, attributes, events);
    try {
      component.didRenderNode(node);
    } catch (e) {
      print("[WARNING] Error inside [ChildNodeComponent.didRenderNode]: $e");
    }
  }

  @override
  void attachNode(RenderElement? element, RenderElement child, RenderElement? after) {
    super.attachNode(element, child, after);
    try {
      component.didAttachNode(child);
    } catch (e) {
      print("[WARNING] Error inside [ChildNodeComponent.didAttachNode]: $e");
    }
  }

  @override
  bool updateShouldNotify(covariant ChildNodeDelegate oldDelegate) {
    return component.runtimeType != oldDelegate.component.runtimeType || component.hasChanged(oldDelegate.component);
  }
}
