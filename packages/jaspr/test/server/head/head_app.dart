import 'package:jaspr/jaspr.dart';

class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield const Head(title: 'a', meta: {'test': 'b', 'c': 'd'});
    yield div([
      const Head(title: 'b', meta: {'c': 'e'}),
      const Head(title: 'c'),
    ]);
  }
}
