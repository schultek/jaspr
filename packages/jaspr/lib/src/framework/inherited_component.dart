part of 'framework.dart';

/// Base class for components that efficiently propagate information down the tree.
///
/// To obtain the nearest instance of a particular type of inherited component from
/// a build context, use [BuildContext.dependOnInheritedComponentOfExactType].
///
/// Inherited components, when referenced in this way, will cause the consumer to
/// rebuild when the inherited component itself changes state.
///
/// ## Implementing the `of` method
///
/// The convention is to provide a static method `of` on the [InheritedComponent]
/// which does the call to [BuildContext.dependOnInheritedComponentOfExactType]. This
/// allows the class to define its own fallback logic in case there isn't
/// a component in scope. In the example above, the value returned will be
/// null in that case, but it could also have defaulted to a value.
///
/// Occasionally, the inherited component is an implementation detail of another
/// class, and is therefore private. The `of` method in that case is typically
/// put on the public class instead.
///
/// ## Calling the `of` method
///
/// When using the `of` method, the `context` must be a descendant of the
/// [InheritedComponent], meaning it must be "below" the [InheritedComponent] in the
/// tree.
///
/// See also:
///
///  * [StatefulComponent] and [State], for components that can build differently
///    several times over their lifetime.
///  * [StatelessComponent], for components that always build the same way given a
///    particular configuration and ambient state.
///  * [Component], for an overview of components in general.
abstract class InheritedComponent extends Component {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const InheritedComponent({required this.child, super.key});

  final Component child;

  @override
  InheritedElement createElement() => InheritedElement(this);

  /// Whether the framework should notify components that inherit from this component.
  ///
  /// When this component is rebuilt, sometimes we need to rebuild the components that
  /// inherit from this component but sometimes we do not. For example, if the data
  /// held by this component is the same as the data held by `oldComponent`, then we
  /// do not need to rebuild the components that inherited the data held by
  /// `oldComponent`.
  ///
  /// The framework distinguishes these cases by calling this function with the
  /// component that previously occupied this location in the tree as an argument.
  /// The given component is guaranteed to have the same [runtimeType] as this
  /// object.
  @protected
  bool updateShouldNotify(covariant InheritedComponent oldComponent);
}

/// An [Element] that uses an [InheritedComponent] as its configuration.
class InheritedElement extends BuildableElement {
  /// Creates an element that uses the given component as its configuration.
  InheritedElement(InheritedComponent super.component);

  @override
  InheritedComponent get component => super.component as InheritedComponent;

  @override
  Component build() => component.child;

  final Map<Element, Object?> _dependents = HashMap<Element, Object?>();

  @override
  void _updateInheritance() {
    assert(_lifecycleState == _ElementLifecycle.active);
    final incomingElements = _parent?._inheritedElements;
    final inheritedElements = _inheritedElements = incomingElements != null
        ? HashMap<Type, InheritedElement>.of(incomingElements)
        : HashMap<Type, InheritedElement>();
    inheritedElements[component.runtimeType] = this;
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
  ///    created with [dependOnInheritedComponentOfExactType].
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
  ///    created with [dependOnInheritedComponentOfExactType].
  ///  * [getDependencies], which returns the current value for a dependent
  ///    element.
  ///  * [notifyDependent], which can be overridden to use a dependent's
  ///    [getDependencies] value to decide if the dependent needs to be rebuilt.
  @protected
  void setDependencies(Element dependent, Object? value) {
    _dependents[dependent] = value;
  }

  /// Called by [dependOnInheritedComponentOfExactType] when a new [dependent] is added.
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
  void didUpdate(covariant InheritedComponent oldComponent) {
    if (component.updateShouldNotify(oldComponent)) {
      notifyClients(oldComponent);
    }
    super.didUpdate(oldComponent);
  }

  /// Notifies all dependent elements that this inherited component has changed, by
  /// calling [Element.didChangeDependencies].
  ///
  /// This method must only be called during the build phase. Usually this
  /// method is called automatically when an inherited component is rebuilt, e.g.
  /// as a result of calling [State.setState] above the inherited component.
  ///
  /// Notify other objects that the component associated with this element has
  /// changed.
  ///
  /// Called during [didUpdate] after changing the component
  /// associated with this element but before rebuilding this element.
  @protected
  void notifyClients(covariant InheritedComponent oldComponent) {
    assert(_debugCheckOwnerBuildTargetExists('notifyClients'));
    for (final Element dependent in _dependents.keys) {
      notifyDependent(oldComponent, dependent);
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
  ///    created with [dependOnInheritedComponentOfExactType].
  ///  * [getDependencies], which returns the current value for a dependent
  ///    element.
  ///  * [setDependencies], which sets the value for a dependent element.
  @protected
  void notifyDependent(covariant InheritedComponent oldComponent, Element dependent) {
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
