import 'package:jaspr/jaspr.dart';

class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Head(title: 'a', meta: {'test': 'b', 'c': 'd'});
    yield div([
      Head(title: 'b', meta: {'c': 'e'}),
      Head(title: 'c'),
    ]);
  }
}
