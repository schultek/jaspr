import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class App extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return div([
      Document.head(title: 'a', meta: {'test': 'b', 'c': 'd'}),
      div([
        Document.head(title: 'b', meta: {'c': 'e'}),
        Document.head(title: 'c'),
      ]),
    ]);
  }
}
