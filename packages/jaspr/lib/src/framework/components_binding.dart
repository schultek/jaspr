part of framework;

/// Main app binding, controls the root component and global state
mixin ComponentsBinding on BindingBase {
  /// The currently active uri.
  /// On the server, this is the requested uri. On the client, this is the
  /// currently visited uri in the browser.
  Uri get currentUri;

  @override
  void initInstances() {
    super.initInstances();
    _instance = this;
    _buildOwner = BuildOwner();
  }

  static ComponentsBinding? _instance;
  static ComponentsBinding? get instance => _instance;

  late BuildOwner _buildOwner;
  BuildOwner get buildOwner => _buildOwner;

  /// Whether the current app is run on the client (in the browser)
  bool get isClient;

  /// Sets [app] as the new root of the component tree and performs an initial build
  Future<void> attachRootComponent(Component app, {required String attachTo}) async {
    return buildOwner.lockState(() async {
      buildOwner._isFirstBuild = true;

      var element = _Root(child: app).createElement();
      element._owner = _buildOwner;

      element.mount(null);

      if (element._asyncFirstBuild != null) {
        await element._asyncFirstBuild;
      }

      _rootElement = element;
      buildOwner._isFirstBuild = false;

      didAttachRootElement(element, to: attachTo);
    });
  }

  @protected
  void didAttachRootElement(BuildScheduler element, {required String to});

  /// The [Element] that is at the root of the hierarchy.
  ///
  /// This is initialized the first time [runApp] is called.
  SingleChildElement? get rootElement => _rootElement;
  SingleChildElement? _rootElement;

  DomView registerView(covariant dynamic root, DomBuilderFn builderFn, bool initialRender);
}

/// In difference to Flutter, we have multiple build schedulers instead of one global build owner
/// Particularly each dom element is a build scheduler and manages its subtree of components
mixin BuildScheduler on Element {
  DomView? _view;

  // ignore: prefer_final_fields
  bool _willUpdate = false;

  DomView get view => _view!;
  set view(DomView v) {
    _view = v;
  }

  @override
  void render(DomBuilder b) {
    _willUpdate = false;
    super.render(b);
  }
}

class _Root extends Component {
  _Root({required this.child});

  final Component child;

  @override
  _RootElement createElement() => _RootElement(this);
}

class _RootElement extends SingleChildElement with BuildScheduler {
  _RootElement(_Root component) : super(component);

  @override
  _Root get component => super.component as _Root;

  @override
  Component build() => component.child;
}
