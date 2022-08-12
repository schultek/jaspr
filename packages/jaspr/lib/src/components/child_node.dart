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
      renderer: ChildNodeRenderer(this),
      children: [child],
    );
  }

  void handleChildNode(RenderElement node);

  bool hasChanged(covariant ChildNodeComponent oldComponent);
}

class ChildNodeRenderer extends DelegatingRenderer {
  ChildNodeRenderer(this.component);

  final ChildNodeComponent component;

  @override
  void renderNode(RenderElement node, String tag, String? id, List<String>? classes, Map<String, String>? styles,
      Map<String, String>? attributes, Map<String, EventCallback>? events) {
    super.renderNode(node, tag, id, classes, styles, attributes, events);
    component.handleChildNode(node);
  }

  @override
  bool updateShouldNotify(covariant ChildNodeRenderer oldBuilder) {
    return component.runtimeType != oldBuilder.component.runtimeType ||
        component.hasChanged(oldBuilder.component);
  }
}
