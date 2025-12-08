part of 'framework.dart';

/// A component that does not require mutable state.
///
/// A stateless component is a component that describes part of the user interface by
/// building a constellation of other components that describe the user interface
/// more concretely. The building process continues recursively until the
/// description of the user interface is fully concrete (e.g., consists
/// entirely of [DomComponent]s, which describe concrete DOM elements).
///
/// Stateless component are useful when the part of the user interface you are
/// describing does not depend on anything other than the configuration
/// information in the object itself and the [BuildContext] in which the component
/// is inflated. For compositions that can change dynamically, e.g. due to
/// having an internal clock-driven state, or depending on some system state,
/// consider using [StatefulComponent].
///
/// ## Performance considerations
///
/// The [build] method of a stateless component is typically only called in three
/// situations: the first time the component is inserted in the tree, when the
/// component's parent changes its configuration, and when an [InheritedComponent] it
/// depends on changes.
///
/// If a component's parent will regularly change the component's configuration, or if
/// it depends on inherited components that frequently change, then it is important
/// to optimize the performance of the [build] method to maintain a fluid
/// rendering performance.
///
/// There are several techniques one can use to minimize the impact of
/// rebuilding a stateless component:
///
///  * Minimize the number of nodes transitively created by the build method and
///    any components it creates.
///
///  * Use `const` components where possible, and provide a `const` constructor for
///    the component so that users of the component can also do so.
///
///  * When trying to create a reusable piece of UI, prefer using a component
///    rather than a helper method. For example, if there was a function used to
///    build a component, a [State.setState] call would require Flutter to entirely
///    rebuild the returned wrapping component. If a [Component] was used instead,
///    we would be able to efficiently re-render only those parts that
///    really need to be updated. Even better, if the created component is `const`,
///    we would short-circuit most of the rebuild work.
///
///  * Consider refactoring the stateless component into a stateful component so that
///    it can use some of the techniques described at [StatefulComponent], such as
///    caching common parts of subtrees and using [GlobalKey]s when changing the
///    tree structure.
///
///  * If the component is likely to get rebuilt frequently due to the use of
///    [InheritedComponent]s, consider refactoring the stateless component into
///    multiple components, with the parts of the tree that change being pushed to
///    the leaves. For example instead of building a tree with four components, the
///    inner-most component depending on some [InheritedComponent], consider factoring out the
///    part of the build function that builds the inner-most component into its own
///    component, so that only the inner-most component needs to be rebuilt when the
///    inherited component changes.
///
/// By convention, component constructors only use named arguments. Also by
/// convention, the first argument is [key], and the last argument is `child`,
/// `children`, or the equivalent.
///
/// See also:
///
///  * [StatefulComponent] and [State], for components that can build differently
///    several times over their lifetime.
///  * [InheritedComponent], for components that introduce ambient state that can
///    be read by descendant components.
abstract class StatelessComponent extends Component {
  /// Initializes [key] for subclasses.
  const StatelessComponent({super.key});

  /// Creates a [StatelessElement] to manage this component's location in the tree.
  ///
  /// It is uncommon for subclasses to override this method.
  @override
  Element createElement() => StatelessElement(this);

  /// Describes the part of the user interface represented by this component.
  ///
  /// The framework calls this method when this component is inserted into the tree
  /// in a given [BuildContext] and when the dependencies of this component change
  /// (e.g., an [InheritedComponent] referenced by this component changes). This
  /// method can potentially be called in every frame and should not have any side
  /// effects beyond building a component.
  ///
  /// The framework replaces the subtree below this component with the component
  /// returned by this method, either by updating the existing subtree or by
  /// removing the subtree and inflating a new subtree, depending on whether the
  /// component returned by this method can update the root of the existing
  /// subtree, as determined by calling [Component.canUpdate].
  ///
  /// Typically implementations return a newly created constellation of components
  /// that are configured with information from this component's constructor and
  /// from the given [BuildContext].
  ///
  /// The given [BuildContext] contains information about the location in the
  /// tree at which this component is being built. For example, the context
  /// provides the set of inherited components for this location in the tree. A
  /// given component might be built with multiple different [BuildContext]
  /// arguments over time if the component is moved around the tree or if the
  /// component is inserted into the tree in multiple places at once.
  ///
  /// The implementation of this method must only depend on:
  ///
  /// * the fields of the component, which themselves must not change over time,
  ///   and
  /// * any ambient state obtained from the `context` using
  ///   [BuildContext.dependOnInheritedComponentOfExactType].
  ///
  /// If a component's [build] method is to depend on anything else, use a
  /// [StatefulComponent] instead.
  ///
  /// See also:
  ///
  ///  * [StatelessComponent], which contains the discussion on performance considerations.
  @protected
  Component build(BuildContext context);

  /// Implement this method to determine whether a rebuild can be skipped.
  ///
  /// This method will be called whenever the component is about to update. If returned false, the subsequent rebuild will be skipped.
  ///
  /// This method exists only as a performance optimization and gives no guarantees about when the component is rebuilt.
  /// Keep the implementation as efficient as possible and avoid deep (recursive) comparisons or performance heavy checks, as this might
  /// have an opposite effect on performance.
  bool shouldRebuild(covariant Component newComponent) {
    return true;
  }
}

/// Mixin on [StatelessComponent] that performs some async task on the first build
mixin OnFirstBuild on StatelessComponent {
  FutureOr<void> onFirstBuild(BuildContext context);
}

/// An [Element] that uses a [StatelessComponent] as its configuration.
class StatelessElement extends BuildableElement {
  /// Creates an element that uses the given component as its configuration.
  StatelessElement(StatelessComponent super.component);

  @override
  StatelessComponent get component => super.component as StatelessComponent;

  Future<void>? _asyncFirstBuild;

  @override
  void didMount() {
    // We check if the component uses on of the mixins that support async initialization,
    // which will delay the call to [build()] until resolved during the first build.

    if (owner.isFirstBuild && !binding.isClient && component is OnFirstBuild) {
      final result = (component as OnFirstBuild).onFirstBuild(this);
      if (result is Future<void>) {
        _asyncFirstBuild = result;
      }
    }

    super.didMount();
  }

  @override
  bool shouldRebuild(covariant Component newComponent) {
    return component.shouldRebuild(newComponent);
  }

  @override
  Component build() => component.build(this);

  @override
  FutureOr<void> performRebuild() {
    if (owner.isFirstBuild && _asyncFirstBuild != null) {
      return _asyncFirstBuild!
          .then((_) {
            super.performRebuild();
          })
          .onError<Object>((e, st) {
            failRebuild(e, st);
          });
    }
    super.performRebuild();
  }
}
