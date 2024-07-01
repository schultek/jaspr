import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

@client
class Root extends StatelessComponent {
  const Root({required this.child, super.key});

  final Component child;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield ProviderScope(child: child);
  }
}
