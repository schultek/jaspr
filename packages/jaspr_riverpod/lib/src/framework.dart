// ignore_for_file: invalid_use_of_internal_member

library framework;

import 'dart:async';

import 'package:jaspr/jaspr.dart';
import 'package:meta/meta.dart';

import 'internals.dart';
import 'sync_provider.dart';

part 'provider_context.dart';
part 'provider_dependencies.dart';

/// {@template riverpod.providerscope}
/// A component that stores the state of providers.
///
/// All Jaspr applications using Riverpod must contain a [ProviderScope] at
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
    super.key,
    this.overrides = const [],
    this.observers,
    this.parent,
    required this.child,
  });

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

  /// Information on how to override a provider/family.
  final List<Override> overrides;

  @override
  ProviderScopeState createState() => ProviderScopeState();
}

/// Do not use: The [State] of [ProviderScope]
@visibleForTesting
@sealed
class ProviderScopeState extends State<ProviderScope>
    with SyncStateMixin<ProviderScope, Map<String, dynamic>>, SyncScopeMixin {
  /// The [ProviderContainer] exposed to [ProviderScope.child].
  @override
  @visibleForTesting
  // ignore: diagnostic_describe_all_properties
  late final ProviderContainer container;

  ProviderContainer? _debugParentOwner;
  var _dirty = false;

  @override
  void initState() {
    final parent = _getParent();
    assert(() {
      _debugParentOwner = parent;
      return true;
    }(), '');

    container = ProviderContainer(
      parent: parent,
      overrides: [
        _bindingProvider.overrideWithValue(context.binding),
        ...component.overrides,
      ],
      observers: component.observers,
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
      container.updateOverrides([
        _bindingProvider.overrideWithValue(context.binding),
        ...component.overrides,
      ]);
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
    super.key,
    required this.container,
    required super.child,
  });

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
  _UncontrolledProviderScopeElement(UncontrolledProviderScope super.component);

  void Function()? _task;
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

  ProviderSubscription<T> _subscribe<T>(
    ProviderListenable<T> provider,
    void Function(T? previous, T value) listener, {
    void Function(Object error, StackTrace stackTrace)? onError,
    bool fireImmediately = false,
  }) {
    return component.container.listen(provider, listener, onError: onError, fireImmediately: fireImmediately);
  }

  @override
  void mount(Element? parent, Element? prevSibling) {
    if (kDebugMode) {
      debugCanModifyProviders ??= _debugCanModifyProviders;
    }

    component.container.scheduler.flutterVsyncs.add(_jasprVsync);
    super.mount(parent, prevSibling);
  }

  @override
  void updateDependencies(Element dependent, Object? aspect) {
    setDependencies(dependent, getDependencies(dependent) ?? ProviderDependencies(dependent, this));
  }

  void _jasprVsync(void Function() task) {
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
