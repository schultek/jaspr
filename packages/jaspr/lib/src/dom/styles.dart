import '/jaspr.dart';
import 'raw_text/raw_text.dart';
import 'styles/rules.dart';

export 'styles/css.dart' show css;
export 'styles/rules.dart' show StyleRule, MediaQuery, Orientation, ColorScheme, Contrast;
export 'styles/selector.dart' show Selector, SelectorMixin, AttrCheck, Combinator;
export 'styles/styles.dart';

/// Renders the provided list of [styles] into css and wraps them
/// with a `<style>` element.
class Style extends StatelessComponent {
  final List<StyleRule> styles;

  const Style({required this.styles, super.key});

  @override
  Component build(BuildContext context) {
    return Component.element(tag: 'style', children: [RawText(styles.render())]);
  }
}
