import '../../foundation/basic_types.dart';
import '../../foundation/events.dart';
import '../../foundation/styles/styles.dart';
import '../../framework/framework.dart';
import '../raw_text/raw_text.dart';

part 'content.dart';
part 'forms.dart';
part 'media.dart';
part 'other.dart';
part 'svg.dart';
part 'table.dart';
part 'text.dart';

final _events = events;

/// Renders a text node.
///
/// Convenience method for `Component.text()`.
Component text(String text, {Key? key}) {
  return Component.text(text, key: key);
}

/// Renders its input as raw unescaped html using [RawText].
///
/// **WARNING**: This component does not escape any user input and is vulnerable to
/// [cross-site scripting (XSS) attacks](https://owasp.org/www-community/attacks/xss/).
/// Make sure to sanitize any user input when using this component.
///
/// Convenience method for `RawText()`.
Component raw(String text, {Key? key}) {
  return RawText(text, key: key);
}

/// Renders a list of children without any wrapping element.
///
/// Convenience method for `Component.fragment()`.
Component fragment(List<Component> children, {Key? key}) {
  return Component.fragment(children, key: key);
}
