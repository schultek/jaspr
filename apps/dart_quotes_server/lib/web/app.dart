import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'pages/home_page.dart';
import 'pages/quote_page.dart';

class App extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return .fragment([
      div(classes: 'main', [
        Router(
          routes: [
            Route(path: '/', builder: (context, state) => HomePage()),
            Route(
              path: '/quote/:quoteId',
              builder: (context, state) => QuotePage(id: int.tryParse(state.params['quoteId']!) ?? 0),
            ),
          ],
        ),
      ]),
      a(
        classes: "github-badge",
        href: "https://github.com/schultek/jaspr",
        attributes: {'aria-label': "Find the source on Github"},
        [img(src: '/images/github-badge.svg', alt: "Github Badge")],
      ),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.main').styles(
      minHeight: 100.vh,
      maxWidth: 500.px,
      padding: .symmetric(horizontal: 2.em),
      margin: .all(.auto),
    ),
    css('.github-badge').styles(
      position: .absolute(top: 0.px, right: 0.px),
    ),
  ];
}
