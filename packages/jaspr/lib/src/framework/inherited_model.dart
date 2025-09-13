part of 'framework.dart';

abstract class InheritedModel<T> extends InheritedComponent {
  /// Creates an inherited component that supports dependencies qualified by
  /// "aspects", i.e. a descendant component can indicate that it should
  /// only be rebuilt if a specific aspect of the model changes.
  const InheritedModel({super.key, required super.child});

  @override
  InheritedModelElement<T> createElement() => InheritedModelElement<T>(this);

  /// Return true if the changes between this model and [oldComponent] match any
  /// of the [dependencies].
  @protected
  bool updateShouldNotifyDependent(covariant InheritedModel<T> oldComponent, Set<T> dependencies);

  /// Returns true if this model supports the given [aspect].
  ///
  /// Returns true by default: this model supports all aspects.
  ///
  /// Subclasses may override this method to indicate that they do not support
  /// all model aspects. This is typically done when a model can be used
  /// to "shadow" some aspects of an ancestor.
  @protected
  bool isSupportedAspect(Object aspect) => true;

  // The [result] will be a list of all of context's type T ancestors concluding
  // with the one that supports the specified model [aspect].
  static void _findModels<T extends InheritedModel<Object>>(
    BuildContext context,
    Object aspect,
    List<InheritedElement> results,
  ) {
    final InheritedElement? model = context.getElementForInheritedComponentOfExactType<T>();
    if (model == null) {
      return;
    }

    results.add(model);

    assert(model.component is T);
    final T modelComponent = model.component as T;
    if (modelComponent.isSupportedAspect(aspect)) {
      return;
    }

    Element? modelParent;
    model.visitAncestorElements((Element ancestor) {
      modelParent = ancestor;
      return false;
    });
    if (modelParent == null) {
      return;
    }

    _findModels<T>(modelParent!, aspect, results);
  }

  /// Makes [context] dependent on the specified [aspect] of an [InheritedModel]
  /// of type T.
  ///
  /// When the given [aspect] of the model changes, the [context] will be
  /// rebuilt. The [updateShouldNotifyDependent] method must determine if a
  /// change in the model component corresponds to an [aspect] value.
  ///
  /// The dependencies created by this method target all [InheritedModel] ancestors
  /// of type T up to and including the first one for which [isSupportedAspect]
  /// returns true.
  ///
  /// If [aspect] is null this method is the same as
  /// `context.dependOnInheritedComponentOfExactType<T>()`.
  ///
  /// If no ancestor of type T exists, null is returned.
  static T? inheritFrom<T extends InheritedModel<Object>>(BuildContext context, {Object? aspect}) {
    if (aspect == null) {
      return context.dependOnInheritedComponentOfExactType<T>();
    }

    // Create a dependency on all of the type T ancestor models up until
    // a model is found for which isSupportedAspect(aspect) is true.
    final List<InheritedElement> models = <InheritedElement>[];
    _findModels<T>(context, aspect, models);
    if (models.isEmpty) {
      return null;
    }

    final InheritedElement lastModel = models.last;
    for (final InheritedElement model in models) {
      final T value = context.dependOnInheritedElement(model, aspect: aspect) as T;
      if (model == lastModel) {
        return value;
      }
    }

    assert(false);
    return null;
  }
}

class InheritedModelElement<T> extends InheritedElement {
  /// Creates an element that uses the given widget as its configuration.
  InheritedModelElement(InheritedModel<T> super.component);

  @override
  void updateDependencies(Element dependent, Object? aspect) {
    final Set<T>? dependencies = getDependencies(dependent) as Set<T>?;
    if (dependencies != null && dependencies.isEmpty) {
      return;
    }

    if (aspect == null) {
      setDependencies(dependent, HashSet<T>());
    } else {
      assert(aspect is T);
      setDependencies(dependent, (dependencies ?? HashSet<T>())..add(aspect as T));
    }
  }

  @override
  void notifyDependent(InheritedModel<T> oldComponent, Element dependent) {
    final Set<T>? dependencies = getDependencies(dependent) as Set<T>?;
    if (dependencies == null) {
      return;
    }
    if (dependencies.isEmpty ||
        (component as InheritedModel<T>).updateShouldNotifyDependent(oldComponent, dependencies)) {
      dependent.didChangeDependencies();
    }
  }
}
