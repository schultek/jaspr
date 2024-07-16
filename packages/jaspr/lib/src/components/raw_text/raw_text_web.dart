import 'dart:html' as html;

import '../../../browser.dart';

class RawText extends StatelessComponent {
  const RawText(this.text, {super.key});

  final String text;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    final fragment = html.document.createDocumentFragment()..setInnerHtml(text, validator: AllowAll());
    for (final node in fragment.childNodes) {
      yield RawNode.withKey(node);
    }
  }
}

class RawNode extends Component {
  const RawNode(this.node, {super.key});

  factory RawNode.withKey(html.Node node) {
    return RawNode(
      node,
      key: switch (node) {
        html.Text() => const ValueKey('text'),
        html.Element(:final tagName) => ValueKey('element:$tagName'),
        _ => null,
      },
    );
  }

  final html.Node node;

  @override
  Element createElement() => RawNodeElement(this);
}

class RawNodeElement extends BuildableRenderObjectElement {
  RawNodeElement(RawNode super.component);

  @override
  RawNode get component => super.component as RawNode;

  @override
  Iterable<Component> build() sync* {
    for (final node in component.node.childNodes) {
      yield RawNode.withKey(node);
    }
  }

  @override
  void updateRenderObject() {
    final next = component.node;
    if (next is html.Text) {
      renderObject.updateText(next.text ?? '');
    } else if (next is html.Element) {
      renderObject.updateElement(next.tagName.toLowerCase(), next.id, next.className, null, next.attributes, null);
    } else {
      final curr = (renderObject as DomRenderObject).node;
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
