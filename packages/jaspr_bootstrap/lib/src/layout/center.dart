import 'package:jaspr/jaspr.dart';

class Center extends StatelessComponent {
  final Component child;

  Center({required this.child});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'div',
      classes: ['text-center'],
      child: child,
    );
  }
}
