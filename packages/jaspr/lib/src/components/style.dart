import '../../jaspr.dart';

/// Renders the provided [StyleRule]s into css and wraps them
/// with a &lt;style&gt; element.
class Style extends StatelessComponent {
  final List<StyleRule> styles;

  const Style({required this.styles, super.key});

  @override
  Component build(BuildContext context) {
    return Component.element(
      tag: 'style',
      children: [RawText(styles.render())],
    );
  }
}
