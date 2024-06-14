import 'dart:html' as html;

import '../../../browser.dart';

class RawText extends StatelessComponent {
  const RawText(this.text, {this.elementFactories = const {}, super.key});

  final String text;
  final ElementFactories elementFactories;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    var fragment = html.document.createDocumentFragment()..setInnerHtml(text, validator: AllowAll());
    for (var node in fragment.childNodes) {
      yield elementFactories.buildNode(node);
    }
  }
}

typedef ElementFactories = Map<String, ElementFactory>;
typedef ElementFactory = Component Function(html.Element);

extension on ElementFactories {
  Component buildNode(html.Node node) {
    if (node is html.Element && containsKey(node.tagName.toLowerCase())) {
      return this[node.tagName.toLowerCase()]!(node);
    }
    return RawNode.withKey(node, this);
  }
}

class RawNode extends Component {
  RawNode(this.node, {this.elementFactories = const {}, super.key});

  factory RawNode.withKey(html.Node node, ElementFactories elementFactories) {
    return RawNode(
      node,
      elementFactories: elementFactories,
      key: switch (node) {
        html.Text() => ValueKey('text'),
        html.Element(:var tagName) => ValueKey('element:$tagName'),
        _ => null,
      },
    );
  }

  final html.Node node;
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
    for (var node in component.node.childNodes) {
      yield component.elementFactories.buildNode(node);
    }
  }

  @override
  void updateRenderObject() {
    var node = component.node;
    if (node is html.Text) {
      renderObject.updateText(node.text ?? '');
    } else if (node is html.Element) {
      renderObject.updateElement(node.tagName.toLowerCase(), node.id, node.className, null, node.attributes, null);
    } else {
      var curr = (renderObject as DomRenderObject).node;
      var next = node.clone(true);
      if (curr != null) {
        curr.replaceWith(next);
      }
      (renderObject as DomRenderObject).node = next;
    }
  }
}

class AllowAll implements html.NodeValidator {
  @override
  bool allowsAttribute(html.Element element, String attributeName, String value) {
    return true;
  }

  @override
  bool allowsElement(html.Element element) {
    return true;
  }
}
