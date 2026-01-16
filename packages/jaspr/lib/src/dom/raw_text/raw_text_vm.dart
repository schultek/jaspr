import '../../framework/framework.dart';

/// Renders its [text] input as raw HTML.
///
/// {@template jaspr.rawText.warning}
/// **WARNING**: This component does not escape any
/// user input and is vulnerable to [cross-site scripting (XSS) attacks](https://owasp.org/www-community/attacks/xss/).
/// Make sure to sanitize any user input when using this component.
/// {@endtemplate}
final class RawText extends Component {
  /// Creates a component that renders [text] as raw HTML.
  ///
  /// {@macro jaspr.rawText.warning}
  const RawText(this.text, {super.key});

  /// The text to render as raw HTML.
  final String text;

  @override
  Element createElement() => _RawTextElement(this);
}

class _RawTextElement extends LeafRenderObjectElement {
  _RawTextElement(super.component);

  @override
  RenderObject createRenderObject() {
    final parent = parentRenderObjectElement!.renderObject as RawableRenderObject;
    return parent.createChildRenderText((component as RawText).text, true);
  }

  @override
  void updateRenderObject(covariant RenderObject renderObject) {
    (renderObject as RawableRenderText).update((component as RawText).text, true);
  }
}
