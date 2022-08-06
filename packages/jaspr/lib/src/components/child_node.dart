import '../../jaspr.dart';

class FindChildNode extends ChildNodeComponent {
  FindChildNode({required this.onNodeFound, required super.child});

  final void Function(DomNode) onNodeFound;

  @override
  void handleChildNode(DomNode node) {
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
    yield DomBuilder.delegate(
      builder: ChildNodeBuilder(this),
      child: child,
    );
  }

  void handleChildNode(DomNode node);

  bool hasChanged(covariant ChildNodeComponent oldComponent);
}

class ChildNodeBuilder extends DelegatingDomBuilder {
  ChildNodeBuilder(this.component);

  final ChildNodeComponent component;

  @override
  void renderNode(DomNode node, String tag, String? id, Iterable<String>? classes, Map<String, String>? styles,
      Map<String, String>? attributes, Map<String, EventCallback>? events) {
    super.renderNode(node, tag, id, classes, styles, attributes, events);
    if (isDirectChild(node)) {
      component.handleChildNode(node);
    }
  }

  @override
  bool updateShouldNotify(covariant ChildNodeBuilder oldBuilder) {
    return component.runtimeType != oldBuilder.component.runtimeType ||
        component.hasChanged(oldBuilder.component) ||
        super.updateShouldNotify(oldBuilder);
  }

  @override
  bool shouldNotifyDependent(DomNode dependent) {
    return isDirectChild(dependent);
  }
}
