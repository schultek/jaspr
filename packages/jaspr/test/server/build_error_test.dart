/// @docImport 'package:jaspr/src/server/async_build_owner.dart';
@TestOn('vm')
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:jaspr_test/server_test.dart';

import 'render_test.dart';

void main() {
  group('build error', () {
    setUpAll(() {
      Jaspr.initializeApp();
    });

    test('completes the render when a build step throws outside build()', () async {
      final result = await renderComponent(const ThrowsInDidRebuild()).timeout(
        const Duration(seconds: 30),
        onTimeout: () => fail('render never completed'),
      );

      expect(result.statusCode, 500);
    });

    test('completes the render when the throwing element has an async ancestor', () async {
      final result = await renderComponent(const Preloading(child: ThrowsInDidRebuild())).timeout(
        const Duration(seconds: 30),
        onTimeout: () => fail('render never completed'),
      );

      expect(result.statusCode, 500);
    });

    test('renders normally when nothing throws', () async {
      final result = await renderComponent(const Preloading(child: Component.text('ok')), standalone: true);

      expect(result.statusCode, 200);
      expect(result.body, decodedMatches(contains('ok')));
    });
  });
}

/// Throws from [Element.didRebuild], which [AsyncBuildOwner] invokes from inside
/// a [TaskChain] step rather than from the guarded [BuildableElement.performRebuild]
/// path, so the throw is not caught by the usual build error handling.
class ThrowsInDidRebuild extends StatelessComponent {
  const ThrowsInDidRebuild({super.key});

  @override
  Element createElement() => _ThrowsInDidRebuildElement(this);

  @override
  Component build(BuildContext context) => div([]);
}

class _ThrowsInDidRebuildElement extends StatelessElement {
  _ThrowsInDidRebuildElement(super.component);

  @override
  void didRebuild() {
    throw StateError('build step failed');
  }
}

/// Suspends the build with [PreloadStateMixin], so its subtree is built from an
/// asynchronous continuation.
class Preloading extends StatefulComponent {
  const Preloading({super.key, required this.child});

  final Component child;

  @override
  State<Preloading> createState() => _PreloadingState();
}

class _PreloadingState extends State<Preloading> with PreloadStateMixin {
  @override
  Future<void> preloadState() async {
    await Future<void>.delayed(Duration.zero);
  }

  @override
  Component build(BuildContext context) => div([span([]), component.child, span([])]);
}
