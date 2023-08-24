// [sample][hidden] Tutorial
import 'package:jaspr/jaspr.dart';

import 'counter.dart';

void main() {
  runApp(App());
}

class App extends StatelessComponent {
  const App({Key? key}) : super(key: key);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'div',
      children: [
        DomComponent(
          tag: 'h1',
          child: Text('Hello World!'),
        ),
        DomComponent(
          tag: 'p',
          child: Text('You\'re great!'),
        ),
      ],
    );

    yield Counter();
  }
}
