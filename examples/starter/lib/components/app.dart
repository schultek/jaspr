import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'home.dart';
import 'whats_next.dart';

// A simple [StatelessComponent] with a [build] method.
@client
class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Router(routes: [
      Route(path: '/', title: 'Home', builder: (context, state) => Home()),
      Route(path: '/whats-next', title: 'Whats Next', builder: (context, state) => WhatsNext()),
    ]);
  }
}
