import 'package:jaspr/jaspr.dart' hide Style;

import 'components/style.dart';

class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Style(
      scoped: true,
      style: '''
        .content {
          background: blue;
        }
      ''',
      child: div(classes: 'content', []), // this will be blue
    );

    yield div(classes: 'content', []); // this not
  }
}
