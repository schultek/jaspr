import 'package:jaspr/jaspr.dart';

class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Document.head(title: 'a', meta: {'test': 'b', 'c': 'd'});
    yield div([
      Document.head(title: 'b', meta: {'c': 'e'}),
      Document.head(title: 'c'),
    ]);
  }
}
