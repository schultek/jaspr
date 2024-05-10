import 'package:meta/meta.dart';

import '../../framework/framework.dart';

abstract class AsyncBuildableElement extends BuildableElement {
  AsyncBuildableElement(super.component);

  Stream<Component> buildAsync();

  late Iterable<Component> _built;

  @override
  Iterable<Component> build() => _built;

  @override
  Future<void> performRebuild() async {
    _built = await buildAsync().toList();
    super.performRebuild();
  }
}

abstract class AsyncStatelessComponent extends Component {
  /// Initializes [key] for subclasses.
  const AsyncStatelessComponent({super.key});

  @override
  Element createElement() => AsyncStatelessElement(this);

  @protected
  Stream<Component> build(BuildContext context);
}

/// An [Element] that uses a [StatelessComponent] as its configuration.
class AsyncStatelessElement extends AsyncBuildableElement {
  /// Creates an element that uses the given component as its configuration.
  AsyncStatelessElement(AsyncStatelessComponent super.component);

  @override
  Stream<Component> buildAsync() => (component as AsyncStatelessComponent).build(this);
}

class AsyncBuilder extends AsyncStatelessComponent {
  const AsyncBuilder({required this.builder, super.key});

  final Stream<Component> Function(BuildContext context) builder;

  @override
  Stream<Component> build(BuildContext context) {
    return builder(context);
  }
}
