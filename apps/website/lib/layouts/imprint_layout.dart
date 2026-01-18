import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:jaspr_content/jaspr_content.dart';

import '../components/layout/footer.dart';
import '../components/layout/header.dart';
import '../constants/theme.dart';

class ImprintLayout extends PageLayout {
  @override
  Pattern get name => 'imprint';

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
        Header(showHome: true),
        main_(classes: 'markdown-content', [
          child,
        ]),
        Footer(),
      ]),
    );
  }

  @css
  static List<StyleRule> get styles => [
    css('.markdown-content', [
      css('&').styles(
        minHeight: 50.vh,
        padding: .only(top: 8.rem, left: contentPadding, right: contentPadding, bottom: 4.rem),
      ),
      css('h3').styles(margin: .only(top: 3.rem)),
    ]),
  ];
}
