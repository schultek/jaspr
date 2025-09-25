import 'package:jaspr/jaspr.dart';

@client
class Root2 extends StatelessComponent {
  const Root2({required this.child, super.key});

  final Component child;

  @override
  Component build(BuildContext context) {
    return section([
      text("Child: "),
      if (kIsWeb) child,
    ]);
  }
}
