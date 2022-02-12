library router;

import 'dart:async';

import './browser_router.dart' if (dart.library.io) 'server_router.dart';
import '../../framework/framework.dart';

part 'route.dart';

/// Interface for history management
/// Will be implemented separately on browser and server
abstract class HistoryManager {
  factory HistoryManager() = HistoryManagerImpl;

  HistoryManager.base();

  /// Initialize the history manager and setup any listeners to history changes
  void init(void Function(String) onChange) {}

  /// Push a new state to the history
  void push(String path, {String? title});

  /// Replace the current history state
  void replace(String path, {String? title});

  /// Go back in the history
  void back();

  /// Used to load the state of a new lazy route
  /// TODO move this out of history manager api
  Future<void>? loadState(String path) => null;
}

/// Simple router component
class Router extends StatefulComponent {
  final List<Route> routes;
  final Route? Function(String, BuildContext)? onGenerateRoute;
  final Component Function(String, BuildContext)? onUnknownRoute;

  Router({required this.routes, this.onGenerateRoute, this.onUnknownRoute});

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

class RouterState extends State<Router> with PreloadStateMixin<Router, ResolvedRoute>, DeferRenderMixin<Router> {
  final HistoryManager _history = HistoryManager();

  ResolvedRoute? _currentRoute;
  ResolvedRoute get currentRoute => _currentRoute!;

  @override
  Future<void> beforeFirstRender() async {
    var route = _matchRoute((context as Element).root.currentUri.path);
    if (route is LazyRoute) route = await route.load();
    _currentRoute = route as ResolvedRoute;
  }

  @override
  Future<ResolvedRoute> preloadState() async {
    var route = _matchRoute((context as Element).root.currentUri.path);
    if (route is LazyRoute) route = await route.load();
    return route as ResolvedRoute;
  }

  @override
  void initState() {
    super.initState();
    _history.init((path) {
      _update(path, action: _HistoryAction.none);
    });
    _currentRoute ??= preloadedState;
    assert(_currentRoute != null);
  }

  Future<void> push(String path, {String? title, bool eager = true}) {
    return _update(path, title: title, eager: eager);
  }

  Future<void> replace(String path, {String? title, bool eager = true}) {
    return _update(path, title: title, eager: eager, action: _HistoryAction.replace);
  }

  void back() {
    _history.back();
  }

  Future<void> _update(
    String path, {
    String? title,
    _HistoryAction action = _HistoryAction.push,
    bool eager = true,
  }) async {
    var nextRoute = _matchRoute(path);
    if (nextRoute is LazyRoute) {
      nextRoute = await nextRoute.load(eager: eager, preload: _history.loadState);
    }
    assert(nextRoute is ResolvedRoute);
    setState(() {
      _currentRoute = nextRoute as ResolvedRoute;
      if (action == _HistoryAction.push) {
        _history.push(path, title: title);
      } else if (action == _HistoryAction.replace) {
        _history.replace(path, title: title);
      }
    });
  }

  Route _matchRoute(String path) {
    for (var route in component.routes) {
      if (route.matches(path)) {
        return route;
      }
    }
    var _route = component.onGenerateRoute?.call(path, context);
    return _route ?? _generateUnknownRoute(path);
  }

  Route _generateUnknownRoute(String path) {
    if (component.onUnknownRoute != null) {
      return Route(path, (context) => component.onUnknownRoute!(path, context));
    } else {
      return Route(path, (context) => DomComponent(tag: 'span', child: Text('No route specified for path $path.')));
    }
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield currentRoute.build(context);
  }
}
