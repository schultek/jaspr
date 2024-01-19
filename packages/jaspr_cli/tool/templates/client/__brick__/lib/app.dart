import 'package:jaspr/jaspr.dart';

/// The root component for this app.
class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    // Renders a <p> element with 'Hello World' content.
    yield p([
      text('Hello World'),
    ]);
  }
}
