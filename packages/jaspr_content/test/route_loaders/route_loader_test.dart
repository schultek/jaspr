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

      test('resolves the config for the exact prefix of each loader with PageConfig.matchUrlPrefix', () async {
        // Arrange: Nested prefixes, a prefix without a config, and a loader without a prefix.
        final docsConfig = PageConfig();
        final v1Config = PageConfig();
        final fallback = PageConfig();
        final loaders = [
          for (final prefix in ['/docs', '/docs/v1', '/blog', null])
            MemoryLoader(
              urlPrefix: prefix,
              pages: [const MemoryPage(path: 'guide.md')],
            ),
        ];

        // Act: Load the routes of every loader with the same resolver.
        final resolver = PageConfig.matchUrlPrefix({'/docs': docsConfig, '/docs/v1': v1Config}, fallback: fallback);
        for (final loader in loaders) {
          await loader.loadRoutes(resolver, false);
        }

        // Assert: The page under /docs/v1 gets its own config, even though its URL also starts with /docs.
        final [docs, v1, blog, unprefixed] = [for (final loader in loaders) loader.sources.single];
        expect(docs.config, same(docsConfig));
        expect(v1.url, equals('/docs/v1/guide'));
        expect(v1.config, same(v1Config));

        // Assert: The other pages get the fallback config.
        expect(blog.config, same(fallback));
        expect(unprefixed.config, same(fallback));
      });

      test('resolves the default config without a fallback with PageConfig.matchUrlPrefix', () async {
        // Arrange: A loader whose prefix has no config, and a config that differs from the default.
        final docsConfig = PageConfig(enableFrontmatter: false, parsers: [MarkdownParser()]);
        final loader = MemoryLoader(
          urlPrefix: '/blog',
          pages: [const MemoryPage(path: 'post.md')],
        );

        // Act: Load the routes with a resolver that has no fallback.
        await loader.loadRoutes(PageConfig.matchUrlPrefix({'/docs': docsConfig}), false);

        // Assert: The page gets a default config instead of the one for another prefix.
        final config = loader.sources.single.config;
        expect(config, isNot(same(docsConfig)));
        expect(config.enableFrontmatter, isTrue);
        expect(config.parsers, isEmpty);
        expect(config.layouts, isEmpty);
        expect(config.theme, isNull);
      });

      // A key that isn't a valid prefix can't be the prefix of any loader.
      for (final key in ['', '/', 'docs', '/docs/', '/docs/1.2']) {
        test('rejects the key "$key" for PageConfig.matchUrlPrefix', () {
          expect(
            () => PageConfig.matchUrlPrefix({'/docs': PageConfig(), key: PageConfig()}),
            throwsA(isA<ArgumentError>().having((error) => error.name, 'name', 'configs')),
          );
        });
      }

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
