/// @docImport 'docs/layout.dart';
/// @docImport 'empty_layout.dart';
library;

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
///
/// See also:
/// - [EmptyLayout]
/// - [DocsLayout]
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
    final title = switch ((page.data['title'], page.data['titleBase'])) {
      (String title, String base) => '$title | $base',
      (String title, _) => title,
      (_, String base) => base,
      _ => '',
    };
    return Document(
      title: title,
      lang: page.data['lang'] ?? lang,
      meta: {
        if (page.data['description'] case final desc?) 'description': desc.toString(),
        if (page.data['keywords'] case final keys?) 'keywords': keys is List ? keys.join(', ') : keys.toString(),
      },
      styles: resetStyles,
      head: [
        if (favicon != null) link(rel: 'icon', type: 'image/png', href: favicon!),
        meta(attributes: {'property': 'og:title'}, content: title),
        if (page.data['description'] case final desc?)
          meta(attributes: {'property': 'og:description'}, content: desc.toString()),
        if (page.data['image'] case final img?) meta(attributes: {'property': 'og:image'}, content: img.toString()),
        buildHead(page),
      ],
      body: buildBody(page, child),
    );
  }
}
