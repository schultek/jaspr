import 'package:jaspr/jaspr.dart';

// A simple [StatelessComponent] with a [build] method.{{#hydration}}
@client{{/hydration}}
class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    // Renders a <p> element with 'Hello World' content.
    yield p([
      text('Hello World'),
    ]);
  }
}
