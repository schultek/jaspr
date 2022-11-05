import 'package:jaspr/jaspr.dart';

@app
class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'p',
      child: Text('Hello World from Jaspr'),
    );
  }
}
