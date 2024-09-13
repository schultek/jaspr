import 'package:jaspr/jaspr.dart';

import '../components/counter.dart';
import '../components/theme_toggle.dart';
import '../constants/theme.dart';

class Home extends StatelessComponent {
  const Home({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield ThemeProvider(
      theme: ThemeMode.light,
      child: section([
        ThemeToggle(),
        const Counter(),
      ]),
    );
  }
}
