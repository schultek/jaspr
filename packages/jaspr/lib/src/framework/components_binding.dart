part of 'framework.dart';

/// Main app binding, controls the root component and global state
mixin ComponentsBinding on AppBinding {
  /// Sets [app] as the new root of the component tree and performs an initial build
  void attachRootComponent(Component app) async {
    final buildOwner = _rootElement?._owner ?? createRootBuildOwner();

    final element = _Root(child: app, rootRenderObject: createRootRenderObject()).createElement();
    element._binding = this;
    element._owner = buildOwner;

    _rootElement = element;

    buildOwner.performInitialBuild(element, completeInitialFrame);
  }

  RenderObject createRootRenderObject();

  BuildOwner createRootBuildOwner() {
    return BuildOwner();
  }

  /// The [Element] that is at the root of the hierarchy.
  ///
  /// This is initialized when `runApp` is called.
  @override
  RenderObjectElement? get rootElement => _rootElement;
  RenderObjectElement? _rootElement;

  static final Map<GlobalKey, Element> _globalKeyRegistry = {};

  static void _registerGlobalKey(GlobalKey key, Element element) {
    _globalKeyRegistry[key] = element;
  }

  static void _unregisterGlobalKey(GlobalKey key, Element element) {
    if (_globalKeyRegistry[key] == element) {
      _globalKeyRegistry.remove(key);
    }
  }
}

class _Root extends Component {
  _Root({required this.child, required this.rootRenderObject});

  final Component child;
  final RenderObject rootRenderObject;

  @override
  _RootElement createElement() => _RootElement(this);
}

class _RootElement extends MultiChildRenderObjectElement {
  _RootElement(_Root super.component);

  @override
  List<Component> buildChildren() => [(component as _Root).child];

  @override
  RenderObject createRenderObject() {
    return (component as _Root).rootRenderObject;
  }

  @override
  void updateRenderObject(_) {}
}
