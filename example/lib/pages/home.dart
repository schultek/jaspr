import 'package:dart_web/dart_web.dart';

import '../components/button.dart';
import '../components/counter.dart';

class Home extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'span',
      child: Text('HOME'),
    );

    yield Counter();

    yield Button(
      label: 'About',
      onPressed: () {
        Router.of(context).push('/about', eager: true);
      },
    );
  }
}
