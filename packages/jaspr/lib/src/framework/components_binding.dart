part of framework;

final _queryReg = RegExp(r'^(.*?)(?:\((\d+):(\d+)\))?$');

/// Main app binding, controls the root component and global state
mixin ComponentsBinding on AppBinding {
  /// Sets [app] as the new root of the component tree and performs an initial build
  Future<void> attachRootComponent(Component app, {required String attachTo}) async {
    var buildOwner = _rootElement?._owner ?? BuildOwner();
    await buildOwner.lockState(() async {
      buildOwner._isFirstBuild = true;

      var attachMatch = _queryReg.firstMatch(attachTo)!;
      var renderer = attachRenderer(attachMatch.group(1)!,
          from: int.tryParse(attachMatch.group(2) ?? ''), to: int.tryParse(attachMatch.group(3) ?? ''));

      var element = _Root(child: app).createElement();
      element._binding = this;
      element._owner = buildOwner;
      element._renderer = renderer;

      element.mount(null, null);

      if (element._asyncFirstBuild != null) {
        await element._asyncFirstBuild;
      }

      _rootElement = element;
      buildOwner._isFirstBuild = false;

      didAttachRootElement(element, to: attachTo);
    });
  }

  @protected
  void didAttachRootElement(Element element, {required String to}) {}

  /// The [Element] that is at the root of the hierarchy.
  ///
  /// This is initialized when [runApp] is called.
  @override
  RenderElement? get rootElement => _rootElement;
  RenderElement? _rootElement;

  Renderer attachRenderer(String target, {int? from, int? to});

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
  _Root({required this.child});

  final Component child;

  @override
  _RootElement createElement() => _RootElement(this);
}

class _RootElement extends SingleChildElement with RenderElement {
  _RootElement(_Root component) : super(component);

  @override
  _Root get component => super.component as _Root;

  @override
  void _firstBuild([VoidCallback? onBuilt]) {
    _attach();
    super._firstBuild(onBuilt);
  }

  @override
  void renderNode(Renderer renderer) {}

  @override
  Component build() => component.child;
}
