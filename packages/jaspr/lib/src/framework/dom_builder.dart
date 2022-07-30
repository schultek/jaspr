part of framework;

mixin DomNode on Element {
  DomBuilder get builder => DomBuilder.of(this);
  late DomBuilder _builder;

  @override
  DomNode get _lastNode => this;

  DomNode? get parentNode => _parentNode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _builder = builder;
  }

  void mountNode() {
    _builder = builder;
    renderNode(builder);
    _parentNode?.renderChildNode(this);
  }

  @override
  void update(Component newComponent) {
    super.update(newComponent);
    renderNode(builder);
  }

  @override
  void unmount() {
    _builder.removeChild(_parentNode!, this);
    super.unmount();
  }

  @protected
  void renderNode(DomBuilder builder);

  @override
  void updatePrevSibling(Element? prevSibling) {
    super.updatePrevSibling(prevSibling);
    _parentNode!.renderChildNode(this);
  }

  @override
  void performRebuild() {
    super.performRebuild();
    _builder.didPerformRebuild(this);
  }

  void renderChildNode(DomNode child) {
    Element? prevElem = child._prevAncestorSibling;
    while (prevElem != null && prevElem._lastNode == null) {
      prevElem = prevElem._prevAncestorSibling;
    }
    var after = prevElem?._lastNode;
    builder.renderChildNode(this, child, after);
  }
}

class InheritedDomBuilder extends InheritedComponent {
  const InheritedDomBuilder({required this.builder, required super.child, super.key});

  final DomBuilder builder;

  @override
  bool updateShouldNotify(covariant InheritedDomBuilder oldComponent) {
    return builder != oldComponent.builder;
  }
}

abstract class DomBuilder {
  static DomBuilder of(BuildContext context) {
    return context.dependOnInheritedComponentOfExactType<InheritedDomBuilder>()!.builder;
  }

  void setRootNode(DomNode node);

  void renderNode(DomNode node, String tag, Map<String, String> attrs, Map<String, EventCallback> events);

  void renderTextNode(DomNode node, String text);

  void renderChildNode(DomNode node, DomNode child, DomNode? after);

  void didPerformRebuild(DomNode node);

  void removeChild(DomNode parent, DomNode child);
}

class Slot {
  Element? nextSibling;

  Slot(this.nextSibling);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Slot && runtimeType == other.runtimeType && nextSibling == other.nextSibling;

  @override
  int get hashCode => nextSibling.hashCode;
}
