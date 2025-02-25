import 'package:jaspr/jaspr.dart';

@client
class Root3 extends StatelessComponent {
  const Root3({required this.child, super.key});

  final Component child;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield section([
      p([
        text("Child 1: "),
        child,
      ]),
      p([
        text("Child 2: "),
        child,
      ]),
      p([
        text("Child 3: "),
        child,
      ]),
    ]);
  }
}
