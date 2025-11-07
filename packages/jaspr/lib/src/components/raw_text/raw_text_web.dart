import 'dart:js_interop';

import 'package:universal_web/web.dart' as web;

import '../../../browser.dart';
import '../../browser/custom_node_component.dart';
import '../../browser/utils.dart';

/// Renders its input as raw HTML.
///
/// **WARNING**: This component does not escape any
/// user input and is vulnerable to [cross-site scripting (XSS) attacks](https://owasp.org/www-community/attacks/xss/).
/// Make sure to sanitize any user input when using this component.
class RawText extends StatelessComponent {
  const RawText(this.text, {super.key});

  final String text;

  @override
  Component build(BuildContext context) {
    var fragment = web.document.createElement('template') as web.HTMLTemplateElement;
    fragment.innerHTML = text.toJS;
    return Component.fragment([
      for (var node in fragment.content.childNodes.toIterable()) RawNode.withKey(node),
    ]);
  }
}

class RawNode extends Component {
  RawNode(this.node, {super.key});

  factory RawNode.withKey(web.Node node) {
    return RawNode(
      node,
      key: switch (node) {
        web.Text() when node.instanceOfString("Text") => ValueKey('text'),
        web.Element() when node.instanceOfString("Element") => ValueKey('element:${node.tagName}'),
        _ => null,
      },
    );
  }

  final web.Node node;

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