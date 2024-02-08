import 'package:jaspr/jaspr.dart';

import '../components/header.dart';

class About extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Header();

    yield section([
      ol(styles: Styles.box(maxWidth: 500.px), [
        li([
          h3([text('Documentation')]),
          text('Jaspr\'s '),
          a(href: 'https://docs.page/schultek/jaspr', [text('official documentation')]),
          text(' provides you with all information you need to get started.'),
        ]),
        li([
          h3([text('Community')]),
          text('Got stuck? Ask your question on the official '),
          a(href: 'https://docs.page/schultek/jaspr', [text('Discord server')]),
          text(' for the Jaspr community.'),
        ]),
      ]),
    ]);
  }
}
