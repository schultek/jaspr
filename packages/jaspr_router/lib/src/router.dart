library router;

import 'dart:async';

import 'package:jaspr/jaspr.dart';

import 'builder.dart';
import 'configuration.dart';
import 'history/history.dart';
import 'matching.dart';
import 'misc/inherited_router.dart';
import 'parser.dart';
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
    if (context is StatefulElement && context.state is RouterState) {
      return context.state as RouterState;
    }
    return context.dependOnInheritedComponentOfExactType<InheritedRouter>()!.router;
  }
}

class RouterState extends State<Router> with PreloadStateMixin {
  RouteMatchList? _matchList;
  RouteMatchList get matchList => _matchList ?? RouteMatchList.empty;

  Map<Object, RouteLoader> routeLoaders = {};

  @override
  Future<void> preloadState() {
    var location = context.binding.currentUri.toString();
    return _matchRoute(location).then((match) async {
      await _preload(match);
      _matchList = match;
    });
  }

  @override
  void initState() {
    super.initState();
    HistoryManager.instance.init((uri) {
      _update(uri, updateHistory: false);
    });
    if (_matchList == null) {
      assert(context.binding.isClient);
      preloadState().then((_) {
        setState(() {});
      });
    }
  }

  Future<void> preload(String location) async {
    return _matchRoute(location).then((match) async {
      await _preload(match);
    });
  }

  Future<void> _preload(RouteMatchList match) async {
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
    await RouteLoader.wait(loaders);
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
    HistoryManager.instance.back();
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
        if (updateHistory) {
          if (!replace) {
            HistoryManager.instance.push(match.uri.toString(), title: match.title);
          } else {
            HistoryManager.instance.replace(match.uri.toString(), title: match.title);
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
    yield* component._builder.build(context, this);
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

  static Future<void> wait(Iterable<RouteLoader> loaders) async {
    var l = loaders.where((l) => l.isPending).map((l) => l.future);
    if (l.isNotEmpty) {
      await Future.wait(l);
    }
  }
}
