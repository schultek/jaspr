library router;

import 'dart:async';

import 'package:jaspr/jaspr.dart';

import 'history.dart';

part 'route.dart';

/// Simple router component
class Router extends StatefulComponent {
  final List<Route>? routes;
  final Route? Function(Uri, BuildContext)? onGenerateRoute;
  final Component Function(Uri, BuildContext)? onUnknownRoute;

  Router({this.routes, this.onGenerateRoute, this.onUnknownRoute});

  @override
  State<StatefulComponent> createState() => RouterState();

  static RouterState of(BuildContext context) {
    if (context is StatefulElement && context.state is RouterState) {
      return context.state as RouterState;
    }
    return context.findAncestorStateOfType<RouterState>()!;
  }
}

enum _HistoryAction { none, push, replace }

class RouterState extends State<Router> with PreloadStateMixin, DeferRenderMixin {
  ResolvedRoute? _currentRoute;
  ResolvedRoute get currentRoute => _currentRoute!;

  final Map<LazyRoute, ResolvedRoute> _resolvedRoutes = {};

  @override
  Future<void> beforeFirstRender() async {
    var route = _matchRoute(ComponentsBinding.instance!.currentUri);
    if (route is LazyRoute) route = _resolvedRoutes[route] = await route.load();
    _currentRoute = route as ResolvedRoute;
  }

  @override
  Future<void> preloadState() async {
    var route = _matchRoute(ComponentsBinding.instance!.currentUri);
    if (route is LazyRoute) route = _resolvedRoutes[route] = await route.load();
    _currentRoute = route as ResolvedRoute;
  }

  @override
  void initState() {
    super.initState();
    HistoryManager.instance.init((uri) {
      _update(uri, action: _HistoryAction.none);
    });
    assert(_currentRoute != null);
  }

  Future<void> preload(String path) async {
    var uri = Uri.parse(path);
    var nextRoute = _matchRoute(uri);
    if (nextRoute is LazyRoute) {
      _resolvedRoutes[nextRoute] = await nextRoute.load(preload: true);
    }
  }

  Future<void> push(String path, {String? title, bool eager = true}) {
    return _update(Uri.parse(path), title: title, eager: eager);
  }

  Future<void> replace(String path, {String? title, bool eager = true}) {
    return _update(Uri.parse(path), title: title, eager: eager, action: _HistoryAction.replace);
  }

  void back() {
    HistoryManager.instance.back();
  }

  Future<void> _update(
    Uri uri, {
    String? title,
    _HistoryAction action = _HistoryAction.push,
    bool eager = true,
  }) async {
    var nextRoute = _matchRoute(uri);
    if (nextRoute is LazyRoute) {
      nextRoute = _resolvedRoutes[nextRoute] = await nextRoute.load(eager: eager, preload: true);
    }
    assert(nextRoute is ResolvedRoute);
    setState(() {
      _currentRoute = nextRoute as ResolvedRoute;
      if (action == _HistoryAction.push) {
        HistoryManager.instance.push(uri, title: title);
      } else if (action == _HistoryAction.replace) {
        HistoryManager.instance.replace(uri, title: title);
      }
    });
  }

  Route _matchRoute(Uri uri) {
    Route? route;
    if (component.routes != null) {
      for (var r in component.routes!) {
        if (r.matches(uri)) {
          route = r;
          break;
        }
      }
    }
    route ??= component.onGenerateRoute?.call(uri, context);
    route ??= _generateUnknownRoute(uri);
    return _resolvedRoutes[route] ?? route;
  }

  Route _generateUnknownRoute(Uri uri) {
    if (component.onUnknownRoute != null) {
      return Route(uri.path, (context) => [component.onUnknownRoute!(uri, context)]);
    } else {
      return Route(
          uri.path,
          (context) =>
              [DomComponent(tag: 'span', child: Text('No route specified for uri $uri.'))]);
    }
  }

  @override
  Iterable<Component> build(BuildContext context) {
    return currentRoute.build(context);
  }
}
