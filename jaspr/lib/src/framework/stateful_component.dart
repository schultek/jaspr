part of framework;

abstract class StatefulComponent extends Component {
  const StatefulComponent({Key? key}) : super(key: key);

  @override
  Element createElement() => StatefulElement(this);

  State createState();
}

/// This defers the first rendering on the client for an async task
mixin DeferRenderMixin<T extends StatefulComponent> on State<T> {
  Future<void> get defer => _deferFuture ?? Future.value();
  Future? _deferFuture;

  bool _defer() {
    if (kIsWeb && AppBinding.instance!.isFirstBuild) {
      _deferFuture = Future.sync(() async {
        await beforeFirstRender();
        _element!._initState();
      });
      return true;
    }
    return false;
  }

  /// Called on the client before initState() to perform some asynchronous task
  Future<void> beforeFirstRender();
}

/// Mixin on [State] that preloads state on the server
mixin PreloadStateMixin<T extends StatefulComponent> on State<T> {
  Future<void> get preloadFuture => _preloadFuture ?? Future.value();
  Future? _preloadFuture;

  bool _preload() {
    if (!kIsWeb) {
      _preloadFuture = Future.sync(() async {
        await preloadState();
        _element!._initState();
      });
      return true;
    }
    return false;
  }

  /// Called on the server before initState() to preload asynchronous data
  @protected
  Future<void> preloadState();
}

/// Mixin on [State] that syncs state data from the server with the client
mixin SyncStateMixin<T extends StatefulComponent, U> on State<T> {
  /// Codec used to serialize the state data on the server and deserialize on the client
  Codec<U, String> get syncCodec => StateJsonCodec();

  /// Globally unique id used to identify the state data between server and client
  String get syncId;

  /// Called on the server after the initial build, to retrieve the state data of this component.
  U saveState();

  /// Called on the client when a new state value is available, either when the state is first initialized, or when the
  /// state becomes available through lazy loading a route.
  ///
  /// On initialization, this will be called after initState() and before didChangeDependencies()
  void updateState(U? value);
}

class StateJsonCodec<T> extends Codec<T, String> {
  @override
  Converter<String, T> get decoder => JsonDecoder().cast();
  @override
  Converter<T, String> get encoder => JsonEncoder().cast();
}

abstract class State<T extends StatefulComponent> {
  T get component => _component!;
  T? _component;

  StatefulElement? _element;

  BuildContext get context => _element!;

  bool get mounted => _element != null;

  @protected
  @mustCallSuper
  void initState() {}

  @mustCallSuper
  @protected
  void didUpdateComponent(covariant T oldComponent) {}

  @protected
  void setState(dynamic Function() fn) {
    fn();
    _element!.markNeedsBuild();
  }

  @protected
  @mustCallSuper
  void deactivate() {}

  @protected
  @mustCallSuper
  void activate() {}

  @mustCallSuper
  @protected
  void dispose() {}

  @protected
  Iterable<Component> build(BuildContext context);

  @protected
  @mustCallSuper
  void didChangeDependencies() {}
}

class StatefulElement extends MultiChildElement {
  StatefulElement(StatefulComponent component)
      : _state = component.createState(),
        super(component) {
    state._component = component;
    state._element = this;
  }

  @override
  Iterable<Component> build() => state.build(this);

  State? _state;
  State get state => _state!;

  void _initState() {
    state.initState();
    if (kIsWeb && state is SyncStateMixin && component.key is GlobalKey) {
      AppBinding.instance!._initState(component.key as GlobalKey);
    }
    state.didChangeDependencies();
  }

  @override
  void _firstBuild() {
    var didInit = false;
    if (state is DeferRenderMixin) {
      didInit = (state as DeferRenderMixin)._defer();
    }
    if (state is PreloadStateMixin) {
      didInit = didInit | (state as PreloadStateMixin)._preload();
    }

    if (!didInit) {
      _initState();
    }
    super._firstBuild();
  }

  @override
  void rebuild() {
    if (_didChangeDependencies) {
      state.didChangeDependencies();
      _didChangeDependencies = false;
    }
    super.rebuild();
  }

  @override
  void update(StatefulComponent newComponent) {
    super.update(newComponent);
    final StatefulComponent oldComponent = state.component;

    _dirty = true;
    state._component = newComponent;

    state.didUpdateComponent(oldComponent);
    root.performRebuildOn(this);
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
    state._element = null;
    _state = null;
  }

  bool _didChangeDependencies = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _didChangeDependencies = true;
  }
}
