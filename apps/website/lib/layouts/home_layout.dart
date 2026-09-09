import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:jaspr_content/jaspr_content.dart';

import '../components/banner.dart';
import '../components/layout/footer.dart';
import '../components/layout/header.dart';
import '../constants/theme.dart';

class HomeLayout extends PageLayout {
  @override
  Pattern get name => 'home';

  @override
  Component buildLayout(Page page, Component child) {
    final pageData = page.data;
    final rawTitle = pageData['title'] as String? ?? 'Jaspr';
    final title = rawTitle == 'Jaspr' ? 'Jaspr | Dart Web Framework' : rawTitle;
    final description = pageData['description'] as String?;
    final keywords = pageData['keywords'] as String?;
    final author = pageData['author'] as String?;

    final og = pageData['og'] as Map<String, Object?>?;
    final ogTitle = og?['title'] as String? ?? title;
    final ogDescription = og?['description'] as String? ?? description;
    final ogImage = og?['image'] as String? ?? 'https://jaspr.site/images/og_image.png';

    return Document(
      title: title,
      lang: 'en',
      head: [
        link(rel: 'icon', type: 'image/x-icon', href: 'favicon.ico'),
        if (description != null) meta(attributes: {'name': 'description'}, content: description),
        if (keywords != null) meta(attributes: {'name': 'keywords'}, content: keywords),
        if (author != null) meta(attributes: {'name': 'author'}, content: author),
        meta(attributes: {'property': 'og:title'}, content: ogTitle),
        if (ogDescription != null) meta(attributes: {'property': 'og:description'}, content: ogDescription),
        meta(attributes: {'property': 'og:image'}, content: ogImage),
      ],
      styles: [
        css('html.light .on-dark').styles(display: .none),
        css('html.dark .on-light').styles(display: .none),
      ],
      body: .fragment([
        Banner(),
        Header(showHome: page.url != '/'),
        main_([child]),
        Footer(),
      ]),
    );
  }

  @css
  static List<StyleRule> get styles => [
    css('main').styles(overflow: .hidden),
    css('section').styles(position: .relative()),
    css('#hero:before').combine(backgroundShade(40.vh, (-20).vw, w: 80.vw, h: 160.vh)),
    css('#content-teaser:before').combine(backgroundShade(10.vh, (-10).vw, w: 70.vw, h: 50.vh)),
    css('#devex:before').combine(backgroundShade(10.vh, 20.vw, w: 80.vw, h: 60.vh)),
    css('#showcase:before').combine(backgroundShade((-5).vh, 15.vw, w: 70.vw, h: 50.vh)),
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
