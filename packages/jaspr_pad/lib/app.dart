import 'package:jaspr/jaspr.dart';
import 'package:jaspr_pad/playground.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

class App extends StatelessComponent {
  const App({Key? key}) : super(key: key);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield ProviderScope(child: Playground());
  }
}
