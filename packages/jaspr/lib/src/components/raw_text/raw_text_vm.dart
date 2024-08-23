import '../../../server.dart';

/// Renders its input as raw HTML.
///
/// **WARNING**: This component does not escape any
/// user input and is vulnerable to [cross-site scripting (XSS) attacks](https://owasp.org/www-community/attacks/xss/).
/// Make sure to sanitize any user input when using this component.
class RawText extends Component {
  const RawText(this.text, {super.key});

  final String text;

  @override
  Element createElement() => RawTextElement(this);
}

class RawTextElement extends LeafRenderObjectElement {
  RawTextElement(super.component);

  @override
  void updateRenderObject() {
    (renderObject as MarkupRenderObject).updateText((component as RawText).text, true);
  }
}
