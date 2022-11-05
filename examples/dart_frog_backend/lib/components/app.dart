import 'package:jaspr/html.dart';

@app
class App extends StatefulComponent {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int count = 10;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield p([
      text('Hello World from Jaspr'),
    ]);

    yield p([
      text('$count'),
    ]);

    yield button(
      events: {'click': (_) {
        print("clicked $count");
        setState(() => count++);
      }},
      [text('Click Me')],
    );
  }
}
