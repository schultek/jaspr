part of router;

typedef FutureBuilder = Future Function();
typedef ComponentBuilder = Component Function(BuildContext);

/// Interface for any Route
/// Do not subclass this, always subclass either LazyRoute or ResolvedRoute
abstract class Route {
  factory Route.lazy(String path, ComponentBuilder builder, FutureBuilder loader) = LazyRoute;

  const factory Route(String path, ComponentBuilder builder) = ResolvedRoute;

  bool matches(String path);
}

/// Interface for a resolved route that does not require any loading
abstract class ResolvedRoute implements Route {
  const factory ResolvedRoute(String path, ComponentBuilder builder) = _ResolvedRoute;

  Component build(BuildContext context);
}

/// Lazy loaded route. Should be used with deferred imports
class LazyRoute implements Route {
  final String _path;
  final FutureBuilder _loader;
  final ComponentBuilder _builder;

  LazyRoute(this._path, this._builder, this._loader);

  Future<ResolvedRoute>? _resolved;

  Future<ResolvedRoute> load({bool eager = true, bool preload = false}) {
    if (_resolved == null) {
      List<Future> loading = [_loader()];
      if (preload) {
        var preloaded = ComponentsBinding.instance!.loadState(_path);
        if (!eager) loading.add(preloaded);
      }
      _resolved = Future.wait(loading).then((_) {
        return ResolvedRoute(_path, _builder);
      });
    }
    return _resolved!;
  }

  @override
  bool matches(String path) => _path == path;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is LazyRoute && runtimeType == other.runtimeType && _path == other._path;

  @override
  int get hashCode => _path.hashCode;
}

class _ResolvedRoute implements ResolvedRoute {
  final String _path;
  final ComponentBuilder _builder;

  const _ResolvedRoute(this._path, this._builder);

  @override
  Component build(BuildContext context) => _builder(context);

  @override
  bool matches(String path) => _path == path;

  @override
  String toString() {
    return '_ResolvedRoute{_path: $_path}';
  }
}
