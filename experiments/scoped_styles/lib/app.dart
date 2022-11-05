import 'package:jaspr/jaspr.dart';

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
      child: DomComponent(tag: 'div', classes: ['content']), // this will be blue
    );

    yield DomComponent(tag: 'div', classes: ['content']); // this not
  }
}
