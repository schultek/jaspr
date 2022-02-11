part of framework;

abstract class StatefulComponent extends Component {
  const StatefulComponent({Key? key}) : super(key: key);

  @override
  Element createElement() => StatefulElement(this);

  State createState();
}

mixin DeferRenderMixin<T extends StatefulComponent> on State<T> {
  Future<void> get defer => _deferFuture ?? Future.value();
  Future? _deferFuture;

  bool _defer() {
    if (kIsWeb && AppBinding.instance!.isFirstBuild) {
      _deferFuture = Future.sync(() async {
        await beforeFirstRender();
        initState();
        didChangeDependencies();
      });
      return true;
    }
    return false;
  }

  Future<void> beforeFirstRender();
}

mixin PreloadStateMixin<T extends StatefulComponent, U> on State<T> {
  U? _preloadedState;
  U? get preloadedState => _preloadedState;

  Future<void> get preload => _preloadFuture ?? Future.value();
  Future? _preloadFuture;

  bool _isLoadingState = false;
  bool get isLoadingState => _isLoadingState;

  bool _preload() {
    if (!kIsWeb) {
      _preloadFuture = Future.sync(() async {
        _preloadedState = await preloadState();
        if (_preloadedState != null && component.key is StateKey) {
          (component.key as StateKey)._saveState(_preloadedState);
        }
        initState();
        didChangeDependencies();
      });
      return true;
    }
    if (component.key is StateKey) {
      _preloadedState = (component.key as StateKey)._getState();
      _isLoadingState = (component.key as StateKey)._isLoadingState();
    }
    return false;
  }

  void _notifyLoadedState(dynamic data) {
    assert(data is U?);
    assert(_element != null);

    if (data == _preloadedState) {
      if (_isLoadingState) {
        _isLoadingState = false;
        _element!.markNeedsBuild();
      }
      return;
    }

    _preloadedState = data;
    _isLoadingState = false;
    _element!.markNeedsBuild();
    didLoadState();
  }

  @protected
  Future<U> preloadState();

  @protected
  void didLoadState() {}
}

mixin PersistStateMixin<T extends StatefulComponent, U> on State<T> {
  @override
  void setState(covariant U Function() fn) {
    var result = fn();
    if (component.key is StateKey) {
      (component.key as StateKey)._saveState(result);
    }
    _element!.markNeedsBuild();
  }
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
      state.initState();
      state.didChangeDependencies();
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
