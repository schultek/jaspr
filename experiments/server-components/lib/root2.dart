import 'package:jaspr/jaspr.dart';

@client
class Root2 extends StatelessComponent {
  const Root2({required this.child, super.key});

  final Component child;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield section([
      text("Child: "),
      if (kIsWeb) child,
    ]);
  }
}
