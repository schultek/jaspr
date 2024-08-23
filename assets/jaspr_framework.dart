/// A [Key] is an identifier for [Widget]s, [Element]s and [SemanticsNode]s.
///
/// A new widget will only be used to update an existing element if its key is
/// the same as the key of the current widget associated with the element.
///
/// Keys must be unique amongst the [Element]s with the same parent.
///
/// Subclasses of [Key] should either subclass [LocalKey] or [GlobalKey].
///
/// See also:
///
///  * [Widget.key], which discusses how widgets use keys.
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
///  * [Widget.key], which discusses how widgets use keys.
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
/// used as fallbacks in the same scope as keys supplied from another widget.
///
/// See also:
///
///  * [Widget.key], which discusses how widgets use keys.
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
  String toString() => '[#$hashCode]';
}

/// A key that is unique across the entire app.
///
/// Global keys uniquely identify elements. Global keys provide access to other
/// objects that are associated with those elements, such as [BuildContext].
/// For [StatefulWidget]s, global keys also provide access to [State].
///
/// Widgets that have global keys reparent their subtrees when they are moved
/// from one location in the tree to another location in the tree. In order to
/// reparent its subtree, a widget must arrive at its new location in the tree
/// in the same animation frame in which it was removed from its old location in
/// the tree.
///
/// Reparenting an [Element] using a global key is relatively expensive, as
/// this operation will trigger a call to [State.deactivate] on the associated
/// [State] and all of its descendants; then force all widgets that depends
/// on an [InheritedWidget] to rebuild.
///
/// If you don't need any of the features listed above, consider using a [Key],
/// [ValueKey], or [UniqueKey] instead.
///
/// You cannot simultaneously include two widgets in the tree with the same
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
/// behavior in widgets in the subtree.
///
/// Instead, a good practice is to let a State object own the GlobalKey, and
/// instantiate it outside the build method, such as in [State.initState].
///
/// See also:
///
///  * The discussion at [Widget.key] for more information about how widgets use
///    keys.
@optionalTypeArgs
class GlobalKey<T extends State<StatefulWidget>> extends Key {
  /// Creates a global key.
  const GlobalKey() : super.empty();

  Element? get _currentElement => WidgetsBinding._globalKeyRegistry[this];

  /// The build context in which the widget with this key builds.
  ///
  /// The current context is null if there is no widget in the tree that matches
  /// this global key.
  BuildContext? get currentContext => _currentElement;

  /// The widget in the tree that currently has this global key.
  ///
  /// The current widget is null if there is no widget in the tree that matches
  /// this global key.
  Widget? get currentWidget => _currentElement?.widget;

  /// The [State] for the widget in the tree that currently has this global key.
  ///
  /// The current state is null if (1) there is no widget in the tree that
  /// matches this global key, (2) that widget is not a [StatefulWidget], or the
  /// associated [State] object is not a subtype of `T`.
  T? get currentState {
    final Element? element = _currentElement;
    if (element is StatefulElement) {
      final StatefulElement statefulElement = element;
      final State state = statefulElement.state;
      if (state is T) return state;
    }
    return null;
  }
}

/// A global key that takes its identity from the object used as its value.
///
/// Used to tie the identity of a widget to the identity of an object used to
/// generate that widget.
///
/// If the object is not private, then it is possible that collisions will occur
/// where independent widgets will reuse the same object as their
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
class GlobalObjectKey<T extends State<StatefulWidget>> extends GlobalKey<T> {
  /// Creates a global key that uses [identical] on [value] for its [operator==].
  const GlobalObjectKey(this.value) : super();

  /// The object whose identity is used by this key's [operator==].
  final Object value;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == runtimeType && other is GlobalObjectKey<T> && identical(other.value, value);
  }

  @override
  int get hashCode => identityHashCode(value);
}

/// Describes the configuration for an [Element].
///
/// Widgets are the central class hierarchy in the jaspr framework and have the
/// same structure and purpose as widgets do in Flutter. A widget
/// is an immutable description of part of a user interface. Widgets can be
/// inflated into elements, which manage the underlying DOM.
///
/// Widgets themselves have no mutable state (all their fields must be final).
/// If you wish to associate mutable state with a widget, consider using a
/// [StatefulWidget], which creates a [State] object (via
/// [StatefulWidget.createState]) whenever it is inflated into an element and
/// incorporated into the tree.
///
/// A given widget can be included in the tree zero or more times. In particular
/// a given widget can be placed in the tree multiple times. Each time a widget
/// is placed in the tree, it is inflated into an [Element], which means a
/// widget that is incorporated into the tree multiple times will be inflated
/// multiple times.
///
/// The [key] property controls how one widget replaces another widget in the
/// tree. If the [runtimeType] and [key] properties of the two widgets are
/// [operator==], respectively, then the new widget replaces the old widget by
/// updating the underlying element (i.e., by calling [Element.update] with the
/// new widget). Otherwise, the old element is removed from the tree, the new
/// widget is inflated into an element, and the new element is inserted into the
/// tree.
///
/// See also:
///
///  * [StatefulWidget] and [State], for widgets that can build differently
///    several times over their lifetime.
///  * [InheritedWidget], for widgets that introduce ambient state that can
///    be read by descendant widgets.
///  * [StatelessWidget], for widgets that always build the same way given a
///    particular configuration and ambient state.
@immutable
abstract class Widget {
  /// Initializes [key] for subclasses.
  const Widget({this.key});

  /// Controls how one widget replaces another widget in the tree.
  ///
  /// If the [runtimeType] and [key] properties of the two widgets are
  /// [operator==], respectively, then the new widget replaces the old widget by
  /// updating the underlying element (i.e., by calling [Element.update] with the
  /// new widget). Otherwise, the old element is removed from the tree, the new
  /// widget is inflated into an element, and the new element is inserted into the
  /// tree.
  ///
  /// In addition, using a [GlobalKey] as the widget's [key] allows the element
  /// to be moved around the tree (changing parent) without losing state. When a
  /// new widget is found (its key and type do not match a previous widget in
  /// the same location), but there was a widget with that same global key
  /// elsewhere in the tree in the previous frame, then that widget's element is
  /// moved to the new location.
  ///
  /// Generally, a widget that is the only child of another widget does not need
  /// an explicit key.
  ///
  /// See also:
  ///
  ///  * The discussions at [Key] and [GlobalKey].
  final Key? key;

  /// Inflates this configuration to a concrete instance.
  ///
  /// A given widget can be included in the tree zero or more times. In particular
  /// a given widget can be placed in the tree multiple times. Each time a widget
  /// is placed in the tree, it is inflated into an [Element], which means a
  /// widget that is incorporated into the tree multiple times will be inflated
  /// multiple times.
  Element createElement();

  /// Whether the `newWidget` can be used to update an [Element] that currently
  /// has the `oldWidget` as its configuration.
  ///
  /// An element that uses a given widget as its configuration can be updated to
  /// use another widget as its configuration if, and only if, the two widgets
  /// have [runtimeType] and [key] properties that are [operator==].
  ///
  /// If the widgets have no key (their key is null), then they are considered a
  /// match if they have the same type, even if their children are completely
  /// different.
  static bool canUpdate(Widget oldWidget, Widget newWidget) {
    return oldWidget.runtimeType == newWidget.runtimeType && oldWidget.key == newWidget.key;
  }
}

/// A widget that does not require mutable state.
///
/// A stateless widget is a widget that describes part of the user interface by
/// building a constellation of other widgets that describe the user interface
/// more concretely. The building process continues recursively until the
/// description of the user interface is fully concrete (e.g., consists
/// entirely of [DOMWidget]s, which describe concrete DOM elements).
///
/// Stateless widget are useful when the part of the user interface you are
/// describing does not depend on anything other than the configuration
/// information in the object itself and the [BuildContext] in which the widget
/// is inflated. For compositions that can change dynamically, e.g. due to
/// having an internal clock-driven state, or depending on some system state,
/// consider using [StatefulWidget].
///
/// ## Performance considerations
///
/// The [build] method of a stateless widget is typically only called in three
/// situations: the first time the widget is inserted in the tree, when the
/// widget's parent changes its configuration, and when an [InheritedWidget] it
/// depends on changes.
///
/// If a widget's parent will regularly change the widget's configuration, or if
/// it depends on inherited widgets that frequently change, then it is important
/// to optimize the performance of the [build] method to maintain a fluid
/// rendering performance.
///
/// There are several techniques one can use to minimize the impact of
/// rebuilding a stateless widget:
///
///  * Minimize the number of nodes transitively created by the build method and
///    any widgets it creates.
///
///  * Use `const` widgets where possible, and provide a `const` constructor for
///    the widget so that users of the widget can also do so.
///
///  * When trying to create a reusable piece of UI, prefer using a widget
///    rather than a helper method. For example, if there was a function used to
///    build a widget, a [State.setState] call would require Flutter to entirely
///    rebuild the returned wrapping widget. If a [Widget] was used instead,
///    we would be able to efficiently re-render only those parts that
///    really need to be updated. Even better, if the created widget is `const`,
///    we would short-circuit most of the rebuild work.
///
///  * Consider refactoring the stateless widget into a stateful widget so that
///    it can use some of the techniques described at [StatefulWidget], such as
///    caching common parts of subtrees and using [GlobalKey]s when changing the
///    tree structure.
///
///  * If the widget is likely to get rebuilt frequently due to the use of
///    [InheritedWidget]s, consider refactoring the stateless widget into
///    multiple widgets, with the parts of the tree that change being pushed to
///    the leaves. For example instead of building a tree with four widgets, the
///    inner-most widget depending on some [InheritedWidget], consider factoring out the
///    part of the build function that builds the inner-most widget into its own
///    widget, so that only the inner-most widget needs to be rebuilt when the
///    inherited widget changes.
///
/// By convention, widget constructors only use named arguments. Also by
/// convention, the first argument is [key], and the last argument is `child`,
/// `children`, or the equivalent.
///
/// See also:
///
///  * [StatefulWidget] and [State], for widgets that can build differently
///    several times over their lifetime.
///  * [InheritedWidget], for widgets that introduce ambient state that can
///    be read by descendant widgets.
abstract class StatelessWidget extends Widget {
  /// Initializes [key] for subclasses.
  const StatelessWidget({super.key});

  /// Creates a [StatelessElement] to manage this widget's location in the tree.
  ///
  /// It is uncommon for subclasses to override this method.
  @override
  Element createElement() => StatelessElement(this);

  /// Describes the part of the user interface represented by this widget.
  ///
  /// The framework calls this method when this widget is inserted into the tree
  /// in a given [BuildContext] and when the dependencies of this widget change
  /// (e.g., an [InheritedWidget] referenced by this widget changes). This
  /// method can potentially be called in every frame and should not have any side
  /// effects beyond building a widget.
  ///
  /// The framework replaces the subtree below this widget with the widget
  /// returned by this method, either by updating the existing subtree or by
  /// removing the subtree and inflating a new subtree, depending on whether the
  /// widget returned by this method can update the root of the existing
  /// subtree, as determined by calling [Widget.canUpdate].
  ///
  /// Typically implementations return a newly created constellation of widgets
  /// that are configured with information from this widget's constructor and
  /// from the given [BuildContext].
  ///
  /// The given [BuildContext] contains information about the location in the
  /// tree at which this widget is being built. For example, the context
  /// provides the set of inherited widgets for this location in the tree. A
  /// given widget might be built with multiple different [BuildContext]
  /// arguments over time if the widget is moved around the tree or if the
  /// widget is inserted into the tree in multiple places at once.
  ///
  /// The implementation of this method must only depend on:
  ///
  /// * the fields of the widget, which themselves must not change over time,
  ///   and
  /// * any ambient state obtained from the `context` using
  ///   [BuildContext.dependOnInheritedWidgetOfExactType].
  ///
  /// If a widget's [build] method is to depend on anything else, use a
  /// [StatefulWidget] instead.
  ///
  /// See also:
  ///
  ///  * [StatelessWidget], which contains the discussion on performance considerations.
  @protected
  Iterable<Widget> build(BuildContext context);

  /// Implement this method to determine whether a rebuild can be skipped.
  ///
  /// This method will be called whenever the widget is about to update. If returned false, the subsequent rebuild will be skipped.
  ///
  /// This method exists only as a performance optimization and gives no guarantees about when the widget is rebuilt.
  /// Keep the implementation as efficient as possible and avoid deep (recursive) comparisons or performance heavy checks, as this might
  /// have an opposite effect on performance.
  bool shouldRebuild(covariant Widget newWidget) {
    return true;
  }
}

/// A widget that has mutable state.
///
/// State is information that (1) can be read synchronously when the widget is
/// built and (2) might change during the lifetime of the widget. It is the
/// responsibility of the widget implementer to ensure that the [State] is
/// promptly notified when such state changes, using [State.setState].
///
/// A stateful widget is a widget that describes part of the user interface by
/// building a constellation of other widgets that describe the user interface
/// more concretely. The building process continues recursively until the
/// description of the user interface is fully concrete (e.g., consists
/// entirely of [DOMWidget]s, which describe concrete DOM elements).
///
/// Stateful widgets are useful when the part of the user interface you are
/// describing can change dynamically, e.g. due to having an internal
/// clock-driven state, or depending on some system state. For compositions that
/// depend only on the configuration information in the object itself and the
/// [BuildContext] in which the widget is inflated, consider using
/// [StatelessWidget].
///
/// [StatefulWidget] instances themselves are immutable and store their mutable
/// state either in separate [State] objects that are created by the
/// [createState] method, or in objects to which that [State] subscribes, for
/// example [Stream] or [ChangeNotifier] objects, to which references are stored
/// in final fields on the [StatefulWidget] itself.
///
/// The framework calls [createState] whenever it inflates a
/// [StatefulWidget], which means that multiple [State] objects might be
/// associated with the same [StatefulWidget] if that widget has been inserted
/// into the tree in multiple places. Similarly, if a [StatefulWidget] is
/// removed from the tree and later inserted in to the tree again, the framework
/// will call [createState] again to create a fresh [State] object, simplifying
/// the lifecycle of [State] objects.
///
/// A [StatefulWidget] keeps the same [State] object when moving from one
/// location in the tree to another if its creator used a [GlobalKey] for its
/// [key]. Because a widget with a [GlobalKey] can be used in at most one
/// location in the tree, a widget that uses a [GlobalKey] has at most one
/// associated element. The framework takes advantage of this property when
/// moving a widget with a global key from one location in the tree to another
/// by grafting the (unique) subtree associated with that widget from the old
/// location to the new location (instead of recreating the subtree at the new
/// location). The [State] objects associated with [StatefulWidget] are grafted
/// along with the rest of the subtree, which means the [State] object is reused
/// (instead of being recreated) in the new location. However, in order to be
/// eligible for grafting, the widget must be inserted into the new location in
/// the same build phase in which it was removed from the old location.
///
/// ## Performance considerations
///
/// There are two primary categories of [StatefulWidget]s.
///
/// The first is one which allocates resources in [State.initState] and disposes
/// of them in [State.dispose], but which does not depend on [InheritedWidget]s
/// or call [State.setState]. Such widgets are commonly used at the root of an
/// application or page, and communicate with subwidgets via [ChangeNotifier]s,
/// [Stream]s, or other such objects. Stateful widgets following such a pattern
/// are relatively cheap (in terms of CPU and GPU cycles), because they are
/// built once then never update. They can, therefore, have somewhat complicated
/// and deep build methods.
///
/// The second category is widgets that use [State.setState] or depend on
/// [InheritedWidget]s. These will typically rebuild many times during the
/// application's lifetime, and it is therefore important to minimize the impact
/// of rebuilding such a widget. (They may also use [State.initState] or
/// [State.didChangeDependencies] and allocate resources, but the important part
/// is that they rebuild.)
///
/// There are several techniques one can use to minimize the impact of
/// rebuilding a stateful widget:
///
///  * Push the state to the leaves. For example, if your page has a ticking
///    clock, rather than putting the state at the top of the page and
///    rebuilding the entire page each time the clock ticks, create a dedicated
///    clock widget that only updates itself.
///
///  * Minimize the number of nodes transitively created by the build method and
///    any widgets it creates. Ideally, a stateful widget would only create a
///    single widget, and that widget would be a [RenderObjectWidget].
///    (Obviously this isn't always practical, but the closer a widget gets to
///    this ideal, the more efficient it will be.)
///
///  * If a subtree does not change, cache the widget that represents that
///    subtree and re-use it each time it can be used. It is massively more
///    efficient for a widget to be re-used than for a new (but
///    identically-configured) widget to be created. Factoring out the stateful
///    part into a widget that takes a child argument is a common way of doing
///    this. Another caching strategy consists of assigning a widget to a
///    `final` state variable which can be used in the build method.
///
///  * Use `const` widgets where possible. (This is equivalent to caching a
///    widget and re-using it.)
///
///  * When trying to create a reusable piece of UI, prefer using a widget
///    rather than a helper method. For example, if there was a function used to
///    build a widget, a [State.setState] call would require Flutter to entirely
///    rebuild the returned wrapping widget. If a [Widget] was used instead,
///    Flutter would be able to efficiently re-render only those parts that
///    really need to be updated. Even better, if the created widget is `const`,
///    Flutter would short-circuit most of the rebuild work.
///
///  * Avoid changing the depth of any created subtrees or changing the type of
///    any widgets in the subtree. For example, rather than returning either the
///    child or the child wrapped in an [IgnorePointer], always wrap the child
///    widget in an [IgnorePointer] and control the [IgnorePointer.ignoring]
///    property. This is because changing the depth of the subtree requires
///    rebuilding, laying out, and painting the entire subtree, whereas just
///    changing the property will require the least possible change to the
///    render tree (in the case of [IgnorePointer], for example, no layout or
///    repaint is necessary at all).
///
///  * If the depth must be changed for some reason, consider wrapping the
///    common parts of the subtrees in widgets that have a [GlobalKey] that
///    remains consistent for the life of the stateful widget. (The
///    [KeyedSubtree] widget may be useful for this purpose if no other widget
///    can conveniently be assigned the key.)
///
/// By convention, widget constructors only use named arguments. Also by
/// convention, the first argument is [key], and the last argument is `child`,
/// `children`, or the equivalent.
///
/// See also:
///
///  * [State], where the logic behind a [StatefulWidget] is hosted.
///  * [StatelessWidget], for widgets that always build the same way given a
///    particular configuration and ambient state.
///  * [InheritedWidget], for widgets that introduce ambient state that can
///    be read by descendant widgets.
abstract class StatefulWidget extends Widget {
  /// Initializes [key] for subclasses.
  const StatefulWidget({super.key});

  /// Creates a [StatefulElement] to manage this widget's location in the tree.
  ///
  /// It is uncommon for subclasses to override this method.
  @override
  Element createElement() => StatefulElement(this);

  /// Creates the mutable state for this widget at a given location in the tree.
  ///
  /// Subclasses should override this method to return a newly created
  /// instance of their associated [State] subclass:
  ///
  /// ```dart
  /// @override
  /// State<MyWidget> createState() => _MyWidgetState();
  /// ```
  ///
  /// The framework can call this method multiple times over the lifetime of
  /// a [StatefulWidget]. For example, if the widget is inserted into the tree
  /// in multiple locations, the framework will create a separate [State] object
  /// for each location. Similarly, if the widget is removed from the tree and
  /// later inserted into the tree again, the framework will call [createState]
  /// again to create a fresh [State] object, simplifying the lifecycle of
  /// [State] objects.
  State createState();
}

/// Tracks the lifecycle of [State] objects when asserts are enabled.
enum _StateLifecycle {
  /// The [State] object has been created. [State.initState] is called at this
  /// time.
  created,

  /// The [State.initState] method has been called but the [State] object is
  /// not yet ready to build. [State.didChangeDependencies] is called at this time.
  initialized,

  /// The [State] object is ready to build and [State.dispose] has not yet been
  /// called.
  ready,

  /// The [State.dispose] method has been called and the [State] object is
  /// no longer able to build.
  defunct,
}

/// The signature of [State.setState] functions.
typedef StateSetter = void Function(VoidCallback fn);

/// The logic and internal state for a [StatefulWidget].
///
/// State is information that (1) can be read synchronously when the widget is
/// built and (2) might change during the lifetime of the widget. It is the
/// responsibility of the widget implementer to ensure that the [State] is
/// promptly notified when such state changes, using [State.setState].
///
/// [State] objects are created by the framework by calling the
/// [StatefulWidget.createState] method when inflating a [StatefulWidget] to
/// insert it into the tree. Because a given [StatefulWidget] instance can be
/// inflated multiple times (e.g., the widget is incorporated into the tree in
/// multiple places at once), there might be more than one [State] object
/// associated with a given [StatefulWidget] instance. Similarly, if a
/// [StatefulWidget] is removed from the tree and later inserted in to the tree
/// again, the framework will call [StatefulWidget.createState] again to create
/// a fresh [State] object, simplifying the lifecycle of [State] objects.
///
/// [State] objects have the following lifecycle:
///
///  * The framework creates a [State] object by calling
///    [StatefulWidget.createState].
///  * The newly created [State] object is associated with a [BuildContext].
///    This association is permanent: the [State] object will never change its
///    [BuildContext]. However, the [BuildContext] itself can be moved around
///    the tree along with its subtree. At this point, the [State] object is
///    considered [mounted].
///  * The framework calls [initState]. Subclasses of [State] should override
///    [initState] to perform one-time initialization that depends on the
///    [BuildContext] or the widget, which are available as the [context] and
///    [widget] properties, respectively, when the [initState] method is
///    called.
///  * The framework calls [didChangeDependencies]. Subclasses of [State] should
///    override [didChangeDependencies] to perform initialization involving
///    [InheritedWidget]s. If [BuildContext.dependOnInheritedWidgetOfExactType] is
///    called, the [didChangeDependencies] method will be called again if the
///    inherited widgets subsequently change or if the widget moves in the tree.
///  * At this point, the [State] object is fully initialized and the framework
///    might call its [build] method any number of times to obtain a
///    description of the user interface for this subtree. [State] objects can
///    spontaneously request to rebuild their subtree by callings their
///    [setState] method, which indicates that some of their internal state
///    has changed in a way that might impact the user interface in this
///    subtree.
///  * During this time, a parent widget might rebuild and request that this
///    location in the tree update to display a new widget with the same
///    [runtimeType] and [Widget.key]. When this happens, the framework will
///    update the [widget] property to refer to the new widget and then call the
///    [didUpdateWidget] method with the previous widget as an argument. [State]
///    objects should override [didUpdateWidget] to respond to changes in their
///    associated widget (e.g., to start implicit animations). The framework
///    always calls [build] after calling [didUpdateWidget], which means any
///    calls to [setState] in [didUpdateWidget] are redundant.
///  * During development, if a hot reload occurs (whether initiated from the
///    command line `flutter` tool by pressing `r`, or from an IDE), the
///    [reassemble] method is called. This provides an opportunity to
///    reinitialize any data that was prepared in the [initState] method.
///  * If the subtree containing the [State] object is removed from the tree
///    (e.g., because the parent built a widget with a different [runtimeType]
///    or [Widget.key]), the framework calls the [deactivate] method. Subclasses
///    should override this method to clean up any links between this object
///    and other elements in the tree.
///  * At this point, the framework might reinsert this subtree into another
///    part of the tree. If that happens, the framework will ensure that it
///    calls [build] to give the [State] object a chance to adapt to its new
///    location in the tree. If the framework does reinsert this subtree, it
///    will do so before the end of the build phase in which the subtree was
///    removed from the tree. For this reason, [State] objects can defer
///    releasing most resources until the framework calls their [dispose]
///    method.
///  * If the framework does not reinsert this subtree by the end of the current
///    build phase, the framework will call [dispose], which indicates that
///    this [State] object will never build again. Subclasses should override
///    this method to release any resources retained by this object.
///  * After the framework calls [dispose], the [State] object is considered
///    unmounted and the [mounted] property is false. It is an error to call
///    [setState] at this point. This stage of the lifecycle is terminal: there
///    is no way to remount a [State] object that has been disposed.
///
/// See also:
///
///  * [StatefulWidget], where the current configuration of a [State] is hosted,
///    and whose documentation has sample code for [State].
///  * [StatelessWidget], for widgets that always build the same way given a
///    particular configuration and ambient state.
///  * [InheritedWidget], for widgets that introduce ambient state that can
///    be read by descendant widgets.
///  * [Widget], for an overview of widgets in general.
@optionalTypeArgs
abstract class State<T extends StatefulWidget> {
  /// The current configuration.
  ///
  /// A [State] object's configuration is the corresponding [StatefulWidget]
  /// instance. This property is initialized by the framework before calling
  /// [initState]. If the parent updates this location in the tree to a new
  /// widget with the same [runtimeType] and [Widget.key] as the current
  /// configuration, the framework will update this property to refer to the new
  /// widget and then call [didUpdateWidget], passing the old configuration as
  /// an argument.
  T get widget => _widget!;
  T? _widget;

  /// The current stage in the lifecycle for this state object.
  ///
  /// This field is used by the framework when asserts are enabled to verify
  /// that [State] objects move through their lifecycle in an orderly fashion.
  _StateLifecycle _debugLifecycleState = _StateLifecycle.created;

  /// Verifies that the [State] that was created is one that expects to be
  /// created for that particular [Widget].
  bool _debugTypesAreRight(Widget widget) => widget is T;

  /// The location in the tree where this widget builds.
  ///
  /// The framework associates [State] objects with a [BuildContext] after
  /// creating them with [StatefulWidget.createState] and before calling
  /// [initState]. The association is permanent: the [State] object will never
  /// change its [BuildContext]. However, the [BuildContext] itself can be moved
  /// around the tree.
  ///
  /// After calling [dispose], the framework severs the [State] object's
  /// connection with the [BuildContext].
  BuildContext get context => _element!;

  StatefulElement? _element;

  /// Whether this [State] object is currently in a tree.
  ///
  /// After creating a [State] object and before calling [initState], the
  /// framework "mounts" the [State] object by associating it with a
  /// [BuildContext]. The [State] object remains mounted until the framework
  /// calls [dispose], after which time the framework will never ask the [State]
  /// object to [build] again.
  ///
  /// It is an error to call [setState] unless [mounted] is true.
  bool get mounted => _element != null;

  /// Called when this object is inserted into the tree.
  ///
  /// The framework will call this method exactly once for each [State] object
  /// it creates.
  ///
  /// Override this method to perform initialization that depends on the
  /// location at which this object was inserted into the tree (i.e., [context])
  /// or on the widget used to configure this object (i.e., [widget]).
  ///
  /// If a [State]'s [build] method depends on an object that can itself
  /// change state, for example a [ChangeNotifier] or [Stream], or some
  /// other object to which one can subscribe to receive notifications, then
  /// be sure to subscribe and unsubscribe properly in [initState],
  /// [didUpdateWidget], and [dispose]:
  ///
  ///  * In [initState], subscribe to the object.
  ///  * In [didUpdateWidget] unsubscribe from the old object and subscribe
  ///    to the new one if the updated widget configuration requires
  ///    replacing the object.
  ///  * In [dispose], unsubscribe from the object.
  ///
  /// You cannot use [BuildContext.dependOnInheritedWidgetOfExactType] from this
  /// method. However, [didChangeDependencies] will be called immediately
  /// following this method, and [BuildContext.dependOnInheritedWidgetOfExactType] can
  /// be used there.
  ///
  /// Implementations of this method should start with a call to the inherited
  /// method, as in `super.initState()`.
  @protected
  @mustCallSuper
  void initState() {
    assert(_debugLifecycleState == _StateLifecycle.created);
  }

  /// Implement this method to determine whether a rebuild can be skipped.
  ///
  /// This method will be called whenever the widget is about to update. If returned false, the subsequent rebuild will be skipped.
  ///
  /// This method exists only as a performance optimization and gives no guarantees about when the widget is rebuilt.
  /// Keep the implementation as efficient as possible and avoid deep (recursive) comparisons or performance heavy checks, as this might
  /// have an opposite effect on performance.
  bool shouldRebuild(covariant T newWidget) {
    return true;
  }

  /// Called whenever the widget configuration changes.
  ///
  /// If the parent widget rebuilds and request that this location in the tree
  /// update to display a new widget with the same [runtimeType] and
  /// [Widget.key], the framework will update the [widget] property of this
  /// [State] object to refer to the new widget and then call this method
  /// with the previous widget as an argument.
  ///
  /// Override this method to respond when the [widget] changes (e.g., to start
  /// implicit animations).
  ///
  /// The framework always calls [build] after calling [didUpdateWidget], which
  /// means any calls to [setState] in [didUpdateWidget] are redundant.
  ///
  /// Implementations of this method should start with a call to the inherited
  /// method, as in `super.didUpdateWidget(oldWidget)`
  @mustCallSuper
  @protected
  void didUpdateWidget(covariant T oldWidget) {}

  /// Notify the framework that the internal state of this object has changed.
  ///
  /// Whenever you change the internal state of a [State] object, make the
  /// change in a function that you pass to [setState]:
  ///
  /// ```dart
  /// setState(() { _myState = newValue; });
  /// ```
  ///
  /// The provided callback is immediately called synchronously. It must not
  /// return a future (the callback cannot be `async`), since then it would be
  /// unclear when the state was actually being set.
  ///
  /// Calling [setState] notifies the framework that the internal state of this
  /// object has changed in a way that might impact the user interface in this
  /// subtree, which causes the framework to schedule a [build] for this [State]
  /// object.
  ///
  /// If you just change the state directly without calling [setState], the
  /// framework might not schedule a [build] and the user interface for this
  /// subtree might not be updated to reflect the new state.
  ///
  /// Generally it is recommended that the `setState` method only be used to
  /// wrap the actual changes to the state, not any computation that might be
  /// associated with the change. For example, here a value used by the [build]
  /// function is incremented, and then the change is written to disk, but only
  /// the increment is wrapped in the `setState`:
  ///
  /// ```dart
  /// Future<void> _incrementCounter() async {
  ///   setState(() {
  ///     _counter++;
  ///   });
  ///   Directory directory = await getApplicationDocumentsDirectory();
  ///   final String dirName = directory.path;
  ///   await File('$dir/counter.txt').writeAsString('$_counter');
  /// }
  /// ```
  ///
  /// It is an error to call this method after the framework calls [dispose].
  /// You can determine whether it is legal to call this method by checking
  /// whether the [mounted] property is true.
  @protected
  void setState(VoidCallback fn) {
    assert(_debugLifecycleState != _StateLifecycle.defunct);
    Object? result = fn() as dynamic;
    assert(
      result is! Future,
      'setState() callback argument returned a Future.\n\n'
      'Instead of performing asynchronous work inside a call to setState(), first '
      'execute the work (without updating the widget state), and then synchronously '
      'update the state inside a call to setState().',
    );
    _element!.markNeedsBuild();
  }

  /// Called when this object is removed from the tree.
  ///
  /// The framework calls this method whenever it removes this [State] object
  /// from the tree. In some cases, the framework will reinsert the [State]
  /// object into another part of the tree (e.g., if the subtree containing this
  /// [State] object is grafted from one location in the tree to another due to
  /// the use of a [GlobalKey]). If that happens, the framework will call
  /// [activate] to give the [State] object a chance to reacquire any resources
  /// that it released in [deactivate]. It will then also call [build] to give
  /// the [State] object a chance to adapt to its new location in the tree. If
  /// the framework does reinsert this subtree, it will do so before the end of
  /// the build phase in which the subtree was removed from the tree. For
  /// this reason, [State] objects can defer releasing most resources until the
  /// framework calls their [dispose] method.
  ///
  /// Subclasses should override this method to clean up any links between
  /// this object and other elements in the tree.
  ///
  /// Implementations of this method should end with a call to the inherited
  /// method, as in `super.deactivate()`.
  ///
  /// See also:
  ///
  ///  * [dispose], which is called after [deactivate] if the widget is removed
  ///    from the tree permanently.
  @protected
  @mustCallSuper
  void deactivate() {}

  /// Called when this object is reinserted into the tree after having been
  /// removed via [deactivate].
  ///
  /// In most cases, after a [State] object has been deactivated, it is _not_
  /// reinserted into the tree, and its [dispose] method will be called to
  /// signal that it is ready to be garbage collected.
  ///
  /// In some cases, however, after a [State] object has been deactivated, the
  /// framework will reinsert it into another part of the tree (e.g., if the
  /// subtree containing this [State] object is grafted from one location in
  /// the tree to another due to the use of a [GlobalKey]). If that happens,
  /// the framework will call [activate] to give the [State] object a chance to
  /// reacquire any resources that it released in [deactivate]. It will then
  /// also call [build] to give the object a chance to adapt to its new
  /// location in the tree. If the framework does reinsert this subtree, it
  /// will do so before the end of the build phase in which the subtree was
  /// removed from the tree. For this reason, [State] objects can defer
  /// releasing most resources until the framework calls their [dispose] method.
  ///
  /// The framework does not call this method the first time a [State] object
  /// is inserted into the tree. Instead, the framework calls [initState] in
  /// that situation.
  ///
  /// Implementations of this method should start with a call to the inherited
  /// method, as in `super.activate()`.
  ///
  /// See also:
  ///
  ///  * [Element.activate], the corresponding method when an element
  ///    transitions from the "inactive" to the "active" lifecycle state.
  @protected
  @mustCallSuper
  void activate() {}

  /// Called when this object is removed from the tree permanently.
  ///
  /// The framework calls this method when this [State] object will never
  /// build again. After the framework calls [dispose], the [State] object is
  /// considered unmounted and the [mounted] property is false. It is an error
  /// to call [setState] at this point. This stage of the lifecycle is terminal:
  /// there is no way to remount a [State] object that has been disposed.
  ///
  /// Subclasses should override this method to release any resources retained
  /// by this object (e.g., stop any active animations).
  ///
  /// Implementations of this method should end with a call to the inherited
  /// method, as in `super.dispose()`.
  ///
  /// See also:
  ///
  ///  * [deactivate], which is called prior to [dispose].
  @mustCallSuper
  @protected
  void dispose() {
    assert(_debugLifecycleState == _StateLifecycle.ready);
    assert(() {
      _debugLifecycleState = _StateLifecycle.defunct;
      return true;
    }());
  }

  /// Describes the part of the user interface represented by this widget.
  ///
  /// The framework calls this method in a number of different situations. For
  /// example:
  ///
  ///  * After calling [initState].
  ///  * After calling [didUpdateWidget].
  ///  * After receiving a call to [setState].
  ///  * After a dependency of this [State] object changes (e.g., an
  ///    [InheritedWidget] referenced by the previous [build] changes).
  ///  * After calling [deactivate] and then reinserting the [State] object into
  ///    the tree at another location.
  ///
  /// This method can potentially be called in every frame and should not have
  /// any side effects beyond building a widget.
  ///
  /// The framework replaces the subtree below this widget with the widget
  /// returned by this method, either by updating the existing subtree or by
  /// removing the subtree and inflating a new subtree, depending on whether the
  /// widget returned by this method can update the root of the existing
  /// subtree, as determined by calling [Widget.canUpdate].
  ///
  /// Typically implementations return a newly created constellation of widgets
  /// that are configured with information from this widget's constructor, the
  /// given [BuildContext], and the internal state of this [State] object.
  ///
  /// The given [BuildContext] contains information about the location in the
  /// tree at which this widget is being built. For example, the context
  /// provides the set of inherited widgets for this location in the tree. The
  /// [BuildContext] argument is always the same as the [context] property of
  /// this [State] object and will remain the same for the lifetime of this
  /// object. The [BuildContext] argument is provided redundantly here so that
  /// this method matches the signature for a [WidgetBuilder].
  ///
  /// See also:
  ///
  ///  * [StatefulWidget], which contains the discussion on performance considerations.
  @protected
  Iterable<Widget> build(BuildContext context);

  /// Called when a dependency of this [State] object changes.
  ///
  /// For example, if the previous call to [build] referenced an
  /// [InheritedWidget] that later changed, the framework would call this
  /// method to notify this object about the change.
  ///
  /// This method is also called immediately after [initState]. It is safe to
  /// call [BuildContext.dependOnInheritedWidgetOfExactType] from this method.
  ///
  /// Subclasses rarely override this method because the framework always
  /// calls [build] after a dependency changes. Some subclasses do override
  /// this method because they need to do some expensive work (e.g., network
  /// fetches) when their dependencies change, and that work would be too
  /// expensive to do for every build.
  @protected
  @mustCallSuper
  void didChangeDependencies() {}
}

abstract class ProxyWidget extends Widget {
  const ProxyWidget({
    this.child,
    this.children,
    super.key,
  }) : assert(child == null || children == null);

  final Widget? child;
  final List<Widget>? children;

  @override
  ProxyElement createElement() => ProxyElement(this);
}

/// Base class for widgets that efficiently propagate information down the tree.
///
/// To obtain the nearest instance of a particular type of inherited widget from
/// a build context, use [BuildContext.dependOnInheritedWidgetOfExactType].
///
/// Inherited widgets, when referenced in this way, will cause the consumer to
/// rebuild when the inherited widget itself changes state.
///
/// ## Implementing the `of` method
///
/// The convention is to provide a static method `of` on the [InheritedWidget]
/// which does the call to [BuildContext.dependOnInheritedWidgetOfExactType]. This
/// allows the class to define its own fallback logic in case there isn't
/// a widget in scope. In the example above, the value returned will be
/// null in that case, but it could also have defaulted to a value.
///
/// Occasionally, the inherited widget is an implementation detail of another
/// class, and is therefore private. The `of` method in that case is typically
/// put on the public class instead.
///
/// ## Calling the `of` method
///
/// When using the `of` method, the `context` must be a descendant of the
/// [InheritedWidget], meaning it must be "below" the [InheritedWidget] in the
/// tree.
///
/// See also:
///
///  * [StatefulWidget] and [State], for widgets that can build differently
///    several times over their lifetime.
///  * [StatelessWidget], for widgets that always build the same way given a
///    particular configuration and ambient state.
///  * [Widget], for an overview of widgets in general.
abstract class InheritedWidget extends ProxyWidget {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const InheritedWidget({super.child, super.children, super.key});

  @override
  InheritedElement createElement() => InheritedElement(this);

  /// Whether the framework should notify widgets that inherit from this widget.
  ///
  /// When this widget is rebuilt, sometimes we need to rebuild the widgets that
  /// inherit from this widget but sometimes we do not. For example, if the data
  /// held by this widget is the same as the data held by `oldWidget`, then we
  /// do not need to rebuild the widgets that inherited the data held by
  /// `oldWidget`.
  ///
  /// The framework distinguishes these cases by calling this function with the
  /// widget that previously occupied this location in the tree as an argument.
  /// The given widget is guaranteed to have the same [runtimeType] as this
  /// object.
  @protected
  bool updateShouldNotify(covariant InheritedWidget oldWidget);
}

enum _ElementLifecycle {
  initial,
  active,
  inactive,
  defunct,
}

class _InactiveElements {
  final Set<Element> _elements = HashSet<Element>();

  void _unmount(Element element) {
    assert(element._lifecycleState == _ElementLifecycle.inactive);
    element.visitChildren((Element child) {
      assert(child._parent == element);
      _unmount(child);
    });
    element.unmount();
    assert(element._lifecycleState == _ElementLifecycle.defunct);
  }

  void _unmountAll() {
    final List<Element> elements = _elements.toList()..sort(Element._sort);
    _elements.clear();

    for (var e in elements.reversed) {
      _unmount(e);
    }
    assert(_elements.isEmpty);
  }

  static void _deactivateRecursively(Element element) {
    assert(element._lifecycleState == _ElementLifecycle.active);
    element.deactivate();
    assert(element._lifecycleState == _ElementLifecycle.inactive);
    element.visitChildren(_deactivateRecursively);
  }

  void add(Element element) {
    assert(!_elements.contains(element));
    assert(element._parent == null);
    if (element._lifecycleState == _ElementLifecycle.active) {
      element.detachRenderObject();
      _deactivateRecursively(element);
    }
    _elements.add(element);
  }

  void remove(Element element) {
    assert(_elements.contains(element));
    assert(element._parent == null);
    _elements.remove(element);
    assert(element._lifecycleState != _ElementLifecycle.active);
  }
}

/// Signature for the callback to [BuildContext.visitChildElements].
///
/// The argument is the child being visited.
///
/// It is safe to call `element.visitChildElements` reentrantly within
/// this callback.
typedef ElementVisitor = void Function(Element element);

/// The BuildContext supplied to a Widgets build() method.
sealed class BuildContext {
  /// The current configuration of the [Element] that is this [BuildContext].
  Widget get widget;

  /// The root widget binding that manages the widget tree.
  AppBinding get binding;

  /// Whether the [widget] is currently updating the widget or render tree.
  ///
  /// For [StatefulWidget]s and [StatelessWidget]s this flag is true while
  /// their respective build methods are executing.
  /// Other [Widget] types may set this to true for conceptually similar phases
  /// of their lifecycle.
  ///
  /// When this is true, it is safe for [widget] to establish a dependency to an
  /// [InheritedWidget] by calling [dependOnInheritedElement] or
  /// [dependOnInheritedWidgetOfExactType].
  ///
  /// Accessing this flag in release mode is not valid.
  bool get debugDoingBuild;

  /// Registers this build context with [ancestor] such that when
  /// [ancestor]'s widget changes this build context is rebuilt.
  ///
  /// Returns `ancestor.widget`.
  ///
  /// This method is rarely called directly. Most applications should use
  /// [dependOnInheritedWidgetOfExactType], which calls this method after finding
  /// the appropriate [InheritedElement] ancestor.
  ///
  /// All of the qualifications about when [dependOnInheritedWidgetOfExactType] can
  /// be called apply to this method as well.
  InheritedWidget dependOnInheritedElement(InheritedElement ancestor, {Object? aspect});

  /// Obtains the nearest widget of the given type `T`, which must be the type of a
  /// concrete [InheritedWidget] subclass, and registers this build context with
  /// that widget such that when that widget changes (or a new widget of that
  /// type is introduced, or the widget goes away), this build context is
  /// rebuilt so that it can obtain new values from that widget.
  ///
  /// This is typically called implicitly from `of()` static methods, e.g.
  /// [Router.of].
  ///
  /// The [aspect] parameter is only used when `T` is an
  /// [InheritedWidget] subclasses that supports partial updates.
  /// It specifies what "aspect" of the inherited
  /// widget this context depends on.
  T? dependOnInheritedWidgetOfExactType<T extends InheritedWidget>({Object? aspect});

  /// Obtains the element corresponding to the nearest widget of the given type `T`,
  /// which must be the type of a concrete [InheritedWidget] subclass.
  ///
  /// Returns null if no such element is found.
  ///
  /// Calling this method is O(1) with a small constant factor.
  ///
  /// This method does not establish a relationship with the target in the way
  /// that [dependOnInheritedWidgetOfExactType] does.
  InheritedElement? getElementForInheritedWidgetOfExactType<T extends InheritedWidget>();

  /// Returns the [State] object of the nearest ancestor [StatefulWidget] widget
  /// that is an instance of the given type `T`.
  ///
  /// Calling this method is relatively expensive (O(N) in the depth of the
  /// tree). Only call this method if the distance from this widget to the
  /// desired ancestor is known to be small and bounded.
  T? findAncestorStateOfType<T extends State>();

  /// Walks the ancestor chain, starting with the parent of this build context's
  /// widget, invoking the argument for each ancestor. The callback is given a
  /// reference to the ancestor widget's corresponding [Element] object. The
  /// walk stops when it reaches the root widget or when the callback returns
  /// false. The callback must not return null.
  ///
  /// This is useful for inspecting the widget tree.
  ///
  /// Calling this method is relatively expensive (O(N) in the depth of the tree).
  void visitAncestorElements(bool Function(Element element) visitor);

  /// Walks the children of this widget.
  ///
  /// This is useful for applying changes to children after they are built
  /// without waiting for the next frame, especially if the children are known.
  ///
  /// Calling this method is potentially expensive for elements with a lot of children
  /// (O(N) in the number of children).
  ///
  /// Calling this method recursively is extremely expensive (O(N) in the number
  /// of descendants), and should be avoided if possible. Generally it is
  /// significantly cheaper to use an [InheritedWidget] and have the descendants
  /// pull data down, than it is to use [visitChildElements] recursively to push
  /// data down to them.
  void visitChildElements(ElementVisitor visitor);

  /// Start bubbling this notification at the given build context.
  ///
  /// The notification will be delivered to any [NotificationListener] widgets
  /// with the appropriate type parameters that are ancestors of the given
  /// [BuildContext].
  void dispatchNotification(Notification notification);
}

class BuildOwner {
  final List<Element> _dirtyElements = <Element>[];

  bool _scheduledBuild = false;

  // ignore: prefer_final_fields
  bool _isFirstBuild = false;
  bool get isFirstBuild => _isFirstBuild;

  Future<void> performInitialBuild(Element element) async {
    element.mount(null, null);
    element.didMount();
  }

  final _InactiveElements _inactiveElements = _InactiveElements();

  /// Whether [_dirtyElements] need to be sorted again as a result of more
  /// elements becoming dirty during the build.
  ///
  /// This is necessary to preserve the sort order defined by [Element._sort].
  ///
  /// This field is set to null when [performBuild] is not actively rebuilding
  /// the widget tree.
  bool? _dirtyElementsNeedsResorting;

  void scheduleBuildFor(Element element) {
    assert(!isFirstBuild);
    assert(element.dirty, 'scheduleBuildFor() called for a widget that is not marked as dirty.');

    if (element._inDirtyList) {
      _dirtyElementsNeedsResorting = true;
      return;
    }
    if (!_scheduledBuild) {
      element.binding.scheduleBuild(performBuild);
      _scheduledBuild = true;
    }

    _dirtyElements.add(element);
    element._inDirtyList = true;
  }

  /// Whether this widget tree is in the build phase.
  ///
  /// Only valid when asserts are enabled.
  bool get debugBuilding => _debugBuilding;
  bool _debugBuilding = false;
  Element? _debugCurrentBuildTarget;

  int _debugStateLockLevel = 0;
  bool get _debugStateLocked => _debugStateLockLevel > 0;

  /// Establishes a scope in which calls to [State.setState] are forbidden, and
  /// calls the given `callback`.
  ///
  /// This mechanism is used to ensure that, for instance, [State.dispose] does
  /// not call [State.setState].
  Future<void> lockState(dynamic Function() callback) async {
    assert(_debugStateLockLevel >= 0);
    assert(() {
      _debugStateLockLevel += 1;
      return true;
    }());
    try {
      var res = callback() as dynamic;
      if (res is Future) {
        await res;
      }
    } finally {
      assert(() {
        _debugStateLockLevel -= 1;
        return true;
      }());
    }
    assert(_debugStateLockLevel >= 0);
  }

  /// Rebuilds [child] and correctly accounts for any asynchronous operations that can
  /// occur during the initial build of the app.
  /// We want the widget and element apis to stay synchronous, so this delays
  /// the execution of [child.performRebuild()] instead of calling it directly.
  void performRebuildOn(Element child, void Function() whenComplete) {
    Object? result = child.performRebuild() as dynamic;
    assert(
      result is! Future,
      '${child.runtimeType}.performBuild() returned a Future while rebuilding.\n\n'
      'Only server builds are allowed to be asynchronous.',
    );
    whenComplete();
    child.attachRenderObject();
  }

  void performBuild() {
    assert(!isFirstBuild);

    assert(_debugStateLockLevel >= 0);
    assert(!_debugBuilding);

    assert(() {
      _debugStateLockLevel += 1;
      _debugBuilding = true;
      return true;
    }());

    try {
      _dirtyElements.sort(Element._sort);
      _dirtyElementsNeedsResorting = false;

      int dirtyCount = _dirtyElements.length;
      int index = 0;

      while (index < dirtyCount) {
        final Element element = _dirtyElements[index];
        assert(element._inDirtyList);

        try {
          element.rebuild();
          if (element._lifecycleState == _ElementLifecycle.active) {
            assert(!element._dirty, 'Build was not finished synchronously on $element');
          }
        } catch (e) {
          // TODO: properly report error
          print("Error on rebuilding widget: $e");
          rethrow;
        }

        index += 1;
        if (dirtyCount < _dirtyElements.length || _dirtyElementsNeedsResorting!) {
          _dirtyElements.sort(Element._sort);
          _dirtyElementsNeedsResorting = false;
          dirtyCount = _dirtyElements.length;
          while (index > 0 && _dirtyElements[index - 1].dirty) {
            index -= 1;
          }
        }
      }

      assert(() {
        if (_dirtyElements
            .any((Element element) => element._lifecycleState == _ElementLifecycle.active && element.dirty)) {
          throw 'performBuild missed some dirty elements.';
        }
        return true;
      }());
    } finally {
      for (final Element element in _dirtyElements) {
        assert(element._inDirtyList);
        element._inDirtyList = false;
      }

      _dirtyElements.clear();
      _dirtyElementsNeedsResorting = null;

      lockState(_inactiveElements._unmountAll);

      _scheduledBuild = false;

      assert(_debugBuilding);
      assert(() {
        _debugBuilding = false;
        _debugStateLockLevel -= 1;
        return true;
      }());
    }
    assert(_debugStateLockLevel >= 0);
  }
}

/// Mixin this class to allow receiving [Notification] objects dispatched by
/// child elements.
///
/// See also:
///   * [NotificationListener], for a widget that allows consuming notifications.
mixin NotifiableElementMixin on Element {
  /// Called when a notification of the appropriate type arrives at this
  /// location in the tree.
  ///
  /// Return true to cancel the notification bubbling. Return false to
  /// allow the notification to continue to be dispatched to further ancestors.
  bool onNotification(Notification notification);

  @override
  void attachNotificationTree() {
    _notificationTree = _NotificationNode(_parent?._notificationTree, this);
  }
}

class _NotificationNode {
  _NotificationNode(this.parent, this.current);

  NotifiableElementMixin? current;
  _NotificationNode? parent;

  void dispatchNotification(Notification notification) {
    if (current?.onNotification(notification) ?? true) {
      return;
    }
    parent?.dispatchNotification(notification);
  }
}

/// An instantiation of a [Widget] at a particular location in the tree.
///
/// Widgets describe how to configure a subtree but the same widget can be used
/// to configure multiple subtrees simultaneously because widgets are immutable.
/// An [Element] represents the use of a widget to configure a specific location
/// in the tree. Over time, the widget associated with a given element can
/// change, for example, if the parent widget rebuilds and creates a new widget
/// for this location..
abstract class Element implements BuildContext {
  /// Creates an element that uses the given widget as its configuration.
  ///
  /// Typically called by an override of [Widget.createElement].
  Element(Widget widget) : _widget = widget;

  Element? _parent;
  Element? get parent => _parent;

  _NotificationNode? _notificationTree;

  /// Compare two widgets for equality.
  ///
  /// When a widget is rebuilt with another that compares equal according
  /// to `operator ==`, it is assumed that the update is redundant and the
  /// work to update that branch of the tree is skipped.
  ///
  /// It is generally discouraged to override `operator ==` on any widget that
  /// has children, since a correct implementation would have to defer to the
  /// children's equality operator also, and that is an O(N²) operation: each
  /// child would need to itself walk all its children, each step of the tree.
  ///
  /// It is sometimes reasonable for a leaf widget (one with no children) to
  /// implement this method, if rebuilding the widget is known to be much more
  /// expensive than checking the widgets' parameters for equality and if the
  /// widget is expected to often be rebuilt with identical parameters.
  ///
  /// In general, however, it is more efficient to cache the widgets used
  /// in a build method if it is known that they will not change.
  @nonVirtual
  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) => identical(this, other);

  // Custom implementation of hash code optimized for the ".of" pattern used
  // with `InheritedWidgets`.
  //
  // `Element.dependOnInheritedWidgetOfExactType` relies heavily on hash-based
  // `Set` look-ups, putting this getter on the performance critical path.
  //
  // The value is designed to fit within the SMI representation. This makes
  // the cached value use less memory (one field and no extra heap objects) and
  // cheap to compare (no indirection).
  @nonVirtual
  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => _cachedHash;
  final int _cachedHash = _nextHashCode = (_nextHashCode + 1) % 0xffffff;
  static int _nextHashCode = 1;

  /// An integer that is guaranteed to be greater than the parent's, if any.
  /// The element at the root of the tree must have a depth greater than 0.
  int get depth => _depth!;
  int? _depth;

  static int _sort(Element a, Element b) {
    if (a.depth < b.depth) {
      return -1;
    } else if (b.depth < a.depth) {
      return 1;
    } else if (b.dirty && !a.dirty) {
      return -1;
    } else if (a.dirty && !b.dirty) {
      return 1;
    }
    return 0;
  }

  /// The configuration for this element.
  @override
  Widget get widget => _widget!;
  Widget? _widget;

  /// The root widget binding that manages the widget tree.
  @override
  AppBinding get binding => _binding!;
  AppBinding? _binding;

  /// The root build owner that manages the build cycle.
  BuildOwner get owner => _owner!;
  BuildOwner? _owner;

  // This is used to verify that Element objects move through life in an
  // orderly fashion.
  _ElementLifecycle _lifecycleState = _ElementLifecycle.initial;

  /// Calls the argument for each child.
  ///
  /// There is no guaranteed order in which the children will be visited, though
  /// it should be consistent over time.
  ///
  /// Calling this during build is dangerous: the child list might still be
  /// being updated at that point, so the children might not be constructed yet,
  /// or might be old children that are going to be replaced. This method should
  /// only be called if it is provable that the children are available.
  void visitChildren(ElementVisitor visitor);

  /// Wrapper around [visitChildren] for [BuildContext].
  @override
  void visitChildElements(ElementVisitor visitor) {
    visitChildren(visitor);
  }

  /// Update the given child with the given new configuration.
  ///
  /// This method is the core of the widgets system. It is called each time we
  /// are to add, update, or remove a child based on an updated configuration.
  ///
  /// If the `child` is null, and the `newWidget` is not null, then we have a new
  /// child for which we need to create an [Element], configured with `newWidget`.
  ///
  /// If the `newWidget` is null, and the `child` is not null, then we need to
  /// remove it because it no longer has a configuration.
  ///
  /// If neither are null, then we need to update the `child`'s configuration to
  /// be the new configuration given by `newWidget`. If `newWidget` can be given
  /// to the existing child (as determined by [Widget.canUpdate]), then it is so
  /// given. Otherwise, the old child needs to be disposed and a new child
  /// created for the new configuration.
  ///
  /// If both are null, then we don't have a child and won't have a child, so we
  /// do nothing.
  ///
  /// The [updateChild] method returns the new child, if it had to create one,
  /// or the child that was passed in, if it just had to update the child, or
  /// null, if it removed the child and did not replace it.
  ///
  /// The following table summarizes the above:
  ///
  /// |                     | **newWidget == null**  | **newWidget != null**   |
  /// | :-----------------: | :--------------------- | :---------------------- |
  /// |  **child == null**  |  Returns null.         |  Returns new [Element]. |
  /// |  **child != null**  |  Old child is removed, returns null. | Old child updated if possible, returns child or new [Element]. |
  @protected
  Element? updateChild(Element? child, Widget? newWidget, Element? prevSibling) {
    if (newWidget == null) {
      if (child != null) {
        if (_lastChild == child) {
          updateLastChild(prevSibling);
        }
        deactivateChild(child);
      }
      return null;
    }
    final Element newChild;
    if (child != null) {
      if (child._widget == newWidget) {
        if (child._parentChanged || child._prevSibling != prevSibling) {
          child.updatePrevSibling(prevSibling);
        }
        newChild = child;
      } else if (child._parentChanged || Widget.canUpdate(child.widget, newWidget)) {
        if (child._parentChanged || child._prevSibling != prevSibling) {
          child.updatePrevSibling(prevSibling);
        }
        var oldWidget = child.widget;
        child.update(newWidget);
        assert(child.widget == newWidget);
        child.didUpdate(oldWidget);
        newChild = child;
      } else {
        deactivateChild(child);
        assert(child._parent == null);
        newChild = inflateWidget(newWidget, prevSibling);
      }
    } else {
      newChild = inflateWidget(newWidget, prevSibling);
    }

    if (_lastChild == prevSibling) {
      updateLastChild(newChild);
    }

    return newChild;
  }

  /// Updates the children of this element to use new widgets.
  ///
  /// Attempts to update the given old children list using the given new
  /// widgets, removing obsolete elements and introducing new ones as necessary,
  /// and then returns the new child list.
  ///
  /// During this function the `oldChildren` list must not be modified. If the
  /// caller wishes to remove elements from `oldChildren` re-entrantly while
  /// this function is on the stack, the caller can supply a `forgottenChildren`
  /// argument, which can be modified while this function is on the stack.
  /// Whenever this function reads from `oldChildren`, this function first
  /// checks whether the child is in `forgottenChildren`. If it is, the function
  /// acts as if the child was not in `oldChildren`.
  ///
  /// This function is a convenience wrapper around [updateChild], which updates
  /// each individual child.
  @protected
  List<Element> updateChildren(List<Element> oldChildren, List<Widget> newWidgets, {Set<Element>? forgottenChildren}) {
    Element? replaceWithNullIfForgotten(Element? child) {
      return child != null && forgottenChildren != null && forgottenChildren.contains(child) ? null : child;
    }

    // This attempts to diff the new child list (newWidgets) with
    // the old child list (oldChildren), and produce a new list of elements to
    // be the new list of child elements of this element. The called of this
    // method is expected to update this render object accordingly.

    // The cases it tries to optimize for are:
    //  - the old list is empty
    //  - the lists are identical
    //  - there is an insertion or removal of one or more widgets in
    //    only one place in the list
    // If a widget with a key is in both lists, it will be synced.
    // Widgets without keys might be synced but there is no guarantee.

    // The general approach is to sync the entire new list backwards, as follows:
    // 1. Walk the lists from the top, syncing nodes, until you no longer have
    //    matching nodes.
    // 2. Walk the lists from the bottom, without syncing nodes, until you no
    //    longer have matching nodes. We'll sync these nodes at the end. We
    //    don't sync them now because we want to sync all the nodes in order
    //    from beginning to end.
    // At this point we narrowed the old and new lists to the point
    // where the nodes no longer match.
    // 3. Walk the narrowed part of the old list to get the list of
    //    keys and sync null with non-keyed items.
    // 4. Walk the narrowed part of the new list forwards:
    //     * Sync non-keyed items with null
    //     * Sync keyed items with the source if it exists, else with null.
    // 5. Walk the bottom of the list again, syncing the nodes.
    // 6. Sync null with any items in the list of keys that are still
    //    mounted.

    if (oldChildren.length <= 1 && newWidgets.length <= 1) {
      final Element? oldChild = replaceWithNullIfForgotten(oldChildren.firstOrNull);
      var newChild = updateChild(oldChild, newWidgets.firstOrNull, null);
      return [if (newChild != null) newChild];
    }

    int newChildrenTop = 0;
    int oldChildrenTop = 0;
    int newChildrenBottom = newWidgets.length - 1;
    int oldChildrenBottom = oldChildren.length - 1;

    final List<Element?> newChildren = oldChildren.length == newWidgets.length
        ? oldChildren
        : List<Element?>.filled(newWidgets.length, null, growable: true);

    Element? prevChild;

    // Update the top of the list.
    while ((oldChildrenTop <= oldChildrenBottom) && (newChildrenTop <= newChildrenBottom)) {
      final Element? oldChild = replaceWithNullIfForgotten(oldChildren[oldChildrenTop]);
      final Widget newWidget = newWidgets[newChildrenTop];
      if (oldChild == null || !Widget.canUpdate(oldChild.widget, newWidget)) break;
      final Element newChild = updateChild(oldChild, newWidget, prevChild)!;
      newChildren[newChildrenTop] = newChild;
      prevChild = newChild;
      newChildrenTop += 1;
      oldChildrenTop += 1;
    }

    // Scan the bottom of the list.
    while ((oldChildrenTop <= oldChildrenBottom) && (newChildrenTop <= newChildrenBottom)) {
      final Element? oldChild = replaceWithNullIfForgotten(oldChildren[oldChildrenBottom]);
      final Widget newWidget = newWidgets[newChildrenBottom];
      if (oldChild == null || !Widget.canUpdate(oldChild.widget, newWidget)) break;
      oldChildrenBottom -= 1;
      newChildrenBottom -= 1;
    }

    Map<Key, Element>? retakeOldKeyedChildren;
    if (newChildrenTop <= newChildrenBottom && oldChildrenTop <= oldChildrenBottom) {
      final Map<Key, Widget> newKeyedChildren = {};
      var newChildrenTopPeek = newChildrenTop;
      while (newChildrenTopPeek <= newChildrenBottom) {
        final Widget newWidget = newWidgets[newChildrenTopPeek];
        final Key? key = newWidget.key;
        if (key != null) {
          newKeyedChildren[key] = newWidget;
        }
        newChildrenTopPeek += 1;
      }

      if (newKeyedChildren.isNotEmpty) {
        retakeOldKeyedChildren = {};
        var oldChildrenTopPeek = oldChildrenTop;
        while (oldChildrenTopPeek <= oldChildrenBottom) {
          final Element? oldChild = replaceWithNullIfForgotten(oldChildren[oldChildrenTopPeek]);
          if (oldChild != null) {
            final Key? key = oldChild.widget.key;
            if (key != null) {
              final Widget? newWidget = newKeyedChildren[key];
              if (newWidget != null && Widget.canUpdate(oldChild.widget, newWidget)) {
                retakeOldKeyedChildren[key] = oldChild;
              }
            }
          }
          oldChildrenTopPeek += 1;
        }
      }
    }

    while (newChildrenTop <= newChildrenBottom) {
      if (oldChildrenTop <= oldChildrenBottom) {
        final Element? oldChild = replaceWithNullIfForgotten(oldChildren[oldChildrenTop]);
        if (oldChild != null) {
          final Key? key = oldChild.widget.key;
          if (key == null || retakeOldKeyedChildren == null || !retakeOldKeyedChildren.containsKey(key)) {
            deactivateChild(oldChild);
          }
        }
        oldChildrenTop += 1;
      }

      Element? oldChild;
      final Widget newWidget = newWidgets[newChildrenTop];
      final Key? key = newWidget.key;
      if (key != null) {
        oldChild = retakeOldKeyedChildren?[key];
      }

      final Element newChild = updateChild(oldChild, newWidget, prevChild)!;
      newChildren[newChildrenTop] = newChild;
      prevChild = newChild;
      newChildrenTop += 1;
    }

    while (oldChildrenTop <= oldChildrenBottom) {
      final Element? oldChild = replaceWithNullIfForgotten(oldChildren[oldChildrenTop]);
      if (oldChild != null) {
        final Key? key = oldChild.widget.key;
        if (key == null || retakeOldKeyedChildren == null || !retakeOldKeyedChildren.containsKey(key)) {
          deactivateChild(oldChild);
        }
      }
      oldChildrenTop += 1;
    }

    // We've scanned the whole list.
    newChildrenBottom = newWidgets.length - 1;
    oldChildrenBottom = oldChildren.length - 1;

    // Update the bottom of the list.
    while ((oldChildrenTop <= oldChildrenBottom) && (newChildrenTop <= newChildrenBottom)) {
      final Element oldChild = oldChildren[oldChildrenTop];
      final Widget newWidget = newWidgets[newChildrenTop];
      final Element newChild = updateChild(oldChild, newWidget, prevChild)!;
      newChildren[newChildrenTop] = newChild;
      prevChild = newChild;
      newChildrenTop += 1;
      oldChildrenTop += 1;
    }

    assert(newChildren.every((element) => element != null));

    return newChildren.cast<Element>();
  }

  /// Add this element to the tree as a child of the given parent.
  ///
  /// The framework calls this function when a newly created element is added to
  /// the tree for the first time. Use this method to initialize state that
  /// depends on having a parent. State that is independent of the parent can
  /// more easily be initialized in the constructor.
  ///
  /// This method transitions the element from the "initial" lifecycle state to
  /// the "active" lifecycle state.
  ///
  /// Subclasses that override this method are likely to want to also override
  /// [update] and [visitChildren].
  ///
  /// Implementations of this method should start with a call to the inherited
  /// method, as in `super.mount(parent)`.
  @mustCallSuper
  void mount(Element? parent, Element? prevSibling) {
    assert(_lifecycleState == _ElementLifecycle.initial);
    assert(_widget != null);
    assert(_parent == null);
    assert(parent == null || parent._lifecycleState == _ElementLifecycle.active);

    _parent = parent;
    _parentRenderObjectElement = parent is RenderObjectElement ? parent : parent?._parentRenderObjectElement;

    _prevSibling = prevSibling;
    _prevAncestorSibling = _prevSibling ?? (_parent is RenderObjectElement ? null : _parent?._prevAncestorSibling);

    _lifecycleState = _ElementLifecycle.active;
    _depth = parent != null ? parent.depth + 1 : 1;

    if (parent != null) {
      _owner = parent.owner;
      _binding = parent.binding;
    }
    assert(_owner != null);
    assert(_binding != null);

    final Key? key = widget.key;
    if (key is GlobalKey && binding.isClient) {
      WidgetsBinding._registerGlobalKey(key, this);
    }
    _updateInheritance();
    _updateObservers();
    attachNotificationTree();
  }

  @protected
  @mustCallSuper
  void didMount() {}

  /// Change the widget used to configure this element.
  ///
  /// The framework calls this function when the parent wishes to use a
  /// different widget to configure this element. The new widget is guaranteed
  /// to have the same [runtimeType] as the old widget.
  ///
  /// This function is called only during the "active" lifecycle state.
  @mustCallSuper
  void update(covariant Widget newWidget) {
    assert(_lifecycleState == _ElementLifecycle.active);
    assert(_widget != null);
    assert(newWidget != widget);
    assert(_depth != null);
    assert(Widget.canUpdate(widget, newWidget));
    if (shouldRebuild(newWidget)) {
      _dirty = true;
    }
    _widget = newWidget;
  }

  void didUpdate(covariant Widget oldWidget) {
    if (_dirty) {
      rebuild();
    }
  }

  /// Implement this method to determine whether a rebuild can be skipped.
  ///
  /// This method will be called whenever the widget is about to update. If returned false, the subsequent rebuild will be skipped.
  ///
  /// This method exists only as a performance optimization and gives no guarantees about when the widget is rebuilt.
  /// Keep the implementation as efficient as possible and avoid deep (recursive) comparisons or performance heavy checks, as this might
  /// have an opposite effect on performance.
  bool shouldRebuild(covariant Widget newWidget);

  void _updateDepth(int parentDepth) {
    final int expectedDepth = parentDepth + 1;
    if (depth < expectedDepth) {
      _depth = expectedDepth;
      visitChildren((Element child) {
        child._updateDepth(expectedDepth);
      });
    }
  }

  Element? _retakeInactiveElement(GlobalKey key, Widget newWidget) {
    final Element? element = key._currentElement;
    if (element == null) {
      return null;
    }
    if (!Widget.canUpdate(element.widget, newWidget)) {
      return null;
    }
    final Element? parent = element._parent;
    if (parent != null) {
      parent.forgetChild(element);
      parent.deactivateChild(element);
    }
    assert(element._parent == null);
    owner._inactiveElements.remove(element);
    return element;
  }

  /// Create an element for the given widget and add it as a child of this
  /// element.
  ///
  /// This method is typically called by [updateChild] but can be called
  /// directly by subclasses that need finer-grained control over creating
  /// elements.
  ///
  /// If the given widget has a global key and an element already exists that
  /// has a widget with that global key, this function will reuse that element
  /// (potentially grafting it from another location in the tree or reactivating
  /// it from the list of inactive elements) rather than creating a new element.
  ///
  /// The element returned by this function will already have been mounted and
  /// will be in the "active" lifecycle state.
  @protected
  Element inflateWidget(Widget newWidget, Element? prevSibling) {
    final Key? key = newWidget.key;
    if (key is GlobalKey) {
      final Element? newChild = _retakeInactiveElement(key, newWidget);
      if (newChild != null) {
        assert(newChild._parent == null);
        newChild._activateWithParent(this);
        newChild._parentChanged = true;
        final Element? updatedChild = updateChild(newChild, newWidget, prevSibling);
        assert(newChild == updatedChild);
        return updatedChild!;
      }
    }
    final Element newChild = newWidget.createElement();
    newChild.mount(this, prevSibling);
    newChild.didMount();
    assert(newChild._lifecycleState == _ElementLifecycle.active);
    return newChild;
  }

  /// Move the given element to the list of inactive elements and detach its
  /// render object from the render tree.
  ///
  /// This method stops the given element from being a child of this element by
  /// detaching its render object from the render tree and moving the element to
  /// the list of inactive elements.
  ///
  /// This method (indirectly) calls [deactivate] on the child.
  ///
  /// The caller is responsible for removing the child from its child model.
  /// Typically [deactivateChild] is called by the element itself while it is
  /// updating its child model; however, during [GlobalKey] reparenting, the new
  /// parent proactively calls the old parent's [deactivateChild], first using
  /// [forgetChild] to cause the old parent to update its child model.
  @protected
  void deactivateChild(Element child) {
    assert(child._parent == this);
    child._parent = null;
    child._prevSibling = null;
    child._prevAncestorSibling = null;
    owner._inactiveElements.add(child);
  }

  /// Remove the given child from the element's child list, in preparation for
  /// the child being reused elsewhere in the element tree.
  ///
  /// This updates the child model such that, e.g., [visitChildren] does not
  /// walk that child anymore.
  ///
  /// The element will still have a valid parent when this is called.
  /// After this is called, [deactivateChild] is called to sever the link to
  /// this object.
  ///
  /// The [update] is responsible for updating or creating the new child that
  /// will replace this [child].
  @protected
  @mustCallSuper
  void forgetChild(Element child) {}

  void _activateWithParent(Element parent) {
    assert(_lifecycleState == _ElementLifecycle.inactive);
    _parent = parent;
    _parentRenderObjectElement = parent is RenderObjectElement ? parent : parent._parentRenderObjectElement;
    _updateDepth(_parent!.depth);
    _activateRecursively(this);
    assert(_lifecycleState == _ElementLifecycle.active);
  }

  static void _activateRecursively(Element element) {
    assert(element._lifecycleState == _ElementLifecycle.inactive);
    element.activate();
    assert(element._lifecycleState == _ElementLifecycle.active);
    element.visitChildren(_activateRecursively);
  }

  /// Transition from the "inactive" to the "active" lifecycle state.
  ///
  /// The framework calls this method when a previously deactivated element has
  /// been reincorporated into the tree. The framework does not call this method
  /// the first time an element becomes active (i.e., from the "initial"
  /// lifecycle state). Instead, the framework calls [mount] in that situation.
  ///
  /// Implementations of this method should start with a call to the inherited
  /// method, as in `super.activate()`.
  @mustCallSuper
  void activate() {
    assert(_lifecycleState == _ElementLifecycle.inactive);
    assert(_widget != null);
    assert(_owner != null);
    assert(_binding != null);
    assert(_parent != null);
    assert(_depth != null);
    final bool hadDependencies = (_dependencies != null && _dependencies!.isNotEmpty) || _hadUnsatisfiedDependencies;
    _lifecycleState = _ElementLifecycle.active;

    var parent = _parent!;
    _parentRenderObjectElement = parent is RenderObjectElement ? parent : parent._parentRenderObjectElement;

    _dependencies?.clear();
    _hadUnsatisfiedDependencies = false;
    _updateInheritance();
    _updateObservers();
    attachNotificationTree();
    if (_dirty) {
      owner.scheduleBuildFor(this);
    }
    if (hadDependencies) didChangeDependencies();
  }

  /// Transition from the "active" to the "inactive" lifecycle state.
  ///
  /// The framework calls this method when a previously active element is moved
  /// to the list of inactive elements. While in the inactive state, the element
  /// will not appear on screen. The element can remain in the inactive state
  /// only until the end of the current animation frame. At the end of the
  /// animation frame, if the element has not be reactivated, the framework will
  /// unmount the element.
  ///
  /// This is (indirectly) called by [deactivateChild].
  ///
  /// Implementations of this method should end with a call to the inherited
  /// method, as in `super.deactivate()`.
  @mustCallSuper
  void deactivate() {
    assert(_lifecycleState == _ElementLifecycle.active);
    assert(_widget != null);
    assert(_depth != null);
    if (_dependencies != null && _dependencies!.isNotEmpty) {
      for (var dependency in _dependencies!) {
        dependency.deactivateDependent(this);
      }
    }
    _inheritedElements = null;
    _lifecycleState = _ElementLifecycle.inactive;
  }

  /// Transition from the "inactive" to the "defunct" lifecycle state.
  ///
  /// Called when the framework determines that an inactive element will never
  /// be reactivated. At the end of each animation frame, the framework calls
  /// [unmount] on any remaining inactive elements, preventing inactive elements
  /// from remaining inactive for longer than a single animation frame.
  ///
  /// After this function is called, the element will not be incorporated into
  /// the tree again.
  ///
  /// Any resources this element holds should be released at this point.
  ///
  /// Implementations of this method should end with a call to the inherited
  /// method, as in `super.unmount()`.
  @mustCallSuper
  void unmount() {
    assert(_lifecycleState == _ElementLifecycle.inactive);
    assert(_widget != null);
    assert(_depth != null);
    assert(_owner != null);

    if (_observerElements != null && _observerElements!.isNotEmpty) {
      for (var observer in _observerElements!) {
        observer.didUnmountElement(this);
      }
      _observerElements = null;
    }

    final Key? key = widget.key;
    if (key is GlobalKey) {
      WidgetsBinding._unregisterGlobalKey(key, this);
    }

    _parentRenderObjectElement = null;
    _widget = null;
    _dependencies = null;
    _lifecycleState = _ElementLifecycle.defunct;
  }

  List<ObserverElement>? _observerElements;

  Map<Type, InheritedElement>? _inheritedElements;
  Set<InheritedElement>? _dependencies;
  bool _hadUnsatisfiedDependencies = false;

  @override
  InheritedWidget dependOnInheritedElement(InheritedElement ancestor, {Object? aspect}) {
    _dependencies ??= HashSet<InheritedElement>();
    _dependencies!.add(ancestor);
    ancestor.updateDependencies(this, aspect);
    return ancestor.widget;
  }

  @override
  T? dependOnInheritedWidgetOfExactType<T extends InheritedWidget>({Object? aspect}) {
    final InheritedElement? ancestor = _inheritedElements == null ? null : _inheritedElements![T];
    if (ancestor != null) {
      return dependOnInheritedElement(ancestor, aspect: aspect) as T;
    }
    _hadUnsatisfiedDependencies = true;
    return null;
  }

  @override
  InheritedElement? getElementForInheritedWidgetOfExactType<T extends InheritedWidget>() {
    final InheritedElement? ancestor = _inheritedElements == null ? null : _inheritedElements![T];
    return ancestor;
  }

  void _updateInheritance() {
    assert(_lifecycleState == _ElementLifecycle.active);
    _inheritedElements = _parent?._inheritedElements;
  }

  /// Populates [_observerElements] when this Element is mounted or activated.
  /// [ObserverElement]s will register themselves for their children.
  void _updateObservers() {
    assert(_lifecycleState == _ElementLifecycle.active);
    _observerElements = _parent?._observerElements;
  }

  /// Called in [Element.mount] and [Element.activate] to register this element in
  /// the notification tree.
  ///
  /// This method is only exposed so that [NotifiableElementMixin] can be implemented.
  /// Subclasses of [Element] that wish to respond to notifications should mix that
  /// in instead.
  ///
  /// See also:
  ///   * [NotificationListener], a widget that allows listening to notifications.
  @protected
  void attachNotificationTree() {
    _notificationTree = _parent?._notificationTree;
  }

  @override
  T? findAncestorStateOfType<T extends State<StatefulWidget>>() {
    Element? ancestor = _parent;
    while (ancestor != null) {
      if (ancestor is StatefulElement && ancestor.state is T) {
        break;
      }
      ancestor = ancestor._parent;
    }
    final StatefulElement? statefulAncestor = ancestor as StatefulElement?;
    return statefulAncestor?.state as T?;
  }

  @override
  void visitAncestorElements(bool Function(Element element) visitor) {
    Element? ancestor = _parent;
    while (ancestor != null && visitor(ancestor)) {
      ancestor = ancestor._parent;
    }
  }

  /// Called when a dependency of this element changes.
  ///
  /// The [dependOnInheritedWidgetOfExactType] registers this element as depending on
  /// inherited information of the given type. When the information of that type
  /// changes at this location in the tree (e.g., because the [InheritedElement]
  /// updated to a new [InheritedWidget] and
  /// [InheritedWidget.updateShouldNotify] returned true), the framework calls
  /// this function to notify this element of the change.
  void didChangeDependencies() {
    assert(_lifecycleState == _ElementLifecycle.active);
    assert(_debugCheckOwnerBuildTargetExists('didChangeDependencies'));
    markNeedsBuild();
  }

  bool _debugCheckOwnerBuildTargetExists(String methodName) {
    assert(() {
      if (owner._debugCurrentBuildTarget == null) {
        throw '$methodName for ${widget.runtimeType} was called at an '
            'inappropriate time.';
      }
      return true;
    }());
    return true;
  }

  /// Returns true if the element has been marked as needing rebuilding.
  bool _dirty = true;
  bool get dirty => _dirty;

  // Whether this is in owner._dirtyElements. This is used to know whether we
  // should be adding the element back into the list when it's reactivated.
  // ignore: prefer_final_fields
  bool _inDirtyList = false;

  // We let widget authors call setState from initState, didUpdateWidget, and
  // build even when state is locked because its convenient and a no-op anyway.
  // This flag ensures that this convenience is only allowed on the element
  // currently undergoing initState, didUpdateWidget, or build.
  bool _debugAllowIgnoredCallsToMarkNeedsBuild = false;
  bool _debugSetAllowIgnoredCallsToMarkNeedsBuild(bool value) {
    assert(_debugAllowIgnoredCallsToMarkNeedsBuild == !value);
    _debugAllowIgnoredCallsToMarkNeedsBuild = value;
    return true;
  }

  /// Marks the element as dirty and schedules a rebuild.
  @mustCallSuper
  void markNeedsBuild() {
    assert(_lifecycleState != _ElementLifecycle.defunct);
    if (_lifecycleState != _ElementLifecycle.active) return;
    assert(_parentRenderObjectElement != null);
    assert(_lifecycleState == _ElementLifecycle.active);
    assert(() {
      if (owner._debugBuilding) {
        assert(owner._debugCurrentBuildTarget != null);
        if (_debugIsInScope(owner._debugCurrentBuildTarget!)) {
          return true;
        }
        if (!_debugAllowIgnoredCallsToMarkNeedsBuild) {
          throw 'setState() or markNeedsBuild() called during build.';
        }
        // can only get here if we're not in scope, but ignored calls are allowed, and our call would somehow be ignored (since we're already dirty)
        assert(dirty);
      } else if (owner._debugStateLocked) {
        assert(!_debugAllowIgnoredCallsToMarkNeedsBuild);
        throw 'setState() or markNeedsBuild() called when widget tree was locked.';
      }
      return true;
    }());

    if (_dirty) return;
    _dirty = true;
    owner.scheduleBuildFor(this);
  }

  bool _debugIsInScope(Element target) {
    Element? current = this;
    while (current != null) {
      if (target == current) {
        return true;
      }
      current = current._parent;
    }
    return false;
  }

  /// Cause the widget to update itself.
  ///
  /// Called by the [BuildOwner] when rebuilding, by [mount] when the element is first
  /// built, and by [update] when the widget has changed.
  void rebuild() {
    assert(_lifecycleState != _ElementLifecycle.initial);
    if (_lifecycleState != _ElementLifecycle.active || !_dirty) {
      return;
    }
    assert(_lifecycleState == _ElementLifecycle.active);
    assert(owner._debugStateLocked);
    Element? debugPreviousBuildTarget;
    assert(() {
      if (!binding.isClient && owner.isFirstBuild) return true;
      debugPreviousBuildTarget = owner._debugCurrentBuildTarget;
      owner._debugCurrentBuildTarget = this;
      return true;
    }());
    if (_observerElements != null && _observerElements!.isNotEmpty) {
      for (var observer in _observerElements!) {
        observer.willRebuildElement(this);
      }
    }
    owner.performRebuildOn(this, () {
      assert(() {
        if (!binding.isClient && owner.isFirstBuild) return true;
        assert(owner._debugCurrentBuildTarget == this);
        owner._debugCurrentBuildTarget = debugPreviousBuildTarget;
        return true;
      }());
      assert(!_dirty);
      if (_dependencies != null && _dependencies!.isNotEmpty) {
        for (var dependency in _dependencies!) {
          dependency.didRebuildDependent(this);
        }
      }
      if (_observerElements != null && _observerElements!.isNotEmpty) {
        for (var observer in _observerElements!) {
          observer.didRebuildElement(this);
        }
      }
    });
  }

  /// Cause the widget to update itself.
  ///
  /// Called by [BuildOwner] after the appropriate checks have been made.
  void performRebuild();

  void attachRenderObject() {}

  void detachRenderObject() {
    visitChildren((Element child) {
      assert(child._parent == this);
      child.detachRenderObject();
    });
  }

  @override
  void dispatchNotification(Notification notification) {
    _notificationTree?.dispatchNotification(notification);
  }

  /// The nearest ancestor dom node.
  RenderObjectElement? _parentRenderObjectElement;
  RenderObjectElement? get parentRenderObjectElement => _parentRenderObjectElement;

  /// The direct previous sibling element.
  Element? _prevSibling;
  Element? get prevSibling => _prevSibling;

  /// The direct or indirect previous sibling element.
  ///
  /// If no direct previous sibling exist, this points to the nearest
  /// previous sibling of the parent element recursively.
  /// If no element is found until the nearest ancestor render object
  /// element, this is null.
  Element? _prevAncestorSibling;
  Element? get prevAncestorSibling => _prevAncestorSibling;

  /// The last direct child element.
  Element? _lastChild;

  /// The last direct child element that is also a render object element.
  RenderObjectElement? _lastRenderObjectElement;
  RenderObjectElement? get lastRenderObjectElement => _lastRenderObjectElement;

  void updateLastChild(Element? child) {
    _lastChild = child;
    _lastRenderObjectElement = _lastChild?._lastRenderObjectElement;
    if (_parent?._lastChild == this && _parent?._lastRenderObjectElement != _lastRenderObjectElement) {
      _parent!.updateLastChild(this);
    }
  }

  var _parentChanged = false;

  void updatePrevSibling(Element? prevSibling) {
    assert(_lifecycleState == _ElementLifecycle.active);
    assert(_widget != null);
    assert(_parent != null);
    assert(_parent!._lifecycleState == _ElementLifecycle.active);
    assert(_depth != null);
    assert(_parentRenderObjectElement != null);

    _prevSibling = prevSibling;
    _updateAncestorSiblingRecursively(_parentChanged);
    _parentChanged = false;
  }

  @mustCallSuper
  void _didUpdateSlot() {}

  void _updateAncestorSiblingRecursively(bool didChangeAncestor) {
    var newAncestorSibling = _prevSibling ?? (_parent is RenderObjectElement ? null : _parent?._prevAncestorSibling);
    if (didChangeAncestor || newAncestorSibling != _prevAncestorSibling) {
      _prevAncestorSibling = newAncestorSibling;
      _didUpdateSlot();
      if (this is! RenderObjectElement) {
        visitChildren((e) => e._updateAncestorSiblingRecursively(true));
      }
    }
  }
}

/// An [Element] that has multiple children and a [build] method.
///
/// Used by [DomWidget], [StatelessWidget] and [StatefulWidget].
abstract class BuildableElement extends Element {
  /// Creates an element that uses the given widget as its configuration.
  BuildableElement(super.widget);

  /// The current list of children of this element.
  ///
  /// This list is filtered to hide elements that have been forgotten (using
  /// [forgetChild]).
  @protected
  Iterable<Element> get children => _children!.where((Element child) => !_forgottenChildren.contains(child));

  List<Element>? _children;
  // We keep a set of forgotten children to avoid O(n^2) work walking _children
  // repeatedly to remove children.
  final Set<Element> _forgottenChildren = HashSet<Element>();

  bool _debugDoingBuild = false;
  @override
  bool get debugDoingBuild => _debugDoingBuild;

  @override
  void mount(Element? parent, Element? prevSibling) {
    super.mount(parent, prevSibling);
    assert(_children == null);
  }

  @override
  void didMount() {
    rebuild();
    super.didMount();
  }

  @override
  bool shouldRebuild(Widget newWidget) {
    return true;
  }

  @override
  void performRebuild() {
    assert(_debugSetAllowIgnoredCallsToMarkNeedsBuild(true));
    List<Widget>? built;
    try {
      assert(() {
        _debugDoingBuild = true;
        return true;
      }());
      built = build().toList();
      assert(() {
        _debugDoingBuild = false;
        return true;
      }());
    } catch (e, st) {
      _debugDoingBuild = false;
      // TODO: implement actual error widget
      built = [
        DomWidget(
          tag: 'div',
          child: Text("Error on building widget: $e"),
        ),
      ];
      print('Error: $e $st');
    } finally {
      _dirty = false;
      assert(_debugSetAllowIgnoredCallsToMarkNeedsBuild(false));
    }

    _children = updateChildren(_children ?? [], built, forgottenChildren: _forgottenChildren);
    _forgottenChildren.clear();
  }

  /// Subclasses should override this function to actually call the appropriate
  /// `build` function (e.g., [StatelessWidget.build] or [State.build]) for
  /// their widget.
  @protected
  Iterable<Widget> build();

  @override
  void visitChildren(ElementVisitor visitor) {
    for (var child in _children ?? []) {
      if (!_forgottenChildren.contains(child)) {
        visitor(child);
      }
    }
  }

  @override
  void forgetChild(Element child) {
    assert(_children != null);
    assert(_children!.contains(child));
    assert(!_forgottenChildren.contains(child));
    _forgottenChildren.add(child);
    super.forgetChild(child);
  }
}

/// An [Element] that uses a [StatelessWidget] as its configuration.
class StatelessElement extends BuildableElement {
  /// Creates an element that uses the given widget as its configuration.
  StatelessElement(StatelessWidget super.widget);

  @override
  StatelessWidget get widget => super.widget as StatelessWidget;

  Future? _asyncFirstBuild;

  @override
  void didMount() {
    // We check if the widget uses on of the mixins that support async initialization,
    // which will delay the call to [build()] until resolved during the first build.

    if (owner.isFirstBuild && !binding.isClient && widget is OnFirstBuild) {
      var result = (widget as OnFirstBuild).onFirstBuild(this);
      if (result is Future) {
        _asyncFirstBuild = result;
      }
    }

    super.didMount();
  }

  @override
  bool shouldRebuild(covariant Widget newWidget) {
    return widget.shouldRebuild(newWidget);
  }

  @override
  Iterable<Widget> build() => widget.build(this);

  @override
  FutureOr<void> performRebuild() {
    if (owner.isFirstBuild && _asyncFirstBuild != null) {
      return _asyncFirstBuild!.then((_) {
        super.performRebuild();
      });
    }
    super.performRebuild();
  }
}

/// An [Element] that uses a [StatefulWidget] as its configuration.
class StatefulElement extends BuildableElement {
  /// Creates an element that uses the given widget as its configuration.
  StatefulElement(StatefulWidget widget)
      : _state = widget.createState(),
        super(widget) {
    assert(() {
      if (!state._debugTypesAreRight(widget)) {
        throw 'StatefulWidget.createState must return a subtype of State<${widget.runtimeType}>\n\n'
            'The createState function for ${widget.runtimeType} returned a state '
            'of type ${state.runtimeType}, which is not a subtype of '
            'State<${widget.runtimeType}>, violating the contract for createState.';
      }
      return true;
    }());
    assert(state._element == null);
    state._element = this;
    assert(
      state._widget == null,
      'The createState function for $widget returned an old or invalid state '
      'instance: ${state._widget}, which is not null, violating the contract '
      'for createState.',
    );
    state._widget = widget;
    assert(state._debugLifecycleState == _StateLifecycle.created);
  }

  @override
  Iterable<Widget> build() => state.build(this);

  /// The [State] instance associated with this location in the tree.
  ///
  /// There is a one-to-one relationship between [State] objects and the
  /// [StatefulElement] objects that hold them. The [State] objects are created
  /// by [StatefulElement] in [mount].
  State? _state;
  State get state => _state!;

  Future? _asyncInitState;

  @override
  void didMount() {
    assert(state._debugLifecycleState == _StateLifecycle.created);

    // We check if state uses on of the mixins that support async initialization,
    // which will delay the call to [_initState()] until resolved during the first build.

    if (owner.isFirstBuild && state is PreloadStateMixin && !binding.isClient) {
      _asyncInitState = (state as PreloadStateMixin).preloadState().then((_) => _initState());
    } else {
      _initState();
    }

    super.didMount();
  }

  void _initState() {
    assert(state._debugLifecycleState == _StateLifecycle.created);
    try {
      _debugSetAllowIgnoredCallsToMarkNeedsBuild(true);
      Object? result = state.initState() as dynamic;
      assert(
        result is! Future,
        '${state.runtimeType}.initState() returned a Future.\n\n'
        'Rather than awaiting on asynchronous work directly inside of initState, '
        'call a separate method to do this work without awaiting it.\n\n'
        'If you need to do some async work before the first render, use PreloadStateMixin on State.',
      );
    } finally {
      _debugSetAllowIgnoredCallsToMarkNeedsBuild(false);
    }
    assert(() {
      state._debugLifecycleState = _StateLifecycle.initialized;
      return true;
    }());
    state.didChangeDependencies();
    assert(() {
      state._debugLifecycleState = _StateLifecycle.ready;
      return true;
    }());
  }

  @override
  FutureOr<void> performRebuild() {
    if (owner.isFirstBuild && _asyncInitState != null) {
      return _asyncInitState!.then((_) {
        if (_didChangeDependencies) {
          state.didChangeDependencies();
          _didChangeDependencies = false;
        }
        super.performRebuild();
      });
    }
    if (_didChangeDependencies) {
      state.didChangeDependencies();
      _didChangeDependencies = false;
    }
    super.performRebuild();
  }

  @override
  bool shouldRebuild(covariant StatefulWidget newWidget) {
    return state.shouldRebuild(newWidget);
  }

  @override
  void update(StatefulWidget newWidget) {
    super.update(newWidget);
    assert(widget == newWidget);
    state._widget = newWidget;
  }

  @override
  void didUpdate(StatefulWidget oldWidget) {
    try {
      _debugSetAllowIgnoredCallsToMarkNeedsBuild(true);
      // TODO: check for returned future
      state.didUpdateWidget(oldWidget);
    } finally {
      _debugSetAllowIgnoredCallsToMarkNeedsBuild(false);
    }
    super.didUpdate(oldWidget);
  }

  @override
  void activate() {
    super.activate();
    state.activate();
    assert(_lifecycleState == _ElementLifecycle.active);
    markNeedsBuild();
  }

  @override
  void deactivate() {
    state.deactivate();
    super.deactivate();
  }

  @override
  void unmount() {
    super.unmount();
    state.dispose();
    assert(state._debugLifecycleState == _StateLifecycle.defunct);
    state._element = null;
    _state = null;
  }

  /// This controls whether we should call [State.didChangeDependencies] from
  /// the start of [build], to avoid calls when the [State] will not get built.
  /// This can happen when the widget has dropped out of the tree, but depends
  /// on an [InheritedWidget] that is still in the tree.
  ///
  /// It is set initially to false, since [_firstBuild] makes the initial call
  /// on the [state]. When it is true, [build] will call
  /// `state.didChangeDependencies` and then sets it to false. Subsequent calls
  /// to [didChangeDependencies] set it to true.
  bool _didChangeDependencies = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _didChangeDependencies = true;
  }
}

/// An [Element] that has multiple children based on a proxy list.
class ProxyElement extends Element {
  /// Creates an element that uses the given widget as its configuration.
  ProxyElement(ProxyWidget super.widget);

  /// The current list of children of this element.
  ///
  /// This list is filtered to hide elements that have been forgotten (using
  /// [forgetChild]).
  @protected
  Iterable<Element> get children => _children!.where((Element child) => !_forgottenChildren.contains(child));

  List<Element>? _children;
  // We keep a set of forgotten children to avoid O(n^2) work walking _children
  // repeatedly to remove children.
  final Set<Element> _forgottenChildren = HashSet<Element>();

  @override
  bool get debugDoingBuild => false;

  @override
  void mount(Element? parent, Element? prevSibling) {
    super.mount(parent, prevSibling);
    assert(_children == null);
  }

  @override
  void didMount() {
    rebuild();
    super.didMount();
  }

  @override
  bool shouldRebuild(ProxyWidget newWidget) {
    return true;
  }

  @override
  void performRebuild() {
    _dirty = false;

    var comp = (widget as ProxyWidget);
    var newWidgets = comp.children ?? [if (comp.child != null) comp.child!];

    _children = updateChildren(_children ?? [], newWidgets, forgottenChildren: _forgottenChildren);
    _forgottenChildren.clear();
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    for (var child in _children ?? []) {
      if (!_forgottenChildren.contains(child)) {
        visitor(child);
      }
    }
  }

  @override
  void forgetChild(Element child) {
    assert(_children != null);
    assert(_children!.contains(child));
    assert(!_forgottenChildren.contains(child));
    _forgottenChildren.add(child);
    super.forgetChild(child);
  }
}

/// An [Element] that uses an [InheritedWidget] as its configuration.
class InheritedElement extends ProxyElement {
  /// Creates an element that uses the given widget as its configuration.
  InheritedElement(InheritedWidget super.widget);

  @override
  InheritedWidget get widget => super.widget as InheritedWidget;

  final Map<Element, Object?> _dependents = HashMap<Element, Object?>();

  @override
  void _updateInheritance() {
    assert(_lifecycleState == _ElementLifecycle.active);
    final Map<Type, InheritedElement>? incomingElements = _parent?._inheritedElements;
    if (incomingElements != null) {
      _inheritedElements = HashMap<Type, InheritedElement>.from(incomingElements);
    } else {
      _inheritedElements = HashMap<Type, InheritedElement>();
    }
    _inheritedElements![widget.runtimeType] = this;
  }

  /// Returns the dependencies value recorded for [dependent]
  /// with [setDependencies].
  ///
  /// Each dependent element is mapped to a single object value
  /// which represents how the element depends on this
  /// [InheritedElement]. This value is null by default and by default
  /// dependent elements are rebuilt unconditionally.
  ///
  /// Subclasses can manage these values with [updateDependencies]
  /// so that they can selectively rebuild dependents in
  /// [notifyDependent].
  ///
  /// This method is typically only called in overrides of [updateDependencies].
  ///
  /// See also:
  ///
  ///  * [updateDependencies], which is called each time a dependency is
  ///    created with [dependOnInheritedWidgetOfExactType].
  ///  * [setDependencies], which sets dependencies value for a dependent
  ///    element.
  ///  * [notifyDependent], which can be overridden to use a dependent's
  ///    dependencies value to decide if the dependent needs to be rebuilt.
  @protected
  Object? getDependencies(Element dependent) {
    return _dependents[dependent];
  }

  /// Sets the value returned by [getDependencies] value for [dependent].
  ///
  /// Each dependent element is mapped to a single object value
  /// which represents how the element depends on this
  /// [InheritedElement]. The [updateDependencies] method sets this value to
  /// null by default so that dependent elements are rebuilt unconditionally.
  ///
  /// Subclasses can manage these values with [updateDependencies]
  /// so that they can selectively rebuild dependents in [notifyDependent].
  ///
  /// This method is typically only called in overrides of [updateDependencies].
  ///
  /// See also:
  ///
  ///  * [updateDependencies], which is called each time a dependency is
  ///    created with [dependOnInheritedWidgetOfExactType].
  ///  * [getDependencies], which returns the current value for a dependent
  ///    element.
  ///  * [notifyDependent], which can be overridden to use a dependent's
  ///    [getDependencies] value to decide if the dependent needs to be rebuilt.
  @protected
  void setDependencies(Element dependent, Object? value) {
    _dependents[dependent] = value;
  }

  /// Called by [dependOnInheritedWidgetOfExactType] when a new [dependent] is added.
  ///
  /// Each dependent element can be mapped to a single object value with
  /// [setDependencies]. This method can lookup the existing dependencies with
  /// [getDependencies].
  ///
  /// By default this method sets the inherited dependencies for [dependent]
  /// to null. This only serves to record an unconditional dependency on
  /// [dependent].
  ///
  /// Subclasses can manage their own dependencies values so that they
  /// can selectively rebuild dependents in [notifyDependent].
  ///
  /// See also:
  ///
  ///  * [getDependencies], which returns the current value for a dependent
  ///    element.
  ///  * [setDependencies], which sets the value for a dependent element.
  ///  * [notifyDependent], which can be overridden to use a dependent's
  ///    dependencies value to decide if the dependent needs to be rebuilt.
  @protected
  void updateDependencies(Element dependent, Object? aspect) {
    setDependencies(dependent, null);
  }

  @override
  void didUpdate(covariant InheritedWidget oldWidget) {
    if (widget.updateShouldNotify(oldWidget)) {
      notifyClients(oldWidget);
    }
    super.didUpdate(oldWidget);
  }

  /// Notifies all dependent elements that this inherited widget has changed, by
  /// calling [Element.didChangeDependencies].
  ///
  /// This method must only be called during the build phase. Usually this
  /// method is called automatically when an inherited widget is rebuilt, e.g.
  /// as a result of calling [State.setState] above the inherited widget.
  ///
  /// Notify other objects that the widget associated with this element has
  /// changed.
  ///
  /// Called during [didUpdate] after changing the widget
  /// associated with this element but before rebuilding this element.
  @protected
  void notifyClients(covariant InheritedWidget oldWidget) {
    assert(_debugCheckOwnerBuildTargetExists('notifyClients'));
    for (final Element dependent in _dependents.keys) {
      notifyDependent(oldWidget, dependent);
    }
  }

  /// Called by [notifyClients] for each dependent.
  ///
  /// Calls `dependent.didChangeDependencies()` by default.
  ///
  /// Subclasses can override this method to selectively call
  /// [didChangeDependencies] based on the value of [getDependencies].
  ///
  /// See also:
  ///
  ///  * [updateDependencies], which is called each time a dependency is
  ///    created with [dependOnInheritedWidgetOfExactType].
  ///  * [getDependencies], which returns the current value for a dependent
  ///    element.
  ///  * [setDependencies], which sets the value for a dependent element.
  @protected
  void notifyDependent(covariant InheritedWidget oldWidget, Element dependent) {
    dependent.didChangeDependencies();
  }

  /// Called by [Element] after being rebuild.
  /// This ensures that dependencies can react to elements that dynamically
  /// do or don't depend to them.
  @protected
  @mustCallSuper
  void didRebuildDependent(Element dependent) {
    assert(_dependents.containsKey(dependent));
  }

  @protected
  @mustCallSuper
  void deactivateDependent(Element dependent) {
    assert(_dependents.containsKey(dependent));
    _dependents.remove(dependent);
  }
}

mixin RenderObjectElement on Element {
  RenderObject createRenderObject() {
    var renderObject = _parentRenderObjectElement!.renderObject.createChildRenderObject();
    assert(renderObject.parent == _parentRenderObjectElement!.renderObject);
    return renderObject;
  }

  void updateRenderObject();

  RenderObject get renderObject => _renderObject!;
  RenderObject? _renderObject;

  @override
  void didMount() {
    if (_renderObject == null) {
      _renderObject = createRenderObject();
      updateRenderObject();
    }
    super.didMount();
  }

  bool _dirtyRender = false;

  bool shouldRerender(covariant Widget newWidget) {
    return true;
  }

  @override
  void update(Widget newWidget) {
    if (shouldRerender(newWidget)) {
      _dirtyRender = true;
    }
    super.update(newWidget);
  }

  @override
  void didUpdate(Widget oldWidget) {
    if (_dirtyRender) {
      _dirtyRender = false;
      updateRenderObject();
    }
    super.didUpdate(oldWidget);
  }

  @override
  void attachRenderObject() {
    var parent = _parentRenderObjectElement?.renderObject;
    if (parent != null) {
      Element? prevElem = _prevAncestorSibling;
      while (prevElem != null && prevElem._lastRenderObjectElement == null) {
        prevElem = prevElem._prevAncestorSibling;
      }
      var after = prevElem?._lastRenderObjectElement;
      parent.attach(renderObject, after: after?.renderObject);
      assert(renderObject.parent == parent);
    }
  }

  @override
  void detachRenderObject() {
    var parent = _parentRenderObjectElement?.renderObject;
    if (parent != null) {
      parent.remove(renderObject);
      assert(renderObject.parent == null);
    }
  }

  @override
  void _didUpdateSlot() {
    super._didUpdateSlot();
    attachRenderObject();
  }

  @override
  RenderObjectElement get _lastRenderObjectElement => this;
}

abstract class BuildableRenderObjectElement = BuildableElement with RenderObjectElement;
abstract class ProxyRenderObjectElement = ProxyElement with RenderObjectElement;
abstract class LeafRenderObjectElement = LeafElement with RenderObjectElement;
