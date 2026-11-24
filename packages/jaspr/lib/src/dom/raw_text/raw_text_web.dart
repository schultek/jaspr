import 'dart:js_interop';

import 'package:universal_web/web.dart' as web;

import '../../../client.dart';
import '../../client/utils.dart';
import '../type_checks.dart';

/// Renders its [text] input as raw HTML.
///
/// {@template jaspr.rawText.warning}
/// **WARNING**: This component does not escape any
/// user input and is vulnerable to [cross-site scripting (XSS) attacks](https://owasp.org/www-community/attacks/xss/).
/// Make sure to sanitize any user input when using this component.
/// {@endtemplate}
final class RawText extends StatelessComponent {
  /// Creates a component that renders [text] as raw HTML.
  ///
  /// {@macro jaspr.rawText.warning}
  const RawText(this.text, {super.key});

  /// The text to render as raw HTML.
  final String text;

  @override
  Component build(BuildContext context) {
    return Component.fragment([
      for (final node in _parse(text, _parentElement(context))) _RawNode(node, key: ValueKey(node)),
    ]);
  }
}

/// The element the markup is about to be inserted into, if there is one.
///
/// The nearest ancestor dom node is not necessarily an element: a fragment
/// renders into a `DocumentFragment`, so the chain is walked until an element
/// turns up.
web.Element? _parentElement(BuildContext context) {
  var renderObject = (context as Element).parentRenderObjectElement?.renderObject;
  while (renderObject is DomRenderObject) {
    final node = renderObject.node;
    if (node.isElement) return node as web.Element;
    renderObject = renderObject.parent;
  }
  return null;
}

/// Parses [text] into dom nodes, in the context of [parent].
///
/// Parsing through `template.innerHTML` puts the nodes in the xhtml namespace,
/// because that is what the html parser uses with no element around the
/// markup. Inside an `<svg>` that is the wrong namespace: `<circle>` becomes an
/// unknown element, and the browser lays an unknown element out as nothing. It
/// is in the dom, it just cannot be seen — and server-rendered markup shows
/// the shape until hydration replaces it with this.
///
/// `createContextualFragment` parses against an element instead, so the nodes
/// come out in that element's namespace. It also settles the cases where the
/// markup is only valid inside a specific parent, such as a `<td>` in a
/// `<tr>`. The template is kept for the case where there is no element to parse
/// against, which is what a fragment at the root of a component tree is.
Iterable<web.Node> _parse(String text, web.Element? parent) {
  if (parent != null) {
    final range = web.document.createRange()..selectNodeContents(parent);
    return range.createContextualFragment(text.toJS).childNodes.toIterable();
  }
  final template = web.document.createElement('template') as web.HTMLTemplateElement;
  template.innerHTML = text.toJS;
  return template.content.childNodes.toIterable();
}

class _RawNode extends Component {
  _RawNode(this.node, {super.key});

  final web.Node node;

  @override
  Element createElement() => _RawNodeElement(this);
}

class _RawNodeElement extends LeafRenderObjectElement {
  _RawNodeElement(_RawNode super.component);

  @override
  _RawNode get component => super.component as _RawNode;

  @override
  void update(_RawNode newComponent) {
    assert(
      newComponent.node == component.node,
      'RawNode cannot be updated with a different node. Use a new RawNode instance instead.',
    );
    super.update(newComponent);
  }

  @override
  RenderObject createRenderObject() {
    final parent = parentRenderObjectElement!.renderObject;
    return _DomRenderNode(component.node)..parent = parent as DomRenderObject;
  }

  @override
  void updateRenderObject(RenderObject renderObject) {}
}

class _DomRenderNode extends DomRenderObject {
  _DomRenderNode(this.node);

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
    return null; // Not applicable for raw nodes.
  }
}
