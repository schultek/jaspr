import 'package:dart_quotes/pages/home_page.dart';
import 'package:jaspr/server.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'pages/quote_page.dart';

class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: 'main', [
      Router(
        routes: [
          Route(path: '/', builder: (context, state) => HomePage()),
          Route(path: '/quote/:quoteId', builder: (context, state) => QuotePage(id: state.params['quoteId']!)),
        ],
      ),
    ]);
    yield a(classes: "github-badge", href: "https://github.com/schultek/jaspr", attributes: {
      'aria-label': "Find the source on Github"
    }, [
      img(src: '/images/github-badge.svg', alt: "Github Badge"),
    ]);
  }

  @css
  static final styles = [
    css('.main').styles(
      minHeight: 100.vh,
      maxWidth: 500.px,
      margin: Margin.all(Unit.auto),
      padding: Padding.symmetric(horizontal: 2.em),
    ),
    css('.github-badge').styles(
      position: Position.absolute(top: 0.px, right: 0.px),
    )
  ];
}
