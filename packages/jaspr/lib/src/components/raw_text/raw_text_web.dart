import 'dart:js_interop';

import 'package:universal_web/web.dart' as web;

import '../../../browser.dart';
import '../../browser/utils.dart';
import '../../foundation/type_checks.dart';

/// Renders its input as raw HTML.
///
/// **WARNING**: This component does not escape any
/// user input and is vulnerable to [cross-site scripting (XSS) attacks](https://owasp.org/www-community/attacks/xss/).
/// Make sure to sanitize any user input when using this component.
class RawText extends StatelessComponent {
  const RawText(this.text, {this.elementFactories = const {}, super.key});

  final String text;
  final ElementFactories elementFactories;

  @override
  Component build(BuildContext context) {
    var fragment = web.document.createElement('template') as web.HTMLTemplateElement;
    fragment.innerHTML = text.toJS;
    return Component.fragment([
      for (var node in fragment.content.childNodes.toIterable()) elementFactories.buildNode(node),
    ]);
  }
}

typedef ElementFactories = Map<String, ElementFactory>;
typedef ElementFactory = Component Function(web.Element);

extension on ElementFactories {
  Component buildNode(web.Node node) {
    if (node.isElement && containsKey((node as web.Element).tagName.toLowerCase())) {
      return this[node.tagName.toLowerCase()]!(node);
    }
    return RawNode.withKey(node, this);
  }
}

class RawNode extends Component {
  RawNode(this.node, {this.elementFactories = const {}, super.key});

  factory RawNode.withKey(web.Node node, ElementFactories elementFactories) {
    return RawNode(
      node,
      elementFactories: elementFactories,
      key: switch (node) {
        web.Text() when node.instanceOfString("Text") => ValueKey('text'),
        web.Element() when node.instanceOfString("Element") => ValueKey('element:${node.tagName}'),
        _ => null,
      },
    );
  }

  final web.Node node;
  final ElementFactories elementFactories;

  @override
  Element createElement() => RawNodeElement(this);
}

class RawNodeElement extends LeafRenderObjectElement {
  RawNodeElement(RawNode super.component);

  @override
  RawNode get component => super.component as RawNode;

  @override
  void update(RawNode newComponent) {
    assert(
      newComponent.node == component.node,
      'RawNode cannot be updated with a different node. Use a new RawNode instance instead.',
    );
    super.update(newComponent);
  }

  @override
  RenderObject createRenderObject() {
    final parent = parentRenderObjectElement!.renderObject;
    return DomRenderNode(component.node)..parent = parent as DomRenderObject;
  }

  @override
  void updateRenderObject(RenderObject renderObject) {}
}

class DomRenderNode extends DomRenderObject {
  DomRenderNode(this.node);

  @override
  final web.Node node;

  @override
  void attach(covariant RenderObject child, {covariant RenderObject? after}) {
    throw UnsupportedError('Raw nodes cannot have children attached to them.');
  }

  @override
  void remove(covariant RenderObject child) {
    throw UnsupportedError('Text nodes cannot have children removed from them.');
  }

  @override
  void finalize() {}

  @override
  web.Node? retakeNode(bool Function(web.Node node) visitNode) {
    return null; // Not applicable for raw nodes
  }
}
