import 'package:jaspr/jaspr.dart';

@client
class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield p([
      text('Hello World from Jaspr'),
    ]);
  }
}
