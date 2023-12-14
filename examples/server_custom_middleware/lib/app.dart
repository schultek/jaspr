import 'package:jaspr/jaspr.dart';

/// A basic jaspr component rendering "Hello World".
class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'p',
      child: Text('Hello World'),
    );
  }
}
