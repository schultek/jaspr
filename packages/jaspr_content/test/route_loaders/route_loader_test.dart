import 'dart:async';

import 'package:jaspr_content/jaspr_content.dart';
import 'package:jaspr_router/jaspr_router.dart' show Route, RouteBase;
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('RouteLoaderBase', () {
    test('limits concurrent eager loads to configured batch size', () async {
      const sourceCount = 100;
      final tracker = _LoadConcurrencyTracker();
      final loader = _TestRouteLoader(sourceCount, tracker);

      final routes = await loader.loadRoutes((_) => const PageConfig(), true);

      expect(routes, hasLength(sourceCount));
      // Should match the maximum defined in the implementation.
      const maxConcurrentLoads = 64;
      expect(tracker.maxConcurrent, equals(maxConcurrentLoads));
      expect(tracker.completedLoads, equals(sourceCount));
    });

    group('urlPrefix', () {
      test('prefixes the URL of each page, but not its path', () async {
        // Arrange
        final guideConfig = PageConfig();
        final loader = MemoryLoader(
          urlPrefix: '/docs/v2',
          pages: [
            const MemoryPage(path: 'index.md'),
            const MemoryPage(path: 'guide/intro.md'),
            const MemoryPage(path: 'index.html', keepSuffix: true),
            const MemoryPage(path: ''),
          ],
        );

        // Act
        final routes = await loader.loadRoutes(PageConfig.match({'guide/': guideConfig}), false);

        // Assert: A root index page and an empty path get the prefix as their URL.
        expect(
          loader.sources,
          equals([
            pageSource('index.md', '/docs/v2'),
            pageSource('guide/intro.md', '/docs/v2/guide/intro'),
            pageSource('index.html', '/docs/v2/index.html'),
            pageSource('', '/docs/v2'),
          ]),
        );
        expect(_routePaths(routes), equals(['/docs/v2', '/docs/v2/guide/intro', '/docs/v2/index.html']));

        // Assert: Config patterns match the path without the prefix.
        final intro = loader.sources[1];
        expect(intro.config, same(guideConfig));

        // Assert: The page keeps the path, and gets the prefixed URL.
        await intro.load();
        expect(intro.page!.path, equals('guide/intro.md'));
        expect(intro.page!.url, equals('/docs/v2/guide/intro'));
        expect(intro.page!.data.page, containsPair('url', '/docs/v2/guide/intro'));
      });

      test('prefixes the URLs of GitHub pages', () {
        // Arrange
        final loader = GitHubLoader('owner/repo', urlPrefix: '/docs');

        // Act
        final source = GitHubPageSource('guide/intro.md', 'https://api.github.com/blob', loader);

        // Assert
        expect(source, pageSource('guide/intro.md', '/docs/guide/intro'));
      });

      test('routes secondary outputs under the prefix', () async {
        // Arrange
        final loader = MemoryLoader(
          urlPrefix: '/docs/v2',
          pages: [
            const MemoryPage(path: 'index.md'),
            const MemoryPage(path: 'guide/intro.md'),
          ],
        );

        // Act
        final routes = await loader.loadRoutes((_) => PageConfig(secondaryOutputs: [MarkdownOutput()]), false);

        // Assert
        expect(
          _routePaths(routes),
          equals([
            '/docs/v2',
            '/docs/v2/index.html.md',
            '/docs/v2/guide/intro',
            '/docs/v2/guide/intro/index.html.md',
          ]),
        );
      });

      // A dot is only rejected in the last segment.
      for (final prefix in ['/docs', '/docs/v2', '/0.10.0/docs', '/docs/v(2)', '/.well-known/docs', '/a-b_c~d']) {
        test('accepts the prefix $prefix', () {
          expect(MemoryLoader(pages: [], urlPrefix: prefix).urlPrefix, equals(prefix));
        });
      }

      for (final prefix in [
        '',
        'docs',
        '/',
        '/docs/',
        '//docs',
        '/docs//v2',
        '/docs/./v2',
        '/docs/..',
        '/docs/:version',
        '/docs/0.10.0',
        '/.well-known',
        '/docs?v=2',
        '/docs#v2',
        '/docs/v 2',
        '/docs/über',
        '/docs/a"b',
        '/docs/caf%C3%A9',
      ]) {
        test('rejects the prefix "$prefix"', () {
          expect(() => MemoryLoader(pages: [], urlPrefix: prefix), throwsArgumentError);
        });
      }
    });
  });
}

/// Returns the paths of the [routes].
List<String> _routePaths(List<RouteBase> routes) {
  return [for (final route in routes.cast<Route>()) route.path];
}

class _TestRouteLoader extends RouteLoaderBase<_TestPageSource> {
  _TestRouteLoader(this.sourceCount, this.tracker);

  final int sourceCount;
  final _LoadConcurrencyTracker tracker;

  @override
  Future<List<_TestPageSource>> loadPageSources() async {
    return [
      for (var pageIndex = 0; pageIndex < sourceCount; pageIndex += 1)
        _TestPageSource('page-$pageIndex.md', this, tracker),
    ];
  }
}

class _TestPageSource extends PageSource {
  _TestPageSource(super.path, super.loader, this.tracker);

  final _LoadConcurrencyTracker tracker;

  @override
  Future<Page> buildPage() async {
    tracker.start();
    try {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    } finally {
      tracker.finish();
    }

    return Page(
      path: path,
      url: url,
      content: '# $path',
      config: config,
      loader: loader,
    );
  }
}

class _LoadConcurrencyTracker {
  int _inFlight = 0;
  int maxConcurrent = 0;
  int completedLoads = 0;

  void start() {
    _inFlight += 1;
    if (_inFlight > maxConcurrent) {
      maxConcurrent = _inFlight;
    }
  }

  void finish() {
    _inFlight -= 1;
    completedLoads += 1;
  }
}
