// [sample][hidden] Tutorial
import 'package:jaspr/jaspr.dart';

// New code in step 2

void main() {
  runApp(App());
}

class App extends StatefulComponent {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int count = 0;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Text('Count is $count');

    yield DomComponent(
      tag: 'button',
      events: {
        'click': (e) {
          setState(() => count++);
        },
      },
      child: Text('Press Me'),
    );
  }
}
