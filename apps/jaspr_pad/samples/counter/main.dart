// [sample=0] Counter
import 'package:jaspr/jaspr.dart';

void main() {
  runApp(App());
}

class App extends StatefulComponent {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int count = 0;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield text('Count is $count');

    yield button(
      onClick: () {
        setState(() => count++);
      },
      [text('Press Me')],
    );
  }
}
