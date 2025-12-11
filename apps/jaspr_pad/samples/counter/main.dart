// [sample=0] Counter
import 'package:jaspr/dom.dart';
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
  Component build(BuildContext context) {
    return div([
      .text('Count is $count'),
      button(
        onClick: () {
          setState(() => count++);
        },
        [.text('Press Me')],
      ),
    ]);
  }
}
