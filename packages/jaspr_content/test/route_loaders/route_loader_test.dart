import 'dart:async';

import 'package:jaspr_content/jaspr_content.dart';
import 'package:test/test.dart';

void main() {
  group('RouteLoaderBase', () {
    test('limits concurrent eager loads to configured batch size', () async {
      const sourceCount = 100;
      final tracker = _LoadConcurrencyTracker();
      final loader = _TestRouteLoader(sourceCount, tracker);

      final routes = await loader.loadRoutes((_) => const PageConfig(), true);

      expect(routes, hasLength(sourceCount));
      // Should match the maximum defined in the implementation.
      const maxConcurrentLoads = 32;
      expect(tracker.maxConcurrent, equals(maxConcurrentLoads));
      expect(tracker.completedLoads, equals(sourceCount));
    });
  });
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
