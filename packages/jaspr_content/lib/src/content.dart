import 'package:jaspr/jaspr.dart';

import 'theme/theme.dart';

/// A component that wraps the content of a page and applies default typographic styles.
///
/// The applies styles are based on the [ContentTheme] provided by the nearest [Content.wrapTheme] ancestor
/// (usually the root [ContentApp]).
class Content extends StatelessComponent {
  const Content(this.child, {super.key});

  final Component child;

  static Component wrapTheme(ContentTheme theme, {required Component child}) {
    return _InheritedContentTheme(theme: theme, child: child);
  }

  static ContentTheme themeOf(BuildContext context) {
    return context.dependOnInheritedComponentOfExactType<_InheritedContentTheme>()?.theme ?? ContentTheme();
  }

  @override
  Component build(BuildContext context) {
    final children = <Component>[];
    if (!kIsWeb) {
      final theme = themeOf(context);
      children.add(Document.head(children: [
        Style(styles: theme.styles),
      ]));
    }

    children.add(section(classes: 'content', [child]));
    return Component.fragment(children: children);
  }
}

class _InheritedContentTheme extends InheritedComponent {
  _InheritedContentTheme({
    required this.theme,
    required super.child,
  });

  final ContentTheme theme;

  @override
  bool updateShouldNotify(covariant _InheritedContentTheme oldComponent) {
    return theme != oldComponent.theme;
  }
}
