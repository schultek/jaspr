import 'package:jaspr/jaspr.dart';

/// The root interactive component for this app.
///
/// This is automatically rendered on the client by using the @client annotation.
@client
class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    // Renders a <p> element with 'Hello World' content.
    yield p([
      text('Hello World'),
    ]);
  }
}
