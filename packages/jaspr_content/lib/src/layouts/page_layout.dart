import 'package:jaspr/server.dart';

import '../content/content.dart';
import '../page.dart';

/// A layout for a page.
/// 
/// A page layout is responsible for wrapping the content of a page in a layout.
/// This may include adding a header, footer, or sidebar to the page.
/// 
/// When more than one layout is provided to the page's [PageConfig], the layout's [name] pattern is used to determined 
/// which layout to choose for a page.
abstract class PageLayout {
  /// The name pattern that the layout matches.
  /// 
  /// The layout is chosen if its name pattern matches the 'layout' key in the page data.
  /// The layout may also be chosen if it is the first provided layout and no other layout matches for the page.
  Pattern get name;

  /// Builds the layout for the given page and child component.
  Component buildLayout(Page page, Component child);
}

/// A base implementation of a page layout.
abstract class PageLayoutBase implements PageLayout {
  const PageLayoutBase({
    this.favicon,
    this.lang = 'en',
  });

  final String? favicon;
  final String lang;

  Component buildHead(Page page) {
    return Fragment(children: []);
  }

  Component buildBody(Page page, Component child);

  @override
  Component buildLayout(Page page, Component child) {
    return Document(
      title: switch ((page.data['title'], page.data['titleBase'])) {
        (String title, String base) => '$title | $base',
        (String title, _) => title,
        (_, String base) => base,
        _ => '',
      },
      lang: page.data['lang'] ?? lang,
      styles: resetStyles,
      head: [
        if (favicon != null) link(rel: 'icon', type: 'image/png', href: favicon!),
        buildHead(page),
      ],
      body: buildBody(page, child),
    );
  }
}
