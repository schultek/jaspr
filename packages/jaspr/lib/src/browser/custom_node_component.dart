import 'package:universal_web/web.dart' as web;

import '../framework/framework.dart';
import 'dom_render_object.dart';
import 'utils.dart';

abstract class NodeChildComponent extends Component {
  const NodeChildComponent({super.key});

  @override
  NodeChildElement createElement();
}

abstract class NodeChildElement implements RenderObjectElement {
  @override
  DomRenderNodeChild createRenderObject();
}

class DomRenderNodeChild extends DomRenderObject with MultiChildDomRenderObject, HydratableDomRenderObject {
  DomRenderNodeChild(this.node, DomRenderNodes parent, [List<web.Node>? nodes]) {
    this.parent = parent;
    toHydrate = [...nodes ?? node.childNodes.toIterable()];
    beforeStart = toHydrate.firstOrNull?.previousSibling;
  }

  factory DomRenderNodeChild.between(DomRenderNodes parent, web.Node start, web.Node end) {
    final nodes = <web.Node>[];
    web.Node? curr = start.nextSibling;
    while (curr != null && curr != end) {
      nodes.add(curr);
      curr = curr.nextSibling;
    }
    return DomRenderNodeChild(start.parentElement!, parent, nodes);
  }

  @override
  final web.Element node;
  late final web.Node? beforeStart;

  @override
  void attach(DomRenderObject child, {DomRenderObject? after}) {
    attachChild(child, after, startNode: beforeStart);
  }

  @override
  void remove(DomRenderObject child) {
    removeChild(child);
  }
}

class CustomNodeComponent extends Component {
  CustomNodeComponent(this.nodes, this.children, {super.key});

  final List<web.Node> nodes;
  final List<NodeChildComponent> children;

  @override
  Element createElement() => CustomNodeElement(this);
}

class CustomNodeElement extends MultiChildRenderObjectElement {
  CustomNodeElement(CustomNodeComponent super.component);

  @override
  CustomNodeComponent get component => super.component as CustomNodeComponent;

  @override
  void update(CustomNodeComponent newComponent) {
    assert(
      newComponent.nodes == component.nodes,
      'CustomNodeComponent cannot be updated with different nodes.',
    );
    super.update(newComponent);
  }

  @override
  List<Component> buildChildren() {
    return component.children;
  }

  @override
  RenderObject createRenderObject() {
    final parent = parentRenderObjectElement!.renderObject;
    return DomRenderNodes(component.nodes, parent as DomRenderObject);
  }

  @override
  void updateRenderObject(RenderObject renderObject) {}

  @override
  void unmount() {
    super.unmount();
    _clearEventListeners(this);
  }

  static _clearEventListeners(Element e) {
    if (e case RenderObjectElement(renderObject: DomRenderElement r)) {
      r.events?.forEach((type, binding) {
        binding.clear();
      });
      r.events = null;
    }

    e.visitChildren(_clearEventListeners);
  }
}

class DomRenderNode extends DomRenderObject {
  DomRenderNode(this.node);

  @override
  final web.Node node;

  @override
  void attach(covariant RenderObject child, {covariant RenderObject? after}) {
    throw UnsupportedError('A DomRenderNode cannot have children attached to them.');
  }

  @override
  void remove(covariant RenderObject child) {
    throw UnsupportedError('A DomRenderNode cannot have children removed from them.');
  }

  @override
  void finalize() {}

  @override
  web.Node? retakeNode(bool Function(web.Node node) visitNode) {
    return null; // Not applicable for raw nodes
  }
}

class DomRenderNodes extends DomRenderFragment {
  DomRenderNodes(List<web.Node> nodes, DomRenderObject? parent) : super(parent, []) {
    if (nodes.isEmpty) {
      firstChildNode = null;
      lastChildNode = null;
      isAttached = true;
      return;
    }
    final firstNode = nodes.first;
    final lastNode = nodes.last;
    assert(firstNode.parentNode == lastNode.parentNode, 'All nodes must share the same parent.');
    firstChildNode = firstNode;
    lastChildNode = lastNode;
    if (parent != null && parent.node.contains(firstNode)) {
      if (parent is HydratableDomRenderObject) {
        var startIndex = parent.toHydrate.indexOf(firstNode);
        var endIndex = parent.toHydrate.indexOf(lastNode);
        if (startIndex != -1 && endIndex != -1 && startIndex <= endIndex) {
          parent.toHydrate.removeRange(startIndex, endIndex + 1);
        }
      }
      isAttached = true;
    } else {
      for (final node in nodes) {
        this.node.appendChild(node);
      }
    }
  }

  @override
  late final web.Node? firstChildNode;

  @override
  late final web.Node? lastChildNode;

  @override
  void attach(covariant RenderObject child, {covariant RenderObject? after}) {
    if (child is DomRenderNodeChild) {
      assert(
        isAttached ? parent!.node.contains(child.node) : node.contains(child.node),
        'Cannot attach a child that is not already part of the component fragment.',
      );
      child.parent = this;
      child.finalize();
      return;
    }
    throw UnsupportedError('DomRenderNodes cannot have children attached to them.');
  }

  @override
  void remove(covariant RenderObject child) {
    throw UnsupportedError('DomRenderNodes cannot have children removed from them.');
  }
}
