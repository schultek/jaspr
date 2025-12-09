import 'package:meta/meta.dart' show optionalTypeArgs;

import '../../foundation/basic_types.dart';
import '../../foundation/constants.dart';
import '../../framework/framework.dart';
import '../events.dart';
import '../raw_text/raw_text.dart';
import '../styles/styles.dart';

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
/// Migrate to use [Component.text] directly instead.
@Deprecated('Use Component.text() instead.')
Component text(String text, {Key? key}) {
  return Component.text(text, key: key);
}

/// Renders its input as raw unescaped html using [RawText].
///
/// **WARNING**: This component does not escape any user input and is vulnerable to
/// [cross-site scripting (XSS) attacks](https://owasp.org/www-community/attacks/xss/).
/// Make sure to sanitize any user input when using this component.
///
/// Migrate to use [RawText] directly instead.
@Deprecated('Use RawText() instead.')
Component raw(String text, {Key? key}) {
  return RawText(text, key: key);
}

/// Renders a list of [children] without any wrapping element.
///
/// Migrate to use [Component.fragment] directly instead.
@Deprecated('Use Component.fragment() instead.')
Component fragment(List<Component> children, {Key? key}) {
  return Component.fragment(children, key: key);
}

String? _explicitBool(bool? val) => switch (val) {
  true => kIsWeb ? 'true' : '',
  false => kIsWeb ? 'false' : null,
  null => null,
};
