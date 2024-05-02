library router;

import 'dart:async';

import 'package:jaspr/jaspr.dart';

import 'builder.dart';
import 'configuration.dart';
import 'matching.dart';
import 'misc/inherited_router.dart';
import 'parser.dart';
import 'platform/platform.dart';
import 'route.dart';
import 'typedefs.dart';

/// Router component.
class Router extends StatefulComponent {
  Router({
    required this.routes,
    this.errorBuilder,
    this.redirect,
    this.redirectLimit = 5,
  }) {
    _configuration = RouteConfiguration(
      routes: routes,
      redirectLimit: redirectLimit,
      topRedirect: redirect ?? (_, __) => null,
    );
    _parser = RouteInformationParser(
      configuration: _configuration,
    );
    _builder = RouteBuilder(
      configuration: _configuration,
      errorBuilder: errorBuilder,
    );
  }

  final List<RouteBase> routes;
  final RouterComponentBuilder? errorBuilder;
  final RouterRedirect? redirect;
  final int redirectLimit;

  late final RouteConfiguration _configuration;
  late final RouteInformationParser _parser;
  late final RouteBuilder _builder;

  @override
  State<StatefulComponent> createState() => RouterState();

  static RouterState of(BuildContext context) {
    return maybeOf(context)!;
  }

  static RouterState? maybeOf(BuildContext context) {
    if (context is StatefulElement && context.state is RouterState) {
      return context.state as RouterState;
    }
    return context.dependOnInheritedComponentOfExactType<InheritedRouter>()?.router;
  }
}

class RouterState extends State<Router> with PreloadStateMixin {
  RouteMatchList? _matchList;
  RouteMatchList get matchList => _matchList ?? RouteMatchList.empty;

  Map<Object, RouteLoader> routeLoaders = {};

  @override
  Future<void> preloadState() {
    return initRoutes();
  }

  @override
  void initState() {
    super.initState();
    if (kGenerateMode) {
      PlatformRouter.instance.registry.registerRoutes(component.routes);
    }
    PlatformRouter.instance.history.init(context.binding, onChangeState: (state, {url}) {
      _update(url ?? context.binding.currentUri.toString(), extra: state, updateHistory: false, replace: true);
    });
    if (_matchList == null) {
      assert(context.binding.isClient);
      initRoutes().then((_) {
        setState(() {});
      });
    }
  }

  @override
  void didUpdateComponent(Router oldComponent) {
    super.didUpdateComponent(oldComponent);
    if (component == oldComponent) return;
    initRoutes();
  }

  Future<void> initRoutes() {
    var location = context.binding.currentUri.toString();
    return _matchRoute(location).then(_preload).then((match) {
      _matchList = match;
      if (context.binding.isClient && match.uri.toString() != location) {
        PlatformRouter.instance.history.replace(match.uri.toString(), title: match.title);
      }
    });
  }

  Future<void> preload(String location) {
    return _matchRoute(location).then(_preload);
  }

  Future<RouteMatchList> _preload(RouteMatchList match) {
    var loaders = <RouteLoader>[];
    for (var i = 0; i < match.matches.length; i++) {
      var m = match.matches[i];
      var r = m.route;
      var hasNext = i < match.matches.length - 1;

      if (r is LazyRouteMixin && (!hasNext || r is ShellRoute)) {
        var key = m.subloc;
        var l = (routeLoaders[key] ??= RouteLoader.from((r as LazyRouteMixin).load()));
        loaders.add(l);
      }
    }
    return RouteLoader.wait(loaders).then((_) => match);
  }

  /// Get a location from route name and parameters.
  /// This is useful for redirecting to a named location.
  String namedLocation(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
  }) {
    return component._configuration.namedLocation(name, params: params, queryParams: queryParams);
  }

  Future<void> push(String location, {Object? extra}) {
    return _update(location, extra: extra);
  }

  Future<void> pushNamed(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  }) {
    return push(
      namedLocation(name, params: params, queryParams: queryParams),
      extra: extra,
    );
  }

  Future<void> replace(String location, {Object? extra}) {
    return _update(location, extra: extra, replace: true);
  }

  Future<void> replaceNamed(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  }) {
    return replace(
      namedLocation(name, params: params, queryParams: queryParams),
      extra: extra,
    );
  }

  void back() {
    PlatformRouter.instance.history.back();
  }

  Future<void> _update(
    String location, {
    Object? extra,
    bool updateHistory = true,
    bool replace = false,
  }) {
    return _matchRoute(location, extra: extra).then((match) {
      setState(() {
        _matchList = match;
        if (updateHistory || location != match.uri.toString()) {
          if (!replace) {
            PlatformRouter.instance.history.push(match.uri.toString(), title: match.title, data: match.extra);
          } else {
            PlatformRouter.instance.history.replace(match.uri.toString(), title: match.title, data: match.extra);
          }
        }
      });
    });
  }

  Future<RouteMatchList> _matchRoute(String location, {Object? extra}) {
    return component._parser.parseRouteInformation(location, context, extra: extra);
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    if (_matchList?.title case var title?) {
      yield Head(title: title);
    }
    yield* component._builder.build(this);
  }
}

class RouteLoader {
  RouteLoader.from(this.future) : isPending = true {
    future.whenComplete(() {
      isPending = false;
    });
  }

  final Future future;

  bool isPending;

  static Future<void> wait(Iterable<RouteLoader> loaders) {
    var l = loaders.where((l) => l.isPending).map((l) => l.future);
    if (l.isNotEmpty) {
      return Future.wait(l);
    } else {
      return SynchronousFuture(null);
    }
  }
}
