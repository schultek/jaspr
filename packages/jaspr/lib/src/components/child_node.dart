import '../../jaspr.dart';

class FindChildNode extends ChildNodeComponent {
  FindChildNode({required this.onNodeFound, required super.child});

  final void Function(RenderElement) onNodeFound;

  @override
  void handleChildNode(RenderElement node) {
    onNodeFound(node);
  }

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

  void handleChildNode(RenderElement node);

  bool hasChanged(covariant ChildNodeComponent oldComponent);
}

class ChildNodeDelegate extends RenderDelegate {
  ChildNodeDelegate(this.component);

  final ChildNodeComponent component;

  @override
  void renderNode(RenderElement node, String tag, String? id, List<String>? classes, Map<String, String>? styles,
      Map<String, String>? attributes, Map<String, EventCallback>? events) {
    super.renderNode(node, tag, id, classes, styles, attributes, events);
    component.handleChildNode(node);
  }

  @override
  bool updateShouldNotify(covariant ChildNodeDelegate oldDelegate) {
    return component.runtimeType != oldDelegate.component.runtimeType ||
        component.hasChanged(oldDelegate.component);
  }
}
