import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

@client
class App extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return p([.text('Hello World from Jaspr')]);
  }
}
