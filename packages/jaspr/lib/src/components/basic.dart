// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../framework/framework.dart';

/// A stateless utility component whose [build] method uses its
/// [builder] callback to create the component's child.
///
/// {@youtube 560 315 https://www.youtube.com/watch?v=xXNOkIuSYuA}
///
/// This component is a simple inline alternative to defining a [StatelessComponent]
/// subclass. For example a component defined and used like this:
///
/// ```dart
/// class Foo extends StatelessComponent {
///   @override
///   Component build(BuildContext context) => Text('foo');
/// }
///
/// Center(child: Foo())
/// ```
///
/// Could equally well be defined and used like this, without
/// defining a new component class:
///
/// ```dart
/// Center(
///   child: Builder(
///     builder: (BuildContext context) => Text('foo');
///   ),
/// )
/// ```
///
/// The difference between either of the previous examples and simply
/// creating a child directly, without an intervening component, is the
/// extra [BuildContext] element that the additional component adds. This
/// is particularly noticeable when the tree contains an inherited
/// component that is referred to by a method like `Scaffold.of`,
/// which visits the child component's [BuildContext] ancestors.
///
/// In the following example the button's `onPressed` callback is unable
/// to find the enclosing `ScaffoldState` with `Scaffold.of`:
///
/// ```dart
/// Component build(BuildContext context) {
///   return Scaffold(
///     body: Center(
///       child: TextButton(
///         onPressed: () {
///           // Fails because Scaffold.of() doesn't find anything
///           // above this component's context.
///           print(Scaffold.of(context).hasAppBar);
///         },
///         child: Text('hasAppBar'),
///       )
///     ),
///   );
/// }
/// ```
///
/// A [Builder] component introduces an additional [BuildContext] element
/// and so the `Scaffold.of` method succeeds.
///
/// ```dart
/// Component build(BuildContext context) {
///   return Scaffold(
///     body: Builder(
///       builder: (BuildContext context) {
///         return Center(
///           child: TextButton(
///             onPressed: () {
///               print(Scaffold.of(context).hasAppBar);
///             },
///             child: Text('hasAppBar'),
///           ),
///         );
///       },
///     ),
///   );
/// }
/// ```
///
/// See also:
///
///  * [StatefulBuilder], A stateful utility component whose [build] method uses its
///    [builder] callback to create the component's child.
class Builder extends StatelessComponent {
  /// Creates a component that delegates its build to a callback.
  ///
  /// The [builder] argument must not be null.
  const Builder({super.key, required this.builder});

  /// Called to obtain the child component.
  ///
  /// This function is called whenever this component is included in its parent's
  /// build and the old component (if any) that it synchronizes with has a distinct
  /// object identity. Typically the parent's build method will construct
  /// a new tree of components and so a new Builder child will not be [identical]
  /// to the corresponding old one.
  final ComponentBuilder builder;

  @override
  Component build(BuildContext context) => builder(context);
}

/// Signature for the builder callback used by [StatefulBuilder].
///
/// Call `setState` to schedule the [StatefulBuilder] to rebuild.
typedef StatefulComponentBuilder = Component Function(BuildContext context, StateSetter setState);

/// A platonic component that both has state and calls a closure to obtain its child component.
///
/// The [StateSetter] function passed to the [builder] is used to invoke a
/// rebuild instead of a typical [State]'s [State.setState].
///
/// Since the [builder] is re-invoked when the [StateSetter] is called, any
/// variables that represents state should be kept outside the [builder] function.
///
/// See also:
///
///  * [Builder], the platonic stateless component.
class StatefulBuilder extends StatefulComponent {
  /// Creates a component that both has state and delegates its build to a callback.
  ///
  /// The [builder] argument must not be null.
  const StatefulBuilder({super.key, required this.builder});

  /// Called to obtain the child component.
  ///
  /// This function is called whenever this component is included in its parent's
  /// build and the old component (if any) that it synchronizes with has a distinct
  /// object identity. Typically the parent's build method will construct
  /// a new tree of components and so a new Builder child will not be [identical]
  /// to the corresponding old one.
  final StatefulComponentBuilder builder;

  @override
  State<StatefulBuilder> createState() => _StatefulBuilderState();
}

class _StatefulBuilderState extends State<StatefulBuilder> {
  @override
  Component build(BuildContext context) => component.builder(context, setState);
}
