import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import 'components/playground/playground.dart';

class App extends StatelessComponent {
  const App({required this.providerOverrides, Key? key}) : super(key: key);

  final List<Override> providerOverrides;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield ProviderScope(
      overrides: providerOverrides,
      child: Playground(),
    );
  }
}
