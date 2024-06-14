import 'package:jaspr/html.dart';

part 'app.g.dart';

@client
class App extends StatefulComponent with _$App {
  const App({required this.child});

  final Component child;

  @override
  State<StatefulComponent> createState() => AppState();
}

class AppState extends State<App> {
  bool toggled = false;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'p',
      child: Text('Hello World'),
    );

    yield button([text('Toggle')], events: {'click': (e) => setState(() => toggled = !toggled)});

    yield div(
      styles: Styles.text(color: toggled ? Colors.blue : Colors.red),
      [component.child],
    );

    yield div(
      styles: Styles.text(color: Colors.green),
      [component.child],
    );
  }
}
