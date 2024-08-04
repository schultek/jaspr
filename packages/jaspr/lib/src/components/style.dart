import '../../jaspr.dart';

/// Renders the provided [StyleRule]s into css and wraps them
/// with a &lt;style&gt; element.
class Style extends StatelessComponent {
  final List<StyleRule> styles;

  const Style({required this.styles, super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'style',
      child: RawText(styles.render()),
    );
  }
}
