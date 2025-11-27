part of 'framework.dart';

/// The BuildContext supplied to a Components build() method.
sealed class BuildContext {
  /// The current configuration of the [Element] that is this [BuildContext].
  Component get component;

  /// The root component binding that manages the component tree.
  AppBinding get binding;

  /// Whether the [component] is currently updating the component or render tree.
  ///
  /// For [StatefulComponent]s and [StatelessComponent]s this flag is true while
  /// their respective build methods are executing.
  /// Other [Component] types may set this to true for conceptually similar phases
  /// of their lifecycle.
  ///
  /// When this is true, it is safe for [component] to establish a dependency to an
  /// [InheritedComponent] by calling [dependOnInheritedElement] or
  /// [dependOnInheritedComponentOfExactType].
  ///
  /// Accessing this flag in release mode is not valid.
  bool get debugDoingBuild;

  /// Registers this build context with [ancestor] such that when
  /// [ancestor]'s component changes this build context is rebuilt.
  ///
  /// Returns `ancestor.component`.
  ///
  /// This method is rarely called directly. Most applications should use
  /// [dependOnInheritedComponentOfExactType], which calls this method after finding
  /// the appropriate [InheritedElement] ancestor.
  ///
  /// All of the qualifications about when [dependOnInheritedComponentOfExactType] can
  /// be called apply to this method as well.
  InheritedComponent dependOnInheritedElement(InheritedElement ancestor, {Object? aspect});

  /// Obtains the nearest component of the given type [T], which must be the type of a
  /// concrete [InheritedComponent] subclass, and registers this build context with
  /// that component such that when that component changes (or a new component of that
  /// type is introduced, or the component goes away), this build context is
  /// rebuilt so that it can obtain new values from that component.
  ///
  /// This is typically called implicitly from `of()` static methods, such as `Router.of`.
  ///
  /// The [aspect] parameter is only used when [T] is an
  /// [InheritedComponent] subclasses that supports partial updates.
  /// It specifies what "aspect" of the inherited
  /// component this context depends on.
  T? dependOnInheritedComponentOfExactType<T extends InheritedComponent>({Object? aspect});

  /// Obtains the element corresponding to the nearest component of the given type `T`,
  /// which must be the type of a concrete [InheritedComponent] subclass.
  ///
  /// Returns null if no such element is found.
  ///
  /// Calling this method is O(1) with a small constant factor.
  ///
  /// This method does not establish a relationship with the target in the way
  /// that [dependOnInheritedComponentOfExactType] does.
  InheritedElement? getElementForInheritedComponentOfExactType<T extends InheritedComponent>();

  /// Returns the [State] object of the nearest ancestor [StatefulComponent] component
  /// that is an instance of the given type `T`.
  ///
  /// Calling this method is relatively expensive (O(N) in the depth of the
  /// tree). Only call this method if the distance from this component to the
  /// desired ancestor is known to be small and bounded.
  T? findAncestorStateOfType<T extends State>();

  /// Walks the ancestor chain, starting with the parent of this build context's
  /// component, invoking the argument for each ancestor. The callback is given a
  /// reference to the ancestor component's corresponding [Element] object. The
  /// walk stops when it reaches the root component or when the callback returns
  /// false. The callback must not return null.
  ///
  /// This is useful for inspecting the component tree.
  ///
  /// Calling this method is relatively expensive (O(N) in the depth of the tree).
  void visitAncestorElements(bool Function(Element element) visitor);

  /// Walks the children of this component.
  ///
  /// This is useful for applying changes to children after they are built
  /// without waiting for the next frame, especially if the children are known.
  ///
  /// Calling this method is potentially expensive for elements with a lot of children
  /// (O(N) in the number of children).
  ///
  /// Calling this method recursively is extremely expensive (O(N) in the number
  /// of descendants), and should be avoided if possible. Generally it is
  /// significantly cheaper to use an [InheritedComponent] and have the descendants
  /// pull data down, than it is to use [visitChildElements] recursively to push
  /// data down to them.
  void visitChildElements(ElementVisitor visitor);

  /// Start bubbling this notification at the given build context.
  ///
  /// The notification will be delivered to any [NotificationListener] components
  /// with the appropriate type parameters that are ancestors of the given
  /// [BuildContext].
  void dispatchNotification(Notification notification);
}
