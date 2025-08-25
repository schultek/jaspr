import '../../jaspr.dart';

class ListenableBuilder extends StatefulComponent {
  /// Creates a widget that rebuilds when the given listenable changes.
  ///
  /// The [listenable] argument is required.
  const ListenableBuilder({super.key, required this.listenable, required this.builder});

  /// The [Listenable] to which this widget is listening.
  ///
  /// Commonly a [ChangeNotifier].
  final Listenable listenable;

  final Component Function(BuildContext) builder;

  /// Subclasses typically do not override this method.
  @override
  State<ListenableBuilder> createState() => _ListenableBuilderState();
}

class _ListenableBuilderState extends State<ListenableBuilder> {
  @override
  void initState() {
    super.initState();
    component.listenable.addListener(_handleChange);
  }

  @override
  void didUpdateComponent(ListenableBuilder oldComponent) {
    super.didUpdateComponent(oldComponent);
    if (component.listenable != oldComponent.listenable) {
      oldComponent.listenable.removeListener(_handleChange);
      component.listenable.addListener(_handleChange);
    }
  }

  @override
  void dispose() {
    component.listenable.removeListener(_handleChange);
    super.dispose();
  }

  void _handleChange() {
    if (!mounted) {
      return;
    }
    setState(() {
      // The listenable's state is our build state, and it changed already.
    });
  }

  @override
  Component build(BuildContext context) => component.builder(context);
}

class ValueListenableBuilder<T> extends ListenableBuilder {
  ValueListenableBuilder({
    super.key,
    required ValueListenable<T> super.listenable,
    required Component Function(BuildContext, T) builder,
  }) : super(builder: (context) => builder(context, listenable.value));
}
