import 'dart:js_interop';

import 'package:universal_web/web.dart' as web;

import '../../../client.dart';
import '../../client/utils.dart';

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
    final fragment = web.document.createElement('template') as web.HTMLTemplateElement;
    fragment.innerHTML = text.toJS;
    return Component.fragment([
      for (final node in fragment.content.childNodes.toIterable()) _RawNode(node, key: ValueKey(node)),
    ]);
  }
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
