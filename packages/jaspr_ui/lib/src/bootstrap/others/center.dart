import 'package:jaspr/jaspr.dart';
import 'package:jaspr_ui/src/core/elements/div.dart';

class Center extends StatelessComponent {
  final Component child;

  const Center({required this.child});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DivElement(
      classes: ['text-center'],
      child: child,
    );
  }
}
