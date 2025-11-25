import 'package:jaspr/dom.dart';

@client
class App extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return p([.text('Hello World from Jaspr')]);
  }
}
