library framework;

import 'dart:async';
import 'dart:convert';

import 'package:jaspr/jaspr.dart';
import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';

part 'jaspr/sync_provider.dart';
part 'jaspr/sync_ref.dart';
part 'provider_context.dart';
part 'provider_dependencies.dart';

/// {@template riverpod.providerscope}
/// A component that stores the state of providers.
///
/// All Flutter applications using Riverpod must contain a [ProviderScope] at
/// the root of their component tree. It is done as followed:
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
/// It optionally possible to specify `overrides` to change the behavior of
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
/// the component tree to override the behavior of a provider for only a part of the
/// application:
///
/// ```dart
/// final themeProvider = Provider((ref) => MyTheme.light());
///
/// void main() {
///   runApp(
///     ProviderScope(
///       child: MaterialApp(
///         // Home uses the default behavior for all providers.
///         home: Home(),
///         routes: {
///           // Overrides themeProvider for the /gallery route only
///           '/gallery': (_) => ProviderScope(
///             overrides: [
///               themeProvider.overrideWithValue(MyTheme.dark()),
///             ],
///           ),
///         },
///       ),
///     ),
///   );
/// }
/// ```
///
/// See also:
/// - [ProviderContainer], a Dart-only class that allows manipulating providers
/// - [UncontrolledProviderScope], which exposes a [ProviderContainer] to the component
///   tree without managing its life-cycles.
/// {@endtemplate}
@sealed
class ProviderScope extends StatefulComponent {
  /// {@macro riverpod.providerscope}
  const ProviderScope({
    Key? key,
    this.overrides = const [],
    this.observers,
    this.cacheTime,
    this.disposeDelay,
    this.parent,
    required this.child,
  }) : super(key: key);

  /// Read the current [ProviderContainer] for a [BuildContext].
  static ProviderContainer containerOf(BuildContext context, {bool listen = true}) {
    return _scopeOf(context, listen: listen).component.container;
  }

  static _UncontrolledProviderScopeElement _scopeOf(BuildContext context, {bool listen = true}) {
    var element = context.getElementForInheritedComponentOfExactType<UncontrolledProviderScope>()
        as _UncontrolledProviderScopeElement?;

    if (element == null) {
      throw StateError('No ProviderScope found');
    }

    if (listen) {
      context.dependOnInheritedElement(element);
    }

    return element;
  }

  /// The minimum amount of time before an `autoDispose` provider can be
  /// disposed if not listened.
  ///
  /// If the provider rebuilds (such as when using `ref.watch` or `ref.refresh`),
  /// the timer will be refreshed.
  ///
  /// If null, use the nearest ancestor [ProviderScope]'s [cacheTime].
  /// If no ancestor is found, fallbacks to [Duration.zero].
  final Duration? cacheTime;

  /// The amount of time before a provider is disposed after its last listener
  /// is removed.
  ///
  /// If a new listener is added within that duration, the provider will not be
  /// disposed.
  ///
  /// If null, use the nearest ancestor [ProviderContainer]'s [disposeDelay].
  /// If no ancestor is found, fallbacks to [Duration.zero].
  final Duration? disposeDelay;

  /// Explicitly override the parent [ProviderContainer] that this [ProviderScope]
  /// would be a descendant of.
  ///
  /// A common use-case is to allow modals to access scoped providers, as they
  /// would otherwise be unable to since they would be in a different branch
  /// of the component tree.
  ///
  /// That can be achieved with:
  ///
  /// ```dart
  /// ElevatedButton(
  ///   onTap: () {
  ///     final container = ProviderScope.containerOf(context);
  ///     showDialog(
  ///       context: context,
  ///       builder: (context) {
  ///         return ProviderScope(parent: container, child: MyModal());
  ///       },
  ///     );
  ///   },
  ///   child: Text('show modal'),
  /// )
  /// ```
  ///
  ///
  /// The [parent] variable must never change.
  final ProviderContainer? parent;

  /// The part of the component tree that can use Riverpod and has overridden providers.
  final Component child;

  /// The listeners that subscribes to changes on providers stored on this [ProviderScope].
  final List<ProviderObserver>? observers;

  /// Informations on how to override a provider/family.
  final List<Override> overrides;

  @override
  ProviderScopeState createState() => ProviderScopeState();
}

/// Do not use: The [State] of [ProviderScope]
@visibleForTesting
@sealed
class ProviderScopeState extends State<ProviderScope> with SyncStateMixin<ProviderScope, Map<String, dynamic>> {
  /// The [ProviderContainer] exposed to [ProviderScope.child].
  @visibleForTesting
  // ignore: diagnostic_describe_all_properties
  late final ProviderContainer container;
  ProviderContainer? _debugParentOwner;
  var _dirty = false;

  @override
  String syncId = 'provider_scope';

  late bool _isRoot;
  @override
  bool wantsSync() => _isRoot;

  @override
  Map<String, dynamic> getState() {
    return container.read(_syncProvider.notifier)._saveState();
  }

  @override
  void updateState(Map? value) {
    container.read(_syncProvider.notifier)._updateState(value?.cast());
  }

  @override
  void initState() {
    final parent = _getParent();
    assert(() {
      _debugParentOwner = parent;
      return true;
    }(), '');

    _isRoot = parent == null;
    container = ProviderContainer(
      parent: parent,
      overrides: component.overrides,
      observers: component.observers,
      cacheTime: component.cacheTime,
      disposeDelay: component.disposeDelay,
    );

    super.initState();
  }

  ProviderContainer? _getParent() {
    if (component.parent != null) {
      return component.parent;
    } else {
      final scope = context.getElementForInheritedComponentOfExactType<UncontrolledProviderScope>()?.component
          as UncontrolledProviderScope?;

      return scope?.container;
    }
  }

  @override
  void didUpdateComponent(ProviderScope oldComponent) {
    super.didUpdateComponent(oldComponent);
    _dirty = true;

    if (oldComponent.parent != component.parent) {
      print("ERROR: Changing ProviderScope.parent is not supported");
    }
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    assert(() {
      if (component.parent != null) {
        // didUpdateComponent already takes care of component.parent change
        return true;
      }
      final parent = _getParent();

      if (parent != _debugParentOwner) {
        throw UnsupportedError(
          'ProviderScope was rebuilt with a different ProviderScope ancestor',
        );
      }
      return true;
    }(), '');
    if (_dirty) {
      _dirty = false;
      container.updateOverrides(component.overrides);
    }

    yield UncontrolledProviderScope(
      container: container,
      child: component.child,
    );
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
/// This is what makes `ref.watch(`/`Consumer`/`ref.read` work.
/// {@endtemplate}
@sealed
class UncontrolledProviderScope extends InheritedComponent {
  /// {@macro riverpod.UncontrolledProviderScope}
  const UncontrolledProviderScope({
    Key? key,
    required this.container,
    required Component child,
  }) : super(key: key, child: child);

  /// The [ProviderContainer] exposed to the component tree.
  final ProviderContainer container;

  @override
  bool updateShouldNotify(UncontrolledProviderScope oldComponent) {
    return container != oldComponent.container;
  }

  @override
  // ignore: library_private_types_in_public_api
  _UncontrolledProviderScopeElement createElement() {
    return _UncontrolledProviderScopeElement(this);
  }
}

@sealed
class _UncontrolledProviderScopeElement extends InheritedElement {
  _UncontrolledProviderScopeElement(UncontrolledProviderScope component) : super(component);

  void Function()? _task;
  // ignore: unused_field
  bool _mounted = true;

  @override
  UncontrolledProviderScope get component => super.component as UncontrolledProviderScope;

  T _read<T>(ProviderBase<T> provider) {
    return component.container.read(provider);
  }

  T _refresh<T>(ProviderBase<T> provider) {
    return component.container.refresh(provider);
  }

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

  ProviderSubscription<T> _subscribe<T>(
    ProviderListenable<T> provider,
    void Function(T? previous, T value) listener, {
    void Function(Object error, StackTrace stackTrace)? onError,
    bool fireImmediately = false,
  }) {
    return component.container.listen(provider, listener, onError: onError, fireImmediately: fireImmediately);
  }

  Future<void> _preload(ProviderBase provider) async {
    component.container.read(provider); // create if not exists
    return component.container.read(_syncProvider.notifier)._preload();
  }

  @override
  void mount(Element? parent, Element? prevSibling) {
    assert(() {
      component.container.debugCanModifyProviders = _debugCanModifyProviders;
      return true;
    }());
    assert(
      component.container.vsyncOverride == null,
      'The ProviderContainer was already associated with a different component',
    );
    component.container.vsyncOverride = _flutterVsync;

    super.mount(parent, prevSibling);
  }

  @override
  void updateDependencies(Element dependent, Object? aspect) {
    setDependencies(dependent, getDependencies(dependent) ?? ProviderDependencies(dependent, this));
  }

  @override
  void update(UncontrolledProviderScope newComponent) {
    assert(() {
      component.container.debugCanModifyProviders = null;
      newComponent.container.debugCanModifyProviders = _debugCanModifyProviders;
      return true;
    }());

    component.container.vsyncOverride = null;
    assert(
      newComponent.container.vsyncOverride == null,
      'The ProviderContainer was already associated with a different component',
    );
    newComponent.container.vsyncOverride = _flutterVsync;

    super.update(newComponent);
  }

  void _flutterVsync(void Function() task) {
    assert(_task == null, 'Only one task can be scheduled at a time');
    _task = task;

    // TODO: From my testing, we don't schedule a build here as opposed to flutter_riverpod.
    //  Find out why this was done originally and if this has any other implications.
    Future.microtask(() {
      _task?.call();
      _task = null;
    });
  }

  void _debugCanModifyProviders() {
    // TODO: Scheduling a build here lead to some weird bugs. For now we just ignore this as
    //  it is a debug check only anyways
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
    assert(() {
      component.container.debugCanModifyProviders = null;
      return true;
    }());

    component.container.vsyncOverride = null;
    super.unmount();
  }

  @override
  Component? build() {
    _task?.call();
    _task = null;
    return super.build();
  }
}
