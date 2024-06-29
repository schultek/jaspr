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
    yield div(classes: "client", [
      text(component.name),
      button([text('Toggle')], events: {'click': (e) => setState(() => toggled = !toggled)}),
      if (!toggled) component.child else div(styles: Styles.text(color: Colors.white), [component.child]),
      //div(styles: Styles.text(color: Colors.gray), [component.child]),
      if (!component.name.endsWith("Nested"))
        div([
          App(name: "${component.name} Nested", child: div([text("Nest")])),
        ]),
    ]);
  }
}
