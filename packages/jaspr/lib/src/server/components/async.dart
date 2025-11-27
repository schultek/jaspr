/// @docImport '../../components/basic.dart';
library;

import 'package:meta/meta.dart';

import '../../framework/framework.dart';

/// An element with an async build method.
///
/// This element is only permitted to be used on the server.
///
/// Implementations should override the [buildAsync] method and return a stream
/// of child components.
///
abstract class AsyncBuildableElement extends BuildableElement {
  AsyncBuildableElement(super.component);

  Future<Component> buildAsync();

  late Component _built;

  @override
  Component build() => _built;

  @override
  Future<void> performRebuild() async {
    try {
      _built = await buildAsync();
      super.performRebuild();
    } catch (e, st) {
      failRebuild(e, st);
    }
  }
}

/// The async variant of a stateless component.
///
/// An async component can return an async stream of children rather than
/// a sync iterable. In all other aspects it behaves the same as a [StatelessComponent].
///
/// This component is only permitted to be used on the server.
///
/// See also:
///
///  * [StatelessComponent] for the sync variant of this component.
abstract class AsyncStatelessComponent extends Component {
  /// Initializes [key] for subclasses.
  const AsyncStatelessComponent({super.key});

  @override
  Element createElement() => AsyncStatelessElement(this);

  @protected
  Future<Component> build(BuildContext context);
}

/// An [Element] that uses a [AsyncStatelessComponent] as its configuration.
class AsyncStatelessElement extends AsyncBuildableElement {
  /// Creates an element that uses the given component as its configuration.
  AsyncStatelessElement(AsyncStatelessComponent super.component);

  @override
  Future<Component> buildAsync() => (component as AsyncStatelessComponent).build(this);
}

/// The async variant of a [Builder] component.
///
/// Accepts an async [builder] function that returns a stream of child components.
///
/// This component is only permitted to be used on the server.
///
/// See also:
///
///  * [AsyncStatelessComponent] for building your own async stateless component.
class AsyncBuilder extends AsyncStatelessComponent {
  const AsyncBuilder({required this.builder, super.key});

  final Future<Component> Function(BuildContext context) builder;

  @override
  Future<Component> build(BuildContext context) {
    return builder(context);
  }
}
