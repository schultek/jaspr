import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:jaspr_content/jaspr_content.dart';

import '../components/banner.dart';
import '../components/layout/footer.dart';
import '../components/layout/header.dart';
import '../constants/theme.dart';
import '../pages/home/home.dart';

class HomeLayout extends PageLayout {
  @override
  Pattern get name => 'home';

  @override
  Component buildLayout(Page page, Component child) {
    return Document(
      title: 'Jaspr | Dart Web Framework',
      lang: 'en',
      head: [link(rel: 'icon', type: 'image/x-icon', href: 'favicon.ico')],
      styles: [
        css('html.light .on-dark').styles(display: .none),
        css('html.dark .on-light').styles(display: .none),
      ],
      body: .fragment([
        Banner(),
        Header(),
        main_([Home()]),
        Footer(),
      ]),
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
