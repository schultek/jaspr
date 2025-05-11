import 'package:intl/intl.dart';
import 'package:jaspr/server.dart';

import '../page.dart';
import 'secondary_output.dart';

abstract class RSSFilter {
  static const optOut = _OptOutRSSFilter();
  static const optIn = _OptInRSSFilter();

  const factory RSSFilter.custom(bool Function(Page page) include) = _CustomRSSFilter;

  bool include(Page page);
}

class _OptOutRSSFilter implements RSSFilter {
  const _OptOutRSSFilter();

  @override
  bool include(Page page) => page.data['page']?['rss'] != false;
}

class _OptInRSSFilter implements RSSFilter {
  const _OptInRSSFilter();

  @override
  bool include(Page page) => page.data['page']?['rss'] == true;
}

class _CustomRSSFilter implements RSSFilter {
  const _CustomRSSFilter(this._include);

  final bool Function(Page page) _include;

  @override
  bool include(Page page) => _include(page);
}

/// Outputs a rss feed for your pages.
class RSSOutput extends SecondaryOutput {
  RSSOutput({
    this.title,
    this.description,
    this.siteUrl,
    this.language,
    this.filter = RSSFilter.optOut,
    this.itemBuilder = _defaultItemBuilder,
  });

  final String? title;
  final String? description;
  final String? siteUrl;
  final String? language;
  final RSSFilter filter;
  final RSSItem Function(Page page) itemBuilder;

  @override
  final Pattern pattern = RegExp(r'/?index\..*');

  @override
  String createRoute(String route) {
    return '/rss.xml';
  }

  @override
  Component build(Page page) {
    return Builder(builder: (context) sync* {
      context.setHeader('Content-Type', 'text/xml');
      context.setStatusCode(200, responseBody: renderRssFeed(page, context.pages));
    });
  }
  
  
  /// The standard date format for dates within an RSS feed.
  static final rssDateFormat = DateFormat("dd MMM yyyy");

  static RSSItem _defaultItemBuilder(Page page) {
    final pageData = page.data['page'] ?? {};
    return RSSItem(
      title: pageData['title'] ?? '',
      description: pageData['description'],
      pubDate: pageData['publishDate'],
      author: pageData['author'],
    );
  }

  String renderRssFeed(Page page, List<Page> pages) {

    final title = this.title ?? page.data['site']?['title'] ?? '/';
    final siteUrl = this.siteUrl ?? page.data['site']?['url'] ?? '';
    final description = this.description ?? page.data['site']?['description'] ?? '/';
    final language = this.language ?? page.data['site']?['language'] ?? 'en-US';

    final pubDate = page.data['site']?['publishDate'] ?? rssDateFormat.format(DateTime.now());
    final lastBuildDate = rssDateFormat.format(DateTime.now());

    final items = <String>[];

    for (final page in pages) {
      if (!filter.include(page)) {
        continue;
      }

      final item = itemBuilder(page);

      var itemSource = '''
    <item>
      <title>${item.title}</title>
      <link>$siteUrl${page.url}</link>''';

      if (item.description case final desc?) {
        itemSource += '''
      <description>$desc</description>''';
      }
      if (item.pubDate case final pubDate?) {
        itemSource += '''
      <pubDate>$pubDate</pubDate>''';
      }
      itemSource += '''
      <guid>${page.url}</guid>''';

      if (item.author case final author?) {
        itemSource += '''
      <author>$author</author>''';
      }
      itemSource += '''
    </item>''';
      items.add(itemSource);
    }

    final feed = '''
<rss version="2.0">
  <channel>
    <title>$title</title>
    <link>$siteUrl</link>
    <description>$description</description>
    <language>$language</language>
    <pubDate>$pubDate</pubDate>
    <lastBuildDate>$lastBuildDate</lastBuildDate>
${items.reversed.join('\n')}
  </channel>
</rss>''';
    return feed;
  }
}

class RSSItem {
  const RSSItem({
    required this.title,
    this.description,
    this.pubDate,
    this.author,
  });

  final String title;
  final String? description;
  final String? pubDate;
  final String? author;
}

