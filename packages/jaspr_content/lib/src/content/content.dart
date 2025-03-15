import 'package:jaspr/jaspr.dart';
// ignore: implementation_imports
import 'package:jaspr/src/foundation/styles/css.dart';

import '../themes/colors.dart';

part 'theme.dart';
part 'base.dart';
part 'layout.dart';

class InheritedContentTheme extends InheritedComponent {
  InheritedContentTheme({
    required this.theme,
    required super.child,
  });

  final ContentTheme theme;

  @override
  bool updateShouldNotify(covariant InheritedContentTheme oldComponent) {
    return theme != oldComponent.theme;
  }
}

class Content extends StatelessComponent {
  const Content({
    required this.children,
  });

  final List<Component> children;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    if (!kIsWeb) {
      final theme =
          context.dependOnInheritedComponentOfExactType<InheritedContentTheme>()?.theme ?? const ContentTheme.custom();
      yield Document.head(children: [
        Style(styles: theme.styles),
      ]);
    }

    yield section(classes: 'content', children);
  }
}
