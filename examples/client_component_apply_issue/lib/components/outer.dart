import 'package:jaspr/jaspr.dart';

@client
class Outer extends StatelessComponent {
  const Outer({required this.child, super.key});

  final Component child;

  @override
  Component build(BuildContext context) => .apply(
    classes: 'highlighted',
    attributes: const {'data-outer': 'true'},
    child: child,
  );
}
