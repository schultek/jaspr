part of framework;

mixin DomNode on Element {
  DomBuilder get builder => DomBuilder.of(this);
  late DomBuilder _builder;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _builder = builder;
  }

  void mountNode() {
    _builder = builder;
    renderNode(builder);
    _node?.renderChildNode(this);
  }

  @override
  void update(Component newComponent) {
    super.update(newComponent);
    renderNode(builder);
  }

  @override
  void unmount() {
    super.unmount();
    _builder.removeNode(this);
  }

  @protected
  void renderNode(DomBuilder builder);

  @override
  void updateSlot(Slot newSlot) {
    super.updateSlot(newSlot);
    _node!.renderChildNode(this);
  }

  void renderChildNode(DomNode child) {
    Element? beforeElem = child.slot!.nextSibling;

    if (beforeElem == null) {
      child.visitAncestorElements((element) {
        if (element == this) return false;
        beforeElem = element.slot!.nextSibling;
        return beforeElem == null;
      });
    }

    DomNode? before;

    while (beforeElem != null && before == null) {
      if (beforeElem is DomNode) {
        before = beforeElem as DomNode;
      } else {
        visitor(element) {
          if (before != null) return;
          if (element is DomNode) {
            before = element;
          } else {
            element.visitChildren(visitor);
          }
        }

        beforeElem!.visitChildren(visitor);
      }

      if (before == null) {
        beforeElem = beforeElem!.slot?.nextSibling;
      }
    }

    builder.renderChildNode(this, child, before);
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

  void renderChildNode(DomNode node, DomNode child, DomNode? before);

  void removeNode(DomNode node);
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
