part of 'framework.dart';

/// A component that has mutable state.
///
/// State is information that (1) can be read synchronously when the component is
/// built and (2) might change during the lifetime of the component. It is the
/// responsibility of the component implementer to ensure that the [State] is
/// promptly notified when such state changes, using [State.setState].
///
/// A stateful component is a component that describes part of the user interface by
/// building a constellation of other components that describe the user interface
/// more concretely. The building process continues recursively until the
/// description of the user interface is fully concrete (e.g., consists
/// entirely of [DomComponent]s, which describe concrete DOM elements).
///
/// Stateful components are useful when the part of the user interface you are
/// describing can change dynamically, e.g. due to having an internal
/// clock-driven state, or depending on some system state. For compositions that
/// depend only on the configuration information in the object itself and the
/// [BuildContext] in which the component is inflated, consider using
/// [StatelessComponent].
///
/// [StatefulComponent] instances themselves are immutable and store their mutable
/// state either in separate [State] objects that are created by the
/// [createState] method, or in objects to which that [State] subscribes, for
/// example [Stream] or [ChangeNotifier] objects, to which references are stored
/// in final fields on the [StatefulComponent] itself.
///
/// The framework calls [createState] whenever it inflates a
/// [StatefulComponent], which means that multiple [State] objects might be
/// associated with the same [StatefulComponent] if that component has been inserted
/// into the tree in multiple places. Similarly, if a [StatefulComponent] is
/// removed from the tree and later inserted in to the tree again, the framework
/// will call [createState] again to create a fresh [State] object, simplifying
/// the lifecycle of [State] objects.
///
/// A [StatefulComponent] keeps the same [State] object when moving from one
/// location in the tree to another if its creator used a [GlobalKey] for its
/// [key]. Because a component with a [GlobalKey] can be used in at most one
/// location in the tree, a component that uses a [GlobalKey] has at most one
/// associated element. The framework takes advantage of this property when
/// moving a component with a global key from one location in the tree to another
/// by grafting the (unique) subtree associated with that component from the old
/// location to the new location (instead of recreating the subtree at the new
/// location). The [State] objects associated with [StatefulComponent] are grafted
/// along with the rest of the subtree, which means the [State] object is reused
/// (instead of being recreated) in the new location. However, in order to be
/// eligible for grafting, the component must be inserted into the new location in
/// the same build phase in which it was removed from the old location.
///
/// ## Performance considerations
///
/// There are two primary categories of [StatefulComponent]s.
///
/// The first is one which allocates resources in [State.initState] and disposes
/// of them in [State.dispose], but which does not depend on [InheritedComponent]s
/// or call [State.setState]. Such components are commonly used at the root of an
/// application or page, and communicate with subcomponents via [ChangeNotifier]s,
/// [Stream]s, or other such objects. Stateful components following such a pattern
/// are relatively cheap (in terms of CPU and GPU cycles), because they are
/// built once then never update. They can, therefore, have somewhat complicated
/// and deep build methods.
///
/// The second category is components that use [State.setState] or depend on
/// [InheritedComponent]s. These will typically rebuild many times during the
/// application's lifetime, and it is therefore important to minimize the impact
/// of rebuilding such a component. (They may also use [State.initState] or
/// [State.didChangeDependencies] and allocate resources, but the important part
/// is that they rebuild.)
///
/// There are several techniques one can use to minimize the impact of
/// rebuilding a stateful component:
///
///  * Push the state to the leaves. For example, if your page has a ticking
///    clock, rather than putting the state at the top of the page and
///    rebuilding the entire page each time the clock ticks, create a dedicated
///    clock component that only updates itself.
///
///  * Minimize the number of nodes transitively created by the build method and
///    any components it creates. Ideally, a stateful component would only create a
///    single component, and that component would be a [DomComponent].
///    (Of course this isn't always practical, but the closer a component gets to
///    this ideal, the more efficient it will be.)
///
///  * If a subtree does not change, cache the component that represents that
///    subtree and re-use it each time it can be used. It is massively more
///    efficient for a component to be re-used than for a new (but
///    identically-configured) component to be created. Factoring out the stateful
///    part into a component that takes a child argument is a common way of doing
///    this. Another caching strategy consists of assigning a component to a
///    `final` state variable which can be used in the build method.
///
///  * Use `const` components where possible. (This is equivalent to caching a
///    component and re-using it.)
///
///  * When trying to create a reusable piece of UI, prefer using a component
///    rather than a helper method. For example, if there was a function used to
///    build a component, a [State.setState] call would require Flutter to entirely
///    rebuild the returned wrapping component. If a [Component] was used instead,
///    Flutter would be able to efficiently re-render only those parts that
///    really need to be updated. Even better, if the created component is `const`,
///    Flutter would short-circuit most of the rebuild work.
///
///  * Avoid changing the depth of any created subtrees or changing the type of
///    any components in the subtree. For example, rather than returning either the
///    child or the child wrapped in an `IgnorePointer`, always wrap the child
///    component in an `IgnorePointer` and control the `IgnorePointer.ignoring`
///    property. This is because changing the depth of the subtree requires
///    rebuilding, laying out, and painting the entire subtree, whereas just
///    changing the property will require the least possible change to the
///    render tree (in the case of `IgnorePointer`, for example, no layout or
///    repaint is necessary at all).
///
///  * If the depth must be changed for some reason, consider wrapping the
///    common parts of the subtrees in components that have a [GlobalKey] that
///    remains consistent for the life of the stateful component.
///
/// By convention, component constructors only use named arguments. Also by
/// convention, the first argument is [key], and the last argument is `child`,
/// `children`, or the equivalent.
///
/// See also:
///
///  * [State], where the logic behind a [StatefulComponent] is hosted.
///  * [StatelessComponent], for components that always build the same way given a
///    particular configuration and ambient state.
///  * [InheritedComponent], for components that introduce ambient state that can
///    be read by descendant components.
abstract class StatefulComponent extends Component {
  /// Initializes [key] for subclasses.
  const StatefulComponent({super.key});

  /// Creates a [StatefulElement] to manage this component's location in the tree.
  ///
  /// It is uncommon for subclasses to override this method.
  @override
  Element createElement() => StatefulElement(this);

  /// Creates the mutable state for this component at a given location in the tree.
  ///
  /// Subclasses should override this method to return a newly created
  /// instance of their associated [State] subclass:
  ///
  /// ```dart
  /// @override
  /// State<MyComponent> createState() => _MyComponentState();
  /// ```
  ///
  /// The framework can call this method multiple times over the lifetime of
  /// a [StatefulComponent]. For example, if the component is inserted into the tree
  /// in multiple locations, the framework will create a separate [State] object
  /// for each location. Similarly, if the component is removed from the tree and
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

/// The logic and internal state for a [StatefulComponent].
///
/// State is information that (1) can be read synchronously when the component is
/// built and (2) might change during the lifetime of the component. It is the
/// responsibility of the component implementer to ensure that the [State] is
/// promptly notified when such state changes, using [State.setState].
///
/// [State] objects are created by the framework by calling the
/// [StatefulComponent.createState] method when inflating a [StatefulComponent] to
/// insert it into the tree. Because a given [StatefulComponent] instance can be
/// inflated multiple times (e.g., the component is incorporated into the tree in
/// multiple places at once), there might be more than one [State] object
/// associated with a given [StatefulComponent] instance. Similarly, if a
/// [StatefulComponent] is removed from the tree and later inserted in to the tree
/// again, the framework will call [StatefulComponent.createState] again to create
/// a fresh [State] object, simplifying the lifecycle of [State] objects.
///
/// [State] objects have the following lifecycle:
///
///  * The framework creates a [State] object by calling
///    [StatefulComponent.createState].
///  * The newly created [State] object is associated with a [BuildContext].
///    This association is permanent: the [State] object will never change its
///    [BuildContext]. However, the [BuildContext] itself can be moved around
///    the tree along with its subtree. At this point, the [State] object is
///    considered [mounted].
///  * The framework calls [initState]. Subclasses of [State] should override
///    [initState] to perform one-time initialization that depends on the
///    [BuildContext] or the component, which are available as the [context] and
///    [component] properties, respectively, when the [initState] method is
///    called.
///  * The framework calls [didChangeDependencies]. Subclasses of [State] should
///    override [didChangeDependencies] to perform initialization involving
///    [InheritedComponent]s. If [BuildContext.dependOnInheritedComponentOfExactType] is
///    called, the [didChangeDependencies] method will be called again if the
///    inherited components subsequently change or if the component moves in the tree.
///  * At this point, the [State] object is fully initialized and the framework
///    might call its [build] method any number of times to obtain a
///    description of the user interface for this subtree. [State] objects can
///    spontaneously request to rebuild their subtree by callings their
///    [setState] method, which indicates that some of their internal state
///    has changed in a way that might impact the user interface in this
///    subtree.
///  * During this time, a parent component might rebuild and request that this
///    location in the tree update to display a new component with the same
///    [runtimeType] and [Component.key]. When this happens, the framework will
///    update the [component] property to refer to the new component and then call the
///    [didUpdateComponent] method with the previous component as an argument. [State]
///    objects should override [didUpdateComponent] to respond to changes in their
///    associated component (e.g., to start implicit animations). The framework
///    always calls [build] after calling [didUpdateComponent], which means any
///    calls to [setState] in [didUpdateComponent] are redundant.
///  * If the subtree containing the [State] object is removed from the tree
///    (e.g., because the parent built a component with a different [runtimeType]
///    or [Component.key]), the framework calls the [deactivate] method. Subclasses
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
///  * [StatefulComponent], where the current configuration of a [State] is hosted,
///    and whose documentation has sample code for [State].
///  * [StatelessComponent], for components that always build the same way given a
///    particular configuration and ambient state.
///  * [InheritedComponent], for components that introduce ambient state that can
///    be read by descendant components.
///  * [Component], for an overview of components in general.
@optionalTypeArgs
abstract class State<T extends StatefulComponent> {
  /// The current configuration.
  ///
  /// A [State] object's configuration is the corresponding [StatefulComponent]
  /// instance. This property is initialized by the framework before calling
  /// [initState]. If the parent updates this location in the tree to a new
  /// component with the same [runtimeType] and [Component.key] as the current
  /// configuration, the framework will update this property to refer to the new
  /// component and then call [didUpdateComponent], passing the old configuration as
  /// an argument.
  T get component => _component!;
  T? _component;

  /// The current stage in the lifecycle for this state object.
  ///
  /// This field is used by the framework when asserts are enabled to verify
  /// that [State] objects move through their lifecycle in an orderly fashion.
  _StateLifecycle _debugLifecycleState = _StateLifecycle.created;

  /// Verifies that the [State] that was created is one that expects to be
  /// created for that particular [Component].
  bool _debugTypesAreRight(Component component) => component is T;

  /// The location in the tree where this component builds.
  ///
  /// The framework associates [State] objects with a [BuildContext] after
  /// creating them with [StatefulComponent.createState] and before calling
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
  /// or on the component used to configure this object (i.e., [component]).
  ///
  /// If a [State]'s [build] method depends on an object that can itself
  /// change state, for example a [ChangeNotifier] or [Stream], or some
  /// other object to which one can subscribe to receive notifications, then
  /// be sure to subscribe and unsubscribe properly in [initState],
  /// [didUpdateComponent], and [dispose]:
  ///
  ///  * In [initState], subscribe to the object.
  ///  * In [didUpdateComponent] unsubscribe from the old object and subscribe
  ///    to the new one if the updated component configuration requires
  ///    replacing the object.
  ///  * In [dispose], unsubscribe from the object.
  ///
  /// You cannot use [BuildContext.dependOnInheritedComponentOfExactType] from this
  /// method. However, [didChangeDependencies] will be called immediately
  /// following this method, and [BuildContext.dependOnInheritedComponentOfExactType] can
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
  /// This method will be called whenever the component is about to update. If returned false, the subsequent rebuild will be skipped.
  ///
  /// This method exists only as a performance optimization and gives no guarantees about when the component is rebuilt.
  /// Keep the implementation as efficient as possible and avoid deep (recursive) comparisons or performance heavy checks, as this might
  /// have an opposite effect on performance.
  bool shouldRebuild(covariant T newComponent) {
    return true;
  }

  /// Called whenever the component configuration changes.
  ///
  /// If the parent component rebuilds and request that this location in the tree
  /// update to display a new component with the same [runtimeType] and
  /// [Component.key], the framework will update the [component] property of this
  /// [State] object to refer to the new component and then call this method
  /// with the previous component as an argument.
  ///
  /// Override this method to respond when the [component] changes (e.g., to start
  /// implicit animations).
  ///
  /// The framework always calls [build] after calling [didUpdateComponent], which
  /// means any calls to [setState] in [didUpdateComponent] are redundant.
  ///
  /// Implementations of this method should start with a call to the inherited
  /// method, as in `super.didUpdateComponent(oldComponent)`
  @mustCallSuper
  @protected
  void didUpdateComponent(covariant T oldComponent) {}

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
    final Object? result = fn() as dynamic;
    assert(
      result is! Future,
      'setState() callback argument returned a Future.\n\n'
      'Instead of performing asynchronous work inside a call to setState(), first '
      'execute the work (without updating the component state), and then synchronously '
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
  ///  * [dispose], which is called after [deactivate] if the component is removed
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

  /// Describes the part of the user interface represented by this component.
  ///
  /// The framework calls this method in a number of different situations. For
  /// example:
  ///
  ///  * After calling [initState].
  ///  * After calling [didUpdateComponent].
  ///  * After receiving a call to [setState].
  ///  * After a dependency of this [State] object changes (e.g., an
  ///    [InheritedComponent] referenced by the previous [build] changes).
  ///  * After calling [deactivate] and then reinserting the [State] object into
  ///    the tree at another location.
  ///
  /// This method can potentially be called in every frame and should not have
  /// any side effects beyond building a component.
  ///
  /// The framework replaces the subtree below this component with the component
  /// returned by this method, either by updating the existing subtree or by
  /// removing the subtree and inflating a new subtree, depending on whether the
  /// component returned by this method can update the root of the existing
  /// subtree, as determined by calling [Component.canUpdate].
  ///
  /// Typically implementations return a newly created constellation of components
  /// that are configured with information from this component's constructor, the
  /// given [BuildContext], and the internal state of this [State] object.
  ///
  /// The given [BuildContext] contains information about the location in the
  /// tree at which this component is being built. For example, the context
  /// provides the set of inherited components for this location in the tree. The
  /// [BuildContext] argument is always the same as the [context] property of
  /// this [State] object and will remain the same for the lifetime of this
  /// object. The [BuildContext] argument is provided redundantly here so that
  /// this method matches the signature for a [ComponentBuilder].
  ///
  /// See also:
  ///
  ///  * [StatefulComponent], which contains the discussion on performance considerations.
  @protected
  Component build(BuildContext context);

  /// Called when a dependency of this [State] object changes.
  ///
  /// For example, if the previous call to [build] referenced an
  /// [InheritedComponent] that later changed, the framework would call this
  /// method to notify this object about the change.
  ///
  /// This method is also called immediately after [initState]. It is safe to
  /// call [BuildContext.dependOnInheritedComponentOfExactType] from this method.
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

/// Mixin on [State] that preloads state on the server
mixin PreloadStateMixin<T extends StatefulComponent> on State<T> {
  /// Called on the server before initState() to preload asynchronous data
  @protected
  Future<void> preloadState();
}

/// An [Element] that uses a [StatefulComponent] as its configuration.
class StatefulElement extends BuildableElement {
  /// Creates an element that uses the given component as its configuration.
  StatefulElement(StatefulComponent component) : _state = component.createState(), super(component) {
    assert(() {
      if (!state._debugTypesAreRight(component)) {
        throw 'StatefulComponent.createState must return a subtype of State<${component.runtimeType}>\n\n'
            'The createState function for ${component.runtimeType} returned a state '
            'of type ${state.runtimeType}, which is not a subtype of '
            'State<${component.runtimeType}>, violating the contract for createState.';
      }
      return true;
    }());
    assert(state._element == null);
    state._element = this;
    assert(
      state._component == null,
      'The createState function for $component returned an old or invalid state '
      'instance: ${state._component}, which is not null, violating the contract '
      'for createState.',
    );
    state._component = component;
    assert(state._debugLifecycleState == _StateLifecycle.created);
  }

  @override
  Component build() => state.build(this);

  /// The [State] instance associated with this location in the tree.
  ///
  /// There is a one-to-one relationship between [State] objects and the
  /// [StatefulElement] objects that hold them. The [State] objects are created
  /// by [StatefulElement] in [mount].
  State<StatefulComponent>? _state;
  State get state => _state!;

  Future<void>? _asyncInitState;

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
      final Object? result = state.initState() as dynamic;
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
      return _asyncInitState!
          .then((_) {
            if (_didChangeDependencies) {
              state.didChangeDependencies();
              _didChangeDependencies = false;
            }
            super.performRebuild();
          })
          .onError<Object>((e, st) {
            failRebuild(e, st);
          });
    }
    if (_didChangeDependencies) {
      state.didChangeDependencies();
      _didChangeDependencies = false;
    }
    super.performRebuild();
  }

  @override
  bool shouldRebuild(covariant StatefulComponent newComponent) {
    return state.shouldRebuild(newComponent);
  }

  @override
  void update(StatefulComponent newComponent) {
    super.update(newComponent);
    assert(component == newComponent);
    state._component = newComponent;
  }

  @override
  void didUpdate(StatefulComponent oldComponent) {
    try {
      _debugSetAllowIgnoredCallsToMarkNeedsBuild(true);
      // TODO: check for returned future
      state.didUpdateComponent(oldComponent);
    } finally {
      _debugSetAllowIgnoredCallsToMarkNeedsBuild(false);
    }
    super.didUpdate(oldComponent);
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
  /// This can happen when the component has dropped out of the tree, but depends
  /// on an [InheritedComponent] that is still in the tree.
  ///
  /// It is set initially to `false`, since [BuildOwner.performInitialBuild] makes
  /// the initial call on the [state]. When it is `true`,
  /// [build] will call [State.didChangeDependencies] and then sets it to `false`.
  /// Subsequent calls to [didChangeDependencies] set it to `true`.
  bool _didChangeDependencies = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _didChangeDependencies = true;
  }
}
