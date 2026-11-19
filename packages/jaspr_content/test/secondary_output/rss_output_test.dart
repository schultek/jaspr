import 'package:jaspr_content/jaspr_content.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  final loader = MockRouteLoader();

  Page page(String url, {Map<String, Object?> data = const {}, Map<String, Object?> site = const {}}) {
    return Page(
      path: 'page.md',
      url: url,
      content: '',
      initialData: {'page': data, 'site': site},
      config: const PageConfig(),
      loader: loader,
    );
  }

  String render(List<Page> pages, {Map<String, Object?> site = const {}}) {
    return RSSOutput().renderRssFeed(page('/', site: site), pages);
  }

  group('RSSOutput.renderRssFeed()', () {
    test('formats dates as RFC 822', () {
      final feed = render(
        [
          page('/post', data: {'title': 'Post', 'publishDate': '2026-11-13'}),
        ],
        site: {'publishDate': '2026-11-01'},
      );

      expect(feed, contains('<pubDate>Sun, 01 Nov 2026 00:00:00 GMT</pubDate>'));
      expect(feed, contains('<pubDate>Fri, 13 Nov 2026 00:00:00 GMT</pubDate>'));
      expect(feed, matches(RegExp(r'<lastBuildDate>\w{3}, \d{2} \w{3} \d{4} \d{2}:\d{2}:\d{2} GMT</lastBuildDate>')));
    });

    test('converts dates with a time zone to GMT', () {
      final feed = render([
        page('/post', data: {'title': 'Post', 'publishDate': '2026-11-13T10:30:00+02:00'}),
      ]);

      expect(feed, contains('<pubDate>Fri, 13 Nov 2026 08:30:00 GMT</pubDate>'));
    });

    test('keeps dates it cannot parse', () {
      final feed = render([
        page('/post', data: {'title': 'Post', 'publishDate': 'Fri, 13 Nov 2026 10:30:00 +0200'}),
      ]);

      expect(feed, contains('<pubDate>Fri, 13 Nov 2026 10:30:00 +0200</pubDate>'));
    });

    test('escapes text', () {
      final feed = render(
        [
          page('/post', data: {'title': 'Tips & <tricks>', 'description': 'A < B & C'}),
        ],
        site: {'title': 'Me & You', 'url': 'https://example.com'},
      );

      expect(feed, contains('<title>Me &amp; You</title>'));
      expect(feed, contains('<title>Tips &amp; &lt;tricks&gt;</title>'));
      expect(feed, contains('<description>A &lt; B &amp; C</description>'));
    });

    test('marks the guid as not a permalink', () {
      final feed = render(
        [
          page('/post', data: {'title': 'Post'}),
        ],
        site: {'url': 'https://example.com'},
      );

      expect(feed, contains('<link>https://example.com/post</link>'));
      expect(feed, contains('<guid isPermaLink="false">/post</guid>'));
    });

    test('starts with an XML declaration', () {
      final feed = render([]);

      expect(feed, startsWith('<?xml version="1.0" encoding="UTF-8"?>\n<rss version="2.0">'));
    });
  });
}
