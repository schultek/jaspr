import 'package:jaspr/jaspr.dart';

@client
class App extends StatefulComponent {
  App({required this.name, required this.child}) {
    print(("Server Component", child));
  }

  final String name;
  final Component child;

  @override
  State<StatefulComponent> createState() => AppState();
}

class AppState extends State<App> {
  bool toggled = false;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield p([text("Hello ${component.name} from App")]);

    yield button([text('Toggle')], events: {'click': (e) => setState(() => toggled = !toggled)});

    yield div(
      classes: "client",
      styles: Styles.text(color: toggled ? Colors.blue : Colors.red),
      [component.child],
    );

    yield div(
      classes: "client2",
      styles: Styles.text(color: Colors.green),
      [component.child],
    );
  }
}
