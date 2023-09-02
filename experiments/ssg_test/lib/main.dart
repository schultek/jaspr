import 'package:jaspr/server.dart';
import 'package:jaspr_router/jaspr_router.dart';

import './app.dart';

void main() {
  runApp(Document(
    title: 'ssg_test',
    styles: [
      StyleRule.import('https://fonts.googleapis.com/css?family=Roboto'),
      StyleRule(
        selector: const Selector.list([Selector.tag('html'), Selector.tag('body')]),
        styles: Styles.combine([
          const Styles.text(
            fontFamily: FontFamily.list([FontFamily('Roboto'), FontFamilies.sansSerif]),
          ),
          Styles.box(
            width: 100.percent,
            height: 100.percent,
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
          ),
        ]),
      ),
    ],
    body: Router(routes: [
      Route(path: '/', builder: (_, __) => App('Home')),
      Route(path: '/about', builder: (_, __) => App('About'), routes: [
        Route(path: 'what_we_do', builder: (_, __) => App('What We Do')),
        Route(path: 'portfolio', builder: (_, __) => App('Portfolio')),
      ]),
      Route(path: '/contact', builder: (_, __) => App('Contact')),
    ]),
  ));
}
