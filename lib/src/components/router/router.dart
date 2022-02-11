library router;

import 'dart:async';

import './browser_router.dart' if (dart.library.io) 'server_router.dart';
import '../../framework/framework.dart';

part 'route.dart';

abstract class HistoryManager {
  factory HistoryManager() = HistoryManagerImpl;

  HistoryManager.base();

  void init(void Function(String) onChange) {}

  void push(String path);
  void back();

  Future<void>? preload(Route nextRoute) => null;
}

class Router extends StatefulComponent {
  final List<Route> routes;
  final Component Function(String, BuildContext) onUnknownRoute;

  Router({required this.routes, required this.onUnknownRoute});

  @override
  State<StatefulComponent> createState() => RouterState();

  static RouterState of(BuildContext context) {
    if (context is StatefulElement && context.state is RouterState) {
      return context.state as RouterState;
    }
    return context.findAncestorStateOfType<RouterState>()!;
  }
}

class RouterState extends State<Router> with PreloadStateMixin<Router, Route?>, DeferRenderMixin<Router> {
  final HistoryManager _history = HistoryManager();

  Route? _currentRoute;
  Route get currentRoute => _currentRoute!;

  @override
  Future<void> beforeFirstRender() async {
    var route = _matchRoute((context as Element).root.currentUri.path);
    await route?.load();
    _currentRoute = route;
  }

  @override
  Future<Route?> preloadState() async {
    var route = _matchRoute((context as Element).root.currentUri.path);
    await route?.load();
    return route;
  }

  @override
  void initState() {
    super.initState();
    _history.init((path) {
      _update(path, addToHistory: false);
    });
    _currentRoute ??= preloadedState;
    assert(_currentRoute != null && _currentRoute!.isLoaded);
  }

  Future<void> push(String path, {bool eager = true}) {
    return _update(path, eager: eager);
  }

  void back() {
    _history.back();
  }

  Future<void> _update(String path, {bool addToHistory = true, bool eager = true}) async {
    var nextRoute = _matchRoute(path);
    if (nextRoute != null) {
      if (eager) {
        if (nextRoute.needsLoading) _history.preload(nextRoute);
        await nextRoute.load();
      } else {
        await nextRoute.load(() => _history.preload(nextRoute));
      }
      setState(() {
        _currentRoute = nextRoute;
        if (addToHistory) {
          _history.push(path);
        }
      });
    }
  }

  Route? _matchRoute(String path) {
    for (var route in component.routes) {
      if (route.matches(path)) {
        return route;
      }
    }
    return Route(path, (context) => component.onUnknownRoute(path, context));
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    assert(currentRoute.isLoaded);
    yield _currentRoute!.build(context);
  }
}
