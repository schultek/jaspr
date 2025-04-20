/// @docImport 'blog_layout.dart';
/// @docImport 'docs_layout.dart';
/// @docImport 'empty_layout.dart';
library;

import 'package:jaspr/server.dart';

import '../content/theme.dart';
import '../page.dart';

/// A layout for a page.
///
/// A page layout is responsible for wrapping the content of a page in a layout.
/// This may include adding a header, footer, or sidebar to the page.
///
/// When more than one layout is provided to the page's [PageConfig], the layout's [name] pattern is used to determined
/// which layout to choose for a page.
///
/// See also:
/// - [EmptyLayout]
/// - [DocsLayout]
/// - [BlogLayout]
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
  const PageLayoutBase();

  Component buildHead(Page page) {
    return Fragment(children: []);
  }

  Component buildBody(Page page, Component child);

  @override
  Component buildLayout(Page page, Component child) {
    final pageData = page.data['page'] ?? {};
    final siteData = page.data['site'] ?? {};

    final pageTitle = pageData['title'] ?? siteData['title'];
    final pageTitleBase = pageData['titleBase'] ?? siteData['titleBase'];

    final title = switch ((pageTitle, pageTitleBase)) {
      (String title, String base) => '$title | $base',
      (String title, _) => title,
      (_, String base) => base,
      _ => '',
    };

    final lang = pageData['lang'] ?? siteData['lang'];
    final favicon = siteData['favicon'];

    final description = pageData['description'];
    final keywords = pageData['keywords'];
    final image = pageData['image'];


    return Document(
      title: title,
      lang: lang,
      meta: {
        if (description case final desc?) 'description': desc.toString(),
        if (keywords case final keys?) 'keywords': keys is List ? keys.join(', ') : keys.toString(),
      },
      styles: resetStyles,
      head: [
        if (favicon != null) link(rel: 'icon', type: 'image/png', href: favicon!),
        meta(attributes: {'property': 'og:title'}, content: title),
        if (description case final desc?)
          meta(attributes: {'property': 'og:description'}, content: desc.toString()),
        if (image case final img?) meta(attributes: {'property': 'og:image'}, content: img.toString()),
        buildHead(page),
      ],
      body: buildBody(page, child),
    );
  }
}
