import 'dart:convert';

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
  bool include(Page page) => page.data.page['rss'] != false;
}

class _OptInRSSFilter implements RSSFilter {
  const _OptInRSSFilter();

  @override
  bool include(Page page) => page.data.page['rss'] == true;
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
    return Builder(
      builder: (context) {
        context.setHeader('Content-Type', 'text/xml');
        context.setStatusCode(200, responseBody: renderRssFeed(page, context.pages));
        return Component.text('');
      },
    );
  }

  /// The standard date format for dates within an RSS feed.
  ///
  /// This is the RFC 822 format that RSS 2.0 requires, such as `Fri, 13 Nov 2026 00:00:00 GMT`.
  /// It always writes `GMT`, so format dates in UTC.
  static final rssDateFormat = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'", 'en_US');

  /// Formats a date from the page or site data, such as `2026-11-13`, as an RSS date.
  ///
  /// A date without a time zone is read as UTC. A value that is not a date is kept as it is,
  /// so that dates already written in the RSS format keep working.
  static String _formatDate(Object value) {
    final date = DateTime.tryParse(value.toString());
    if (date == null) return value.toString();
    final utc = date.isUtc ? date : DateTime.utc(date.year, date.month, date.day, date.hour, date.minute, date.second);
    return rssDateFormat.format(utc);
  }

  static String _escape(Object value) => const HtmlEscape(HtmlEscapeMode.element).convert(value.toString());

  static RSSItem _defaultItemBuilder(Page page) {
    final pageData = page.data.page;
    return RSSItem(
      title: pageData['title'] as String? ?? '',
      description: pageData['description'] as String?,
      pubDate: pageData['publishDate'] as String?,
      author: pageData['author'] as String?,
    );
  }

  String renderRssFeed(Page page, List<Page> pages) {
    final siteData = page.data.site;
    final title = this.title ?? siteData['title'] ?? '/';
    final siteUrl = this.siteUrl ?? siteData['url'] ?? '';
    final description = this.description ?? siteData['description'] ?? '/';
    final language = this.language ?? siteData['language'] ?? 'en-US';

    final lastBuildDate = rssDateFormat.format(DateTime.now().toUtc());
    final pubDate = switch (siteData['publishDate']) {
      final Object date => _formatDate(date),
      null => lastBuildDate,
    };

    final items = <String>[];

    for (final page in pages) {
      if (!filter.include(page)) {
        continue;
      }

      final item = itemBuilder(page);

      var itemSource =
          '''
    <item>
      <title>${_escape(item.title)}</title>
      <link>${_escape('$siteUrl${page.url}')}</link>''';

      if (item.description case final desc?) {
        itemSource += '''
      <description>${_escape(desc)}</description>''';
      }
      if (item.pubDate case final pubDate?) {
        itemSource += '''
      <pubDate>${_escape(_formatDate(pubDate))}</pubDate>''';
      }
      itemSource += '''
      <guid isPermaLink="false">${_escape(page.url)}</guid>''';

      if (item.author case final author?) {
        itemSource += '''
      <author>${_escape(author)}</author>''';
      }
      itemSource += '''
    </item>''';
      items.add(itemSource);
    }

    final feed =
        '''
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <title>${_escape(title)}</title>
    <link>${_escape(siteUrl)}</link>
    <description>${_escape(description)}</description>
    <language>${_escape(language)}</language>
    <pubDate>${_escape(pubDate)}</pubDate>
    <lastBuildDate>$lastBuildDate</lastBuildDate>
${items.reversed.join('\n')}
  </channel>
</rss>''';
    return feed;
  }
}

class RSSItem {
  const RSSItem({required this.title, this.description, this.pubDate, this.author});

  final String title;
  final String? description;
  final String? pubDate;
  final String? author;
}
