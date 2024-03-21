import 'package:jaspr/jaspr.dart';

class App extends StatefulComponent {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int count = 0;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield text('Count: $count');

    yield button(onClick: () {
      setState(() => count++);
    }, [
      text('Increment'),
    ]);
  }
}
