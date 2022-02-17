import 'package:jaspr/jaspr.dart';

import 'components/counter.dart';

class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Counter(key: GlobalKey());
  }
}
