// ignore_for_file: invalid_use_of_internal_member
part of '../core.dart';

/// {@template riverpod.provider_scope}
/// A component that stores the state of providers.
///
/// All Jaspr applications using Riverpod must contain a [ProviderScope] at
/// the root of their client-side component tree. It is done as followed:
///
/// ```dart
/// void main() {
///   runApp(
///     // Enabled Riverpod for the entire application
///     ProviderScope(
///       child: MyApp(),
///     ),
///   );
/// }
/// ```
///
/// It's optionally possible to specify `overrides` to change the behavior of
/// some providers. This can be useful for testing purposes:
///
/// ```dart
/// testComponents('Test example', (tester) async {
///   await tester.pumpComponent(
///     ProviderScope(
///       overrides: [
///         // override the behavior of repositoryProvider to provide a fake
///         // implementation for test purposes.
///         repositoryProvider.overrideWithValue(FakeRepository()),
///       ],
///       child: MyApp(),
///     ),
///   );
/// });
/// ```
///
///
/// Similarly, it is possible to insert other [ProviderScope] anywhere inside
/// the widget tree to override the behavior of a provider for only a part of the
/// application:
///
/// ```dart
/// final themeProvider = Provider((ref) => MyTheme.light());
///
/// void main() {
///   runApp(
///     ProviderScope(
///       child: Router(
///         routes: [
///           // Overrides themeProvider for the /gallery route only
///           Route(
///             path: '/gallery',
///             builder: (_) => ProviderScope(
///               overrides: [
///                 themeProvider.overrideWithValue(MyTheme.dark()),
///               ],
///             ),
///           ),
///         ],
///       ),
///     ),
///   );
/// }
/// ```
///
/// See also:
/// - [ProviderContainer], a Dart-only class that allows manipulating providers
/// - [UncontrolledProviderScope], which exposes a [ProviderContainer] to the widget
///   tree without managing its life-cycles.
/// {@endtemplate}
/// {@category Core}
final class ProviderScope extends StatefulComponent {
  /// {@macro riverpod.provider_scope}
  const ProviderScope({
    super.key,
    this.sync = const [],
    this.overrides = const [],
    this.observers,
    this.retry,
    required this.child,
  });

  /// Read the current [ProviderContainer] for a [BuildContext].
  static ProviderContainer containerOf(BuildContext context, {bool listen = true}) {
    return _scopeOf(context, listen: listen).component.container;
  }

  static _UncontrolledProviderScopeElement _scopeOf(BuildContext context, {bool listen = true}) {
    var element =
        context.getElementForInheritedComponentOfExactType<UncontrolledProviderScope>()
            as _UncontrolledProviderScopeElement?;

    if (element == null) {
      throw StateError('No ProviderScope found');
    }

    if (listen) {
      context.dependOnInheritedElement(element);
    }

    return element;
  }

  /// The retry logic used by providers associated to this container.
  ///
  /// See [ProviderContainer.defaultRetry] for information about the
  /// default retry logic.
  final Retry? retry;

  /// The part of the widget tree that can use Riverpod and has overridden providers.
  final Component child;

  /// The listeners that subscribes to changes on providers stored on this [ProviderScope].
  final List<ProviderObserver>? observers;

  /// Information on how to override a provider/family.
  ///
  /// Overrides are created using methods such as [Provider.overrideWith]/[Provider.overrideWithValue].
  ///
  /// This can be used for:
  /// - testing, by mocking a provider.
  /// - dependency injection, to avoid having to pass a value to many
  ///   widgets in the widget tree.
  /// - performance optimization: By using this to inject values to widgets
  ///   using `ref` inside of their constructor, widgets may be able to use
  ///   `const` constructors, which can improve performance.
  ///
  /// **Note**: Overrides only apply to this [ProviderScope] and its descendants.
  /// Ancestors of this [ProviderScope] will not be affected by the overrides.
  final List<Override> overrides;

  final List<ProviderSync> sync;

  @override
  ProviderScopeState createState() => ProviderScopeState();
}

/// Do not use: The [State] of [ProviderScope]
@internal
final class ProviderScopeState extends State<ProviderScope> with SyncScopeMixin {
  /// The [ProviderContainer] exposed to [ProviderScope.child].
  @override
  @visibleForTesting
  late final ProviderContainer container;
  ProviderContainer? _debugParentOwner;
  var _dirty = false;

  bool didInitContainer = false;

  @override
  Future<void> preloadState() {
    _initContainer();
    return _preloadSyncProviders();
  }

  @override
  void initState() {
    super.initState();
    assert(!kIsWeb || !didInitContainer, 'Container should not be pre-initialized on the web.');
    _initContainer();
  }

  void _initContainer() {
    if (didInitContainer) return;
    didInitContainer = true;

    final parent = _getParent();
    if (kDebugMode) {
      _debugParentOwner = parent;
    }

    assert(() {
      if (parent == null) return true;

      for (final s in component.sync) {
        if ((s as _ProviderSync).provider.dependencies == null) {
          print(
            '[WARNING] Tried to sync provider "${s.provider.name ?? s.provider.runtimeType}" on a nested ProviderScope, but the provider did not specify dependencies.\n'
            '  Because syncing a provider will override it on the client, and overriding in a nested ProviderScope requires the provider to specify dependencies, the sync will fail.\n'
            '  To fix this, either specify dependencies for the provider (e.g. `Provider(..., dependencies: [])`) and its dependents, or sync it on the root ProviderScope.',
          );
        }
      }

      return true;
    }());

    container = ProviderContainer(
      parent: parent,
      overrides: [
        _bindingProvider.overrideWithValue(context.binding),
        ..._syncOverrides,
        ...component.overrides,
      ],
      observers: component.observers,
      retry: component.retry,
      // TODO: handle errors
      // onError: (err, stack) {},
    );
  }

  ProviderContainer? _getParent() {
    final scope =
        context.getElementForInheritedComponentOfExactType<UncontrolledProviderScope>()?.component
            as UncontrolledProviderScope?;

    return scope?.container;
  }

  @override
  void didUpdateComponent(ProviderScope oldComponent) {
    super.didUpdateComponent(oldComponent);
    _dirty = true;
  }

  void _debugAssertParentDidNotChange() {
    final parent = _getParent();

    if (parent != _debugParentOwner) {
      throw UnsupportedError(
        'ProviderScope was rebuilt with a different ProviderScope ancestor',
      );
    }
  }

  @override
  Component build(BuildContext context) {
    if (kDebugMode) _debugAssertParentDidNotChange();

    if (_dirty) {
      _dirty = false;
      container.updateOverrides([_bindingProvider.overrideWithValue(context.binding), ...component.overrides]);
    }

    return UncontrolledProviderScope(container: container, child: component.child);
  }

  @override
  void dispose() {
    container.dispose();
    super.dispose();
  }
}

/// {@template riverpod.UncontrolledProviderScope}
/// Expose a [ProviderContainer] to the component tree.
///
/// **Note**: The [container] will _not_ be disposed when using this component.
/// It is the caller's responsibility to dispose of it when no longer needed.
/// Alternatively, use [ProviderScope] to automatically manage the lifecycle of
/// the [ProviderContainer].
///
/// {@endtemplate}
/// {@category Core}
class UncontrolledProviderScope extends InheritedComponent {
  /// {@macro riverpod.UncontrolledProviderScope}
  const UncontrolledProviderScope({super.key, required this.container, required super.child});

  /// The [ProviderContainer] exposed to the component tree.
  final ProviderContainer container;

  @override
  bool updateShouldNotify(UncontrolledProviderScope oldComponent) {
    return container != oldComponent.container;
  }

  @override
  InheritedElement createElement() {
    return _UncontrolledProviderScopeElement(this);
  }
}

@sealed
class _UncontrolledProviderScopeElement extends InheritedElement {
  _UncontrolledProviderScopeElement(UncontrolledProviderScope super.component);

  Task? _task;
  // ignore: unused_field
  bool _mounted = true;

  @override
  UncontrolledProviderScope get component => super.component as UncontrolledProviderScope;

  T _watch<T>(Object dependent, ProviderListenable<T> target) {
    return getDependencies(dependent)!.watch(target);
  }

  void _listen<T>(
    Object dependent,
    ProviderListenable<T> target,
    void Function(T? previous, T value) listener, {
    void Function(Object error, StackTrace stackTrace)? onError,
    bool fireImmediately = false,
  }) {
    getDependencies(dependent)!.listen(target, listener, onError: onError, fireImmediately: fireImmediately);
  }

  ProviderSubscription<T> _listenManual<T>(
    ProviderListenable<T> provider,
    void Function(T? previous, T value) listener, {
    void Function(Object error, StackTrace stackTrace)? onError,
    bool fireImmediately = false,
  }) {
    return component.container.listen(provider, listener, onError: onError, fireImmediately: fireImmediately);
  }

  @override
  void mount(Element? parent, ElementSlot newSlot) {
    if (kDebugMode) {
      debugCanModifyProviders ??= _debugCanModifyProviders;
    }

    component.container.scheduler.flutterVsyncs.add(_jasprVsync);
    super.mount(parent, newSlot);
  }

  @override
  void updateDependencies(Element dependent, Object? aspect) {
    setDependencies(dependent, getDependencies(dependent) ?? ProviderDependencies(dependent, this));
  }

  void _jasprVsync(Task task) {
    assert(_task == null, 'Only one task can be scheduled at a time');
    _task = task;

    Future.microtask(() async {
      while (owner.isFirstBuild) {
        await Future(() {});
      }
      if (_mounted) markNeedsBuild();
    });
  }

  void _debugCanModifyProviders() {
    // TODO: Scheduling a build here lead to some weird bugs.
    // For now we just ignore this as it is only a debug check anyways.
  }

  @override
  ProviderDependencies? getDependencies(Object dependent) {
    return super.getDependencies(dependent as Element) as ProviderDependencies?;
  }

  @override
  void setDependencies(Element dependent, covariant ProviderDependencies value) {
    super.setDependencies(dependent, value);
  }

  @override
  void didRebuildDependent(Element dependent) {
    getDependencies(dependent)?.didRebuild();
    super.didRebuildDependent(dependent);
  }

  @override
  void deactivateDependent(Element dependent) {
    getDependencies(dependent)?.deactivate();
    super.deactivateDependent(dependent);
  }

  @override
  void unmount() {
    _mounted = false;

    if (kDebugMode && debugCanModifyProviders == _debugCanModifyProviders) {
      debugCanModifyProviders = null;
    }

    component.container.scheduler.flutterVsyncs.remove(_jasprVsync);
    super.unmount();
  }

  @override
  void performRebuild() {
    _task?.call();
    _task = null;
    return super.performRebuild();
  }
}

extension BindingRef on Ref {
  AppBinding get binding => watch(_bindingProvider);
}

final _bindingProvider = Provider<AppBinding>((_) => throw UnimplementedError('Overridden by ProviderScope.'));
