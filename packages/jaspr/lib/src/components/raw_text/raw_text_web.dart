import 'dart:js_interop';

import 'package:universal_web/web.dart' as web;

import '../../../browser.dart';
import '../../browser/utils.dart';

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
  Iterable<Component> build(BuildContext context) sync* {
    var fragment = web.document.createElement('template') as web.HTMLTemplateElement;
    fragment.innerHTML = text.toJS;
    for (var node in fragment.content.childNodes.toIterable()) {
      yield elementFactories.buildNode(node);
    }
  }
}

typedef ElementFactories = Map<String, ElementFactory>;
typedef ElementFactory = Component Function(web.Element);

extension on ElementFactories {
  Component buildNode(web.Node node) {
    if (node is web.Element && node.instanceOfString("Element") && containsKey(node.tagName.toLowerCase())) {
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

class RawNodeElement extends BuildableRenderObjectElement {
  RawNodeElement(RawNode super.component);

  @override
  RawNode get component => super.component as RawNode;

  @override
  Iterable<Component> build() sync* {
    for (var node in component.node.childNodes.toIterable()) {
      yield component.elementFactories.buildNode(node);
    }
  }

  @override
  void updateRenderObject() {
    var next = component.node;
    if (next.instanceOfString("Text") && next is web.Text) {
      renderObject.updateText(next.textContent ?? '');
    } else if (next.instanceOfString("Element") && next is web.Element) {
      renderObject.updateElement(
          next.tagName.toLowerCase(), next.id, next.className, null, next.attributes.toMap(), null);
    } else {
      var curr = (renderObject as DomRenderObject).node;
      var clone = next.cloneNode(true);
      if (curr != null) {
        curr.parentNode?.replaceChild(clone, curr);
      }
      (renderObject as DomRenderObject).node = clone;
    }
  }
}
