part of 'framework.dart';

/// A [Key] is an identifier for [Component]s and [Element]s.
///
/// A new component will only be used to update an existing element if its key is
/// the same as the key of the current component associated with the element.
///
/// Keys must be unique amongst the [Element]s with the same parent.
///
/// Subclasses of [Key] should either subclass [LocalKey] or [GlobalKey].
///
/// See also:
///
///  * [Component.key], which discusses how components use keys.
@immutable
abstract class Key {
  /// Construct a [ValueKey<String>] with the given [String].
  ///
  /// This is the simplest way to create keys.
  const factory Key(String value) = ValueKey<String>;

  /// Default constructor, used by subclasses.
  ///
  /// Useful so that subclasses can call us, because the [Key] factory
  /// constructor shadows the implicit constructor.
  @protected
  const Key.empty();
}

/// A key that is not a [GlobalKey].
///
/// Keys must be unique amongst the [Element]s with the same parent. By
/// contrast, [GlobalKey]s must be unique across the entire app.
///
/// See also:
///
///  * [Component.key], which discusses how components use keys.
abstract class LocalKey extends Key {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const LocalKey() : super.empty();
}

/// A key that uses a value of a particular type to identify itself.
///
/// A [ValueKey<T>] is equal to another [ValueKey<T>] if, and only if, their
/// values are [operator==].
///
/// This class can be subclassed to create value keys that will not be equal to
/// other value keys that happen to use the same value. If the subclass is
/// private, this results in a value key type that cannot collide with keys from
/// other sources, which could be useful, for example, if the keys are being
/// used as fallbacks in the same scope as keys supplied from another component.
///
/// See also:
///
///  * [Component.key], which discusses how components use keys.
class ValueKey<T> extends LocalKey {
  /// Creates a key that delegates its [operator==] to the given value.
  const ValueKey(this.value);

  /// The value to which this key delegates its [operator==]
  final T value;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == runtimeType && other is ValueKey<T> && other.value == value;
  }

  @override
  int get hashCode => Object.hashAll([runtimeType, value]);

  @override
  String toString() {
    final String valueString = T == String ? "<'$value'>" : '<$value>';

    if (runtimeType == ValueKey<T>) {
      return '[$valueString]';
    }
    return '[$T $valueString]';
  }
}

/// A key that is only equal to itself.
///
/// This cannot be created with a const constructor because that implies that
/// all instantiated keys would be the same instance and therefore not be unique.
class UniqueKey extends LocalKey {
  /// Creates a key that is equal only to itself.
  ///
  /// The key cannot be created with a const constructor because that implies
  /// that all instantiated keys would be the same instance and therefore not
  /// be unique.
  // ignore: prefer_const_constructors_in_immutables
  UniqueKey();

  @override
  String toString() => '[#${shortHash(this)}]';
}

/// A key that is unique across the entire app.
///
/// Global keys uniquely identify elements. Global keys provide access to other
/// objects that are associated with those elements, such as [BuildContext].
/// For [StatefulComponent]s, global keys also provide access to [State].
///
/// Components that have global keys reparent their subtrees when they are moved
/// from one location in the tree to another location in the tree. In order to
/// reparent its subtree, a component must arrive at its new location in the tree
/// in the same animation frame in which it was removed from its old location in
/// the tree.
///
/// Reparenting an [Element] using a global key is relatively expensive, as
/// this operation will trigger a call to [State.deactivate] on the associated
/// [State] and all of its descendants; then force all components that depends
/// on an [InheritedComponent] to rebuild.
///
/// If you don't need any of the features listed above, consider using a [Key],
/// [ValueKey], or [UniqueKey] instead.
///
/// You cannot simultaneously include two components in the tree with the same
/// global key. Attempting to do so will assert at runtime.
///
/// ## Pitfalls
///
/// GlobalKeys should not be re-created on every build. They should usually be
/// long-lived objects owned by a [State] object, for example.
///
/// Creating a new GlobalKey on every build will throw away the state of the
/// subtree associated with the old key and create a new fresh subtree for the
/// new key. Besides harming performance, this can also cause unexpected
/// behavior in components in the subtree.
///
/// Instead, a good practice is to let a State object own the GlobalKey, and
/// instantiate it outside the build method, such as in [State.initState].
///
/// See also:
///
///  * The discussion at [Component.key] for more information about how components use
///    keys.
@optionalTypeArgs
abstract class GlobalKey extends Key {
  /// Creates a [LabeledGlobalKey], which is a [GlobalKey] with a label used for
  /// debugging.
  ///
  /// The label is purely for debugging and not used for comparing the identity
  /// of the key.
  factory GlobalKey({String? debugLabel}) => LabeledGlobalKey(debugLabel);

  /// Creates a global key without a label.
  ///
  /// Used by subclasses because the factory constructor shadows the implicit
  /// constructor.
  const GlobalKey.constructor() : super.empty();

  Element? get _currentElement => ComponentsBinding._globalKeyRegistry[this];

  /// The build context in which the component with this key builds.
  ///
  /// The current context is null if there is no component in the tree that matches
  /// this global key.
  BuildContext? get currentContext => _currentElement;

  /// The component in the tree that currently has this global key.
  ///
  /// The current component is null if there is no component in the tree that matches
  /// this global key.
  Component? get currentComponent => _currentElement?.component;
}

/// A global key with a debugging label.
///
/// The debug label is useful for documentation and for debugging. The label
/// does not affect the key's identity.
@optionalTypeArgs
class LabeledGlobalKey extends GlobalKey {
  /// Creates a global key with a debugging label.
  ///
  /// The label does not affect the key's identity.
  // ignore: prefer_const_constructors_in_immutables , never use const for this class
  LabeledGlobalKey(this._debugLabel) : super.constructor();

  final String? _debugLabel;

  @override
  String toString() {
    final String label = _debugLabel != null ? ' $_debugLabel' : '';
    if (runtimeType == LabeledGlobalKey) {
      return '[GlobalKey#${shortHash(this)}$label]';
    }
    return '[${describeIdentity(this)}$label]';
  }
}

/// A global key that takes its identity from the object used as its value.
///
/// Used to tie the identity of a component to the identity of an object used to
/// generate that component.
///
/// If the object is not private, then it is possible that collisions will occur
/// where independent components will reuse the same object as their
/// [GlobalObjectKey] value in a different part of the tree, leading to a global
/// key conflict. To avoid this problem, create a private [GlobalObjectKey]
/// subclass, as in:
///
/// ```dart
/// class _MyKey extends GlobalObjectKey {
///   const _MyKey(Object value) : super(value);
/// }
/// ```
///
/// Since the [runtimeType] of the key is part of its identity, this will
/// prevent clashes with other [GlobalObjectKey]s even if they have the same
/// value.
///
/// Any [GlobalObjectKey] created for the same value will match.
@optionalTypeArgs
class GlobalObjectKey extends GlobalKey {
  /// Creates a global key that uses [identical] on [value] for its [operator==].
  const GlobalObjectKey(this.value) : super.constructor();

  /// The object whose identity is used by this key's [operator==].
  final Object value;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == runtimeType && other is GlobalObjectKey && identical(other.value, value);
  }

  @override
  int get hashCode => identityHashCode(value);

  @override
  String toString() {
    final String selfType = objectRuntimeType(this, 'GlobalObjectKey');
    return '[$selfType ${describeIdentity(value)}]';
  }
}

/// A global key that provides access to the [State] that is associated with its element.
///
/// See also:
///
///  * [GlobalKey], which is a key that is unique across the entire app.
///  * [GlobalNodeKey], which is a key that provides access to the dom [web.Node] that is associated with its element.
///  * The discussion at [Component.key] for more information about how components use
///    keys.
class GlobalStateKey<T extends State<StatefulComponent>> extends GlobalKey {
  factory GlobalStateKey({String? debugLabel}) => LabeledGlobalStateKey(debugLabel);

  /// Creates a global state key without a label.
  ///
  /// Used by subclasses because the factory constructor shadows the implicit
  /// constructor.
  const GlobalStateKey.constructor() : super.constructor();

  /// The [State] for the component in the tree that currently has this global key.
  ///
  /// The current state is null if (1) there is no component in the tree that
  /// matches this global key, (2) that component is not a [StatefulComponent], or the
  /// associated [State] object is not a subtype of `T`.
  T? get currentState => switch (_currentElement) {
    StatefulElement(:final T state) => state,
    _ => null,
  };
}

/// A global state key with a debugging label.
///
/// The debug label is useful for documentation and for debugging. The label
/// does not affect the key's identity.
@optionalTypeArgs
class LabeledGlobalStateKey<T extends State<StatefulComponent>> extends GlobalStateKey<T> {
  /// Creates a global key with a debugging label.
  ///
  /// The label does not affect the key's identity.
  // ignore: prefer_const_constructors_in_immutables , never use const for this class
  LabeledGlobalStateKey(this._debugLabel) : super.constructor();

  final String? _debugLabel;

  @override
  String toString() {
    final String label = _debugLabel != null ? ' $_debugLabel' : '';
    if (runtimeType == LabeledGlobalStateKey) {
      return '[GlobalKey#${shortHash(this)}$label]';
    }
    return '[${describeIdentity(this)}$label]';
  }
}

/// A global state key that takes its identity from the object used as its value.
///
/// Used to tie the identity of a component to the identity of an object used to
/// generate that component.
///
/// If the object is not private, then it is possible that collisions will occur
/// where independent components will reuse the same object as their
/// [GlobalObjectStateKey] value in a different part of the tree, leading to a global
/// key conflict. To avoid this problem, create a private [GlobalObjectStateKey]
/// subclass, as in:
///
/// ```dart
/// class _MyKey extends GlobalObjectStateKey {
///   const _MyKey(Object value) : super(value);
/// }
/// ```
///
/// Since the [runtimeType] of the key is part of its identity, this will
/// prevent clashes with other [GlobalObjectStateKey]s even if they have the same
/// value.
///
/// Any [GlobalObjectStateKey] created for the same value will match.
@optionalTypeArgs
class GlobalObjectStateKey<T extends State<StatefulComponent>> extends GlobalStateKey<T> {
  /// Creates a global key that uses [identical] on [value] for its [operator==].
  const GlobalObjectStateKey(this.value) : super.constructor();

  /// The object whose identity is used by this key's [operator==].
  final Object value;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == runtimeType && other is GlobalObjectKey && identical(other.value, value);
  }

  @override
  int get hashCode => identityHashCode(value);

  @override
  String toString() {
    String selfType = objectRuntimeType(this, 'GlobalObjectStateKey');
    // The runtimeType string of a GlobalObjectStateKey() returns 'GlobalObjectStateKey<State<StatefulComponent>>'
    // because GlobalObjectStateKey is instantiated to its bounds. To avoid cluttering the output
    // we remove the suffix.
    const String suffix = '<State<StatefulComponent>>';
    if (selfType.endsWith(suffix)) {
      selfType = selfType.substring(0, selfType.length - suffix.length);
    }
    return '[$selfType ${describeIdentity(value)}]';
  }
}

/// A global key that provides access to the dom [web.Node] that is associated with its element.
///
/// See also:
///
///  * [GlobalKey], which is a key that is unique across the entire app.
///  * [GlobalStateKey], which is a key that provides access to the [State] that is associated with its element.
///  * The discussion at [Component.key] for more information about how components use
///    keys.
class GlobalNodeKey<T extends web.Node> extends GlobalKey {
  factory GlobalNodeKey({String? debugLabel}) => LabeledGlobalNodeKey(debugLabel);

  /// Creates a global node key without a label.
  ///
  /// Used by subclasses because the factory constructor shadows the implicit
  /// constructor.
  const GlobalNodeKey.constructor() : super.constructor();

  /// The [web.Node] for the component in the tree that currently has this global key.
  ///
  /// The current node is null if (1) the current environment is not web, or (2) there is no component
  /// in the tree that matches this global key.
  T? get currentNode => switch (_currentElement) {
    RenderObjectElement(renderObject: RenderObject(:final T node)) => node,
    Element(slot: ElementSlot(target: RenderObjectElement(renderObject: RenderObject(:final T node)))) => node,
    _ => null,
  };
}

/// A global node key with a debugging label.
///
/// The debug label is useful for documentation and for debugging. The label
/// does not affect the key's identity.
@optionalTypeArgs
class LabeledGlobalNodeKey<T extends web.Node> extends GlobalNodeKey<T> {
  /// Creates a global key with a debugging label.
  ///
  /// The label does not affect the key's identity.
  // ignore: prefer_const_constructors_in_immutables , never use const for this class
  LabeledGlobalNodeKey(this._debugLabel) : super.constructor();

  final String? _debugLabel;

  @override
  String toString() {
    final String label = _debugLabel != null ? ' $_debugLabel' : '';
    if (runtimeType == LabeledGlobalNodeKey) {
      return '[GlobalKey#${shortHash(this)}$label]';
    }
    return '[${describeIdentity(this)}$label]';
  }
}

/// A global node key that takes its identity from the object used as its value.
///
/// Used to tie the identity of a component to the identity of an object used to
/// generate that component.
///
/// If the object is not private, then it is possible that collisions will occur
/// where independent components will reuse the same object as their
/// [GlobalObjectNodeKey] value in a different part of the tree, leading to a global
/// key conflict. To avoid this problem, create a private [GlobalObjectNodeKey]
/// subclass, as in:
///
/// ```dart
/// class _MyKey extends GlobalObjectNodeKey {
///   const _MyKey(Object value) : super(value);
/// }
/// ```
///
/// Since the [runtimeType] of the key is part of its identity, this will
/// prevent clashes with other [GlobalObjectNodeKey]s even if they have the same
/// value.
///
/// Any [GlobalObjectNodeKey] created for the same value will match.
@optionalTypeArgs
class GlobalObjectNodeKey<T extends web.Node> extends GlobalNodeKey<T> {
  /// Creates a global key that uses [identical] on [value] for its [operator==].
  const GlobalObjectNodeKey(this.value) : super.constructor();

  /// The object whose identity is used by this key's [operator==].
  final Object value;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == runtimeType && other is GlobalObjectKey && identical(other.value, value);
  }

  @override
  int get hashCode => identityHashCode(value);

  @override
  String toString() {
    String selfType = objectRuntimeType(this, 'GlobalObjectNodeKey');
    // The runtimeType string of a GlobalObjectNodeKey() returns 'GlobalObjectNodeKey<Node>'
    // because GlobalObjectNodeKey is instantiated to its bounds. To avoid cluttering the output
    // we remove the suffix.
    const String suffix = '<Node>';
    if (selfType.endsWith(suffix)) {
      selfType = selfType.substring(0, selfType.length - suffix.length);
    }
    return '[$selfType ${describeIdentity(value)}]';
  }
}
