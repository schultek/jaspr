part of framework;

mixin DomNode on Element {
  DomBuilder get builder => _InheritedDomBuilder.of(this);
  late DomBuilder _builder;

  @override
  DomNode get _lastNode => this;

  DomNode get parentNode => _parentNode!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _builder = builder;
    renderNode(builder);
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
  void _didChangeAncestorSibling() {
    super._didChangeAncestorSibling();
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

class _InheritedDomBuilder extends InheritedComponent {
  const _InheritedDomBuilder({required this.builder, required super.child});

  final DomBuilder builder;

  @override
  bool updateShouldNotify(covariant _InheritedDomBuilder oldComponent) {
    return builder.runtimeType != oldComponent.builder.runtimeType || builder.updateShouldNotify(oldComponent.builder);
  }

  @override
  InheritedElement createElement() => _InheritedDomBuilderElement(this);

  static DomBuilder of(BuildContext context) {
    if (context is _InheritedDomBuilderElement) {
      var parentElement = context._parent!._inheritedElements![_InheritedDomBuilder]!;
      return (context.dependOnInheritedElement(parentElement) as _InheritedDomBuilder).builder;
    } else {
      return context.dependOnInheritedComponentOfExactType<_InheritedDomBuilder>()!.builder;
    }
  }
}

class _InheritedDomBuilderElement extends InheritedElement {
  _InheritedDomBuilderElement(_InheritedDomBuilder component) : super(component) {
    if (component.builder is DelegatingDomBuilder) {
      (component.builder as DelegatingDomBuilder)._element = this;
    }
  }

  @override
  _InheritedDomBuilder get component => super.component as _InheritedDomBuilder;

  @override
  void updated(covariant _InheritedDomBuilder oldComponent) {
    setDelegatingBuilderParent();
    super.updated(oldComponent);
  }

  void setDelegatingBuilderParent() {
    if (component.builder is DelegatingDomBuilder) {
      (component.builder as DelegatingDomBuilder)._element = this;
      (component.builder as DelegatingDomBuilder)._parent = _InheritedDomBuilder.of(this);
    }
  }

  @override
  Component? build() {
    setDelegatingBuilderParent();
    return component.child;
  }

  bool isDirectChild(DomNode node) {
    return node.parentNode.depth < depth;
  }

  @override
  void notifyDependent(covariant _InheritedDomBuilder oldComponent, Element dependent) {
    if (dependent is _InheritedDomBuilderElement ||
        (dependent is DomNode && component.builder.shouldNotifyDependent(dependent))) {
      dependent.didChangeDependencies();
    }
  }
}

abstract class DomBuilder {
  static Component delegate({required DelegatingDomBuilder builder, required Component child}) {
    return _InheritedDomBuilder(builder: builder, child: child);
  }

  void setRootNode(DomNode node);

  void renderNode(DomNode node, String tag, String? id, Iterable<String>? classes, Map<String, String>? styles,
      Map<String, String>? attributes, Map<String, EventCallback>? events);

  void renderTextNode(DomNode node, String text, [bool rawHtml = false]);

  void renderChildNode(DomNode node, DomNode child, DomNode? after);

  void didPerformRebuild(DomNode node);

  void removeChild(DomNode parent, DomNode child);

  @protected
  bool updateShouldNotify(covariant DomBuilder builder) => true;

  @protected
  bool shouldNotifyDependent(DomNode dependent) => true;
}

abstract class DelegatingDomBuilder implements DomBuilder {
  DomBuilder? _parent;
  _InheritedDomBuilderElement? _element;

  bool isDirectChild(DomNode node) {
    return _element?.isDirectChild(node) ?? false;
  }

  @override
  @protected
  @mustCallSuper
  void setRootNode(DomNode node) {
    _parent!.setRootNode(node);
  }

  @override
  @protected
  @mustCallSuper
  void renderNode(DomNode node, String tag, String? id, Iterable<String>? classes, Map<String, String>? styles,
      Map<String, String>? attributes, Map<String, EventCallback>? events) {
    _parent!.renderNode(node, tag, id, classes, styles, attributes, events);
  }

  @override
  @protected
  @mustCallSuper
  void renderTextNode(DomNode node, String text, [bool rawHtml = false]) {
    _parent!.renderTextNode(node, text, rawHtml);
  }

  @override
  @protected
  @mustCallSuper
  void renderChildNode(DomNode node, DomNode child, DomNode? after) {
    _parent!.renderChildNode(node, child, after);
  }

  @override
  @protected
  @mustCallSuper
  void didPerformRebuild(DomNode node) {
    _parent!.didPerformRebuild(node);
  }

  @override
  @protected
  @mustCallSuper
  void removeChild(DomNode parent, DomNode child) {
    _parent!.removeChild(parent, child);
  }

  @override
  @mustCallSuper
  bool updateShouldNotify(covariant DelegatingDomBuilder oldBuilder) {
    return _parent.runtimeType != oldBuilder._parent.runtimeType || _parent!.updateShouldNotify(oldBuilder._parent!);
  }
}
