/// @docImport 'blog_layout.dart';
/// @docImport 'docs_layout.dart';
/// @docImport 'empty_layout.dart';
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

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

  @mustCallSuper
  Iterable<Component> buildHead(Page page) sync* {
    final pageData = page.data.page;
    final siteData = page.data.site;

    final pageTitle = pageData['title'] ?? siteData['title'];
    final pageTitleBase = pageData['titleBase'] ?? siteData['titleBase'];

    final title = switch ((pageTitle, pageTitleBase)) {
      (final String title, final String base) => '$title | $base',
      (final String title, _) => title,
      (_, final String base) => base,
      _ => '',
    };

    yield Component.element(tag: 'title', children: [Component.text(title)]);
    yield meta(attributes: {'property': 'og:title'}, content: title);

    if (siteData['favicon'] case final String faviconHref) {
      yield link(rel: 'icon', type: 'image/png', href: faviconHref);
    }

    final description = pageData['description'];
    final keywords = pageData['keywords'];
    final image = pageData['image'];
    final metaData = pageData['meta'];

    if (description case final desc?) {
      yield meta(name: 'description', content: desc.toString());
    }
    if (keywords case final keys?) {
      yield meta(name: 'keywords', content: keys is List ? keys.join(', ') : keys.toString());
    }
    if (metaData case final Map<String, Object?> metaData?) {
      for (final MapEntry(key: name, value: content) in metaData.entries) {
        yield meta(name: name, content: content as String?);
      }
    }

    if (description case final desc?) {
      yield meta(attributes: {'property': 'og:description'}, content: desc.toString());
    }
    if (image case final img?) {
      yield meta(attributes: {'property': 'og:image'}, content: img.toString());
    }
    if (metaData case final List<Object?> metaData?) {
      for (final item in metaData) {
        if (item is Map<Object?, Object?>) {
          yield meta(attributes: item.cast());
        }
      }
    }
  }

  Component buildBody(Page page, Component child);

  @override
  Component buildLayout(Page page, Component child) {
    final lang = switch (page.data) {
      {'page': {'lang': final String lang}} => lang,
      {'site': {'lang': final String lang}} => lang,
      _ => null,
    };

    final base = switch (page.data) {
      {'site': {'base': final String base}} => base,
      {'site': {'base': final bool base}} => base ? '/' : null,
      _ => '/',
    };

    return Document(lang: lang, base: base, meta: {}, head: buildHead(page).toList(), body: buildBody(page, child));
  }
}
