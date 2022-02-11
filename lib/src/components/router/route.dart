part of router;

typedef FutureBuilder = Future Function();
typedef ComponentBuilder = Component Function(BuildContext);

class _LazyRoute implements Route {
  @override
  final String path;
  final FutureBuilder _loader;
  final ComponentBuilder _builder;

  _LazyRoute(this.path, this._loader, this._builder);

  Future<void>? _loaded;

  @override
  Future<void> load([Future<void>? Function()? andLoad]) {
    if (_loaded == null) {
      var andLoader = andLoad?.call();
      _loaded = Future.wait<dynamic>([_loader(), if (andLoader != null) andLoader]).whenComplete(() {
        isLoaded = true;
      });
    }
    return _loaded!;
  }

  @override
  bool get needsLoading => _loaded == null;

  @override
  bool isLoaded = false;

  @override
  bool matches(String path) {
    return this.path == path;
  }

  @override
  Component build(BuildContext context) => _builder(context);
}

class _LoadedRoute implements Route {
  @override
  final String path;
  final ComponentBuilder _builder;

  _LoadedRoute(this.path, this._builder);

  @override
  Component build(BuildContext context) => _builder(context);

  @override
  bool get isLoaded => true;

  @override
  Future<void> load([Future<void>? Function()? andLoad]) => Future.value();

  @override
  bool matches(String path) => this.path == path;

  @override
  bool get needsLoading => false;
}

abstract class Route {
  factory Route.lazy(String path, FutureBuilder loader, ComponentBuilder builder) = _LazyRoute;

  factory Route(String path, ComponentBuilder builder) = _LoadedRoute;

  Future<void> load([Future<void>? Function()? andLoad]);

  String get path;

  bool get needsLoading;

  bool get isLoaded;

  bool matches(String path);

  Component build(BuildContext context);
}
