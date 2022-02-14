import 'package:dart_web/dart_web.dart';

import 'components/counter.dart';

class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Counter();
  }
}
