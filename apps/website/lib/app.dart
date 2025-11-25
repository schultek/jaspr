import 'package:jaspr/dom.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'components/banner.dart';
import 'components/markdown_page.dart';
import 'constants/theme.dart';
import 'layout/footer.dart';
import 'layout/header.dart';
import 'pages/home/home.dart';

class App extends StatelessComponent {
  const App({super.key});

  @override
  Component build(BuildContext context) {
    return Router(
      routes: [
        Route(
          path: '/',
          builder: (_, _) => .fragment([
            Banner(),
            Header(),
            main_([Home()]),
            Footer(),
          ]),
        ),
        Route(path: '/imprint', title: 'Imprint', builder: (_, _) => MarkdownPage('lib/content/imprint.md')),
        Route(path: '/privacy', title: 'Privacy Policy', builder: (_, _) => MarkdownPage('lib/content/privacy.md')),
      ],
    );
  }

  @css
  static List<StyleRule> get styles => [
    css('main').styles(overflow: .hidden),
    css('section').styles(position: .relative()),
    css('#hero:before').combine(backgroundShade(40.vh, (-20).vw, w: 80.vw, h: 160.vh)),
    css('#devex:before').combine(backgroundShade(10.vh, 20.vw, w: 80.vw, h: 60.vh)),
    css('#testimonials:before').combine(backgroundShade((-10).vh, (-10).vw, w: 60.vw, h: 60.vh)),
    css('#community:before').combine(backgroundShade(60.vh, 10.vw, w: 80.vw, b: (-20).vh)),
  ];

  static Styles backgroundShade(Unit top, Unit left, {Unit? w, Unit? h, Unit? b, Unit? r}) {
    return Styles(
      content: '',
      position: .absolute(top: top, left: left, right: r, bottom: b),
      zIndex: .new(-1),
      width: w,
      height: h,
      radius: .circular(100.percent),
      opacity: 0.05,
      raw: {'filter': 'blur(64px)', '-webkit-filter': 'blur(64px)', 'background': primaryGradient},
    );
  }
}
