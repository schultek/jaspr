// [sample=5] Bulma CSS
import 'package:jaspr/jaspr.dart';

void main() {
  runApp(App());
}

class App extends StatefulComponent {
  @override
  State createState() => AppState();
}

class AppState extends State<App> {
  int value = 0;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'button',
      classes: ['button', 'is-primary', 'block'],
      events: {
        'click': (e) => setState(() => value = 100),
      },
      child: Text('Click Me'),
    );

    yield DomComponent(
      tag: 'progress',
      classes: ['progress', 'is-primary'],
      attributes: {'value': value.toString(), 'max': '100'},
      child: Text(value.toString() + '%'),
    );
  }
}

class Animation {}
