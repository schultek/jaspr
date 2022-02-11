import 'package:dart_web/dart_web.dart';

import 'button.dart';
import 'counter.dart';

class Home extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Counter();

    yield Button(
      label: 'Go To About',
      onPressed: () {
        Router.of(context).push('/about', eager: true);
      },
    );
  }
}
