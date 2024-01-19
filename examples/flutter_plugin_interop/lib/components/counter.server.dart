import 'package:jaspr/jaspr.dart';

class Counter extends StatelessComponent {
  const Counter({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: 'container', []);
  }
}
