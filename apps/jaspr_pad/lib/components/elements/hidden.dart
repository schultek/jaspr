import 'package:jaspr/jaspr.dart';

class Hidden extends StatelessComponent {
  const Hidden({
    required this.hidden,
    required this.child,
    this.visibilityMode = false,
    Key? key,
  }) : super(key: key);

  final bool hidden;
  final Component child;
  final bool visibilityMode;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent.wrap(
      styles: Styles.box(
        visibility: hidden && visibilityMode ? Visibility.hidden : null,
      ),
      attributes: {if (hidden && !visibilityMode) 'hidden': ''},
      child: child,
    );
  }
}
