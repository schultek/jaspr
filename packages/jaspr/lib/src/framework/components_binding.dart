part of 'framework.dart';

/// Main app binding, controls the root component and global state
mixin ComponentsBinding on AppBinding {
  /// Sets [app] as the new root of the component tree and performs an initial build
  void attachRootComponent(Component app) async {
    var buildOwner = _rootElement?._owner ?? createRootBuildOwner();

    var element = _Root(child: app).createElement();
    element._binding = this;
    element._owner = buildOwner;
    element._renderObject = createRootRenderObject();

    _rootElement = element;

    buildOwner.performInitialBuild(element, completeInitialFrame);
  }

  RenderObject createRootRenderObject();

  BuildOwner createRootBuildOwner() {
    return BuildOwner();
  }

  /// The [Element] that is at the root of the hierarchy.
  ///
  /// This is initialized when [runApp] is called.
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

class _Root extends ProxyComponent {
  _Root({required super.child});

  @override
  _RootElement createElement() => _RootElement(this);
}

class _RootElement extends ProxyRenderObjectElement {
  _RootElement(_Root super.component);

  @override
  void updateRenderObject() {}
}
