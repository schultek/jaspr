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
  Router({required this.routes, this.errorBuilder, this.redirect, this.redirectLimit = 5, super.key}) {
    _configuration = RouteConfiguration(
      routes: routes,
      redirectLimit: redirectLimit,
      topRedirect: redirect ?? (_, _) => null,
    );
    _parser = RouteInformationParser(configuration: _configuration);
    _builder = RouteBuilder(configuration: _configuration, errorBuilder: errorBuilder);
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
  Future<void> preloadState() async {
    if (kGenerateMode) {
      await PlatformRouter.instance.registry.registerRoutes(component.routes);
    }
    return initRoutes();
  }

  @override
  void initState() {
    super.initState();
    PlatformRouter.instance.history.init(
      context,
      onChangeState: (state, {url}) {
        _update(url ?? context.url, extra: state, updateHistory: false, replace: true);
      },
    );
    if (_matchList == null) {
      assert(context.binding.isClient);
      initRoutes();
    }
  }

  @override
  void didUpdateComponent(Router oldComponent) {
    super.didUpdateComponent(oldComponent);
    if (component == oldComponent) return;
    initRoutes();
  }

  Future<void> initRoutes() {
    final location = context.url;
    return _matchRoute(location).then(_preload).then((match) {
      if (!mounted) return;
      _matchList = match;
      if (context.binding.isClient) {
        setState(() {});
      }
      if (context.binding.isClient && match.uri.toString() != location) {
        PlatformRouter.instance.history.replace(match.uri.toString(), title: match.title);
      }
    });
  }

  /// Preloads the route for faster navigation. Works with [LazyRoute]s.
  Future<void> preload(String location) {
    return _matchRoute(location).then(_preload);
  }

  /// Pushes a new route onto the history stack.
  ///
  /// The [extra] parameter can be used to provide additional data with navigation. It will go through serialization
  /// when it is stored in the browser and must be a primitive serializable value.
  ///
  /// See also:
  /// * [replace] which replaces the history entry with the new route.
  Future<void> push(String location, {Object? extra}) {
    return _update(location, extra: extra);
  }

  /// Pushes a named route onto the history stack.
  ///
  /// Optional parameters can be provided to the named route, like `params: {'userId': '123'}` as well as [queryParams].
  /// The [extra] parameter can be used to provide additional data with navigation. It will go through serialization
  /// when it is stored in the browser and must be a primitive serializable value.
  ///
  /// See also:
  /// * [replaceNamed] which replaces the history entry with the named route.
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

  /// Replaces the current history entry with a new route.
  ///
  /// The [extra] parameter can be used to provide additional data with navigation. It will go through serialization
  /// when it is stored in the browser and must be a primitive serializable value.
  ///
  /// See also:
  /// * [push] which pushes the route to the history stack.
  Future<void> replace(String location, {Object? extra}) {
    return _update(location, extra: extra, replace: true);
  }

  /// Replaces the current history entry with a named route.
  ///
  /// Optional parameters can be provided to the named route, like `params: {'userId': '123'}` as well as [queryParams].
  /// The [extra] parameter can be used to provide additional data with navigation. It will go through serialization
  /// when it is stored in the browser and must be a primitive serializable value.
  ///
  /// See also:
  /// * [pushNamed] which pushes a named route onto the history stack.
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

  /// Triggers the browsers back navigation.
  void back() {
    PlatformRouter.instance.history.back();
  }

  /// Get a location from route name and parameters.
  /// This is useful for redirecting to a named location.
  ///
  /// Optional parameters can be provided to the named route, like `params: {'userId': '123'}` as well as [queryParams].
  String namedLocation(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
  }) {
    return component._configuration.namedLocation(name, params: params, queryParams: queryParams);
  }

  Future<void> _update(String location, {Object? extra, bool updateHistory = true, bool replace = false}) {
    return _matchRoute(location, extra: extra).then((match) {
      if (!mounted) return;
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

  Future<RouteMatchList> _preload(RouteMatchList match) {
    final loaders = <RouteLoader>[];
    for (var i = 0; i < match.matches.length; i++) {
      final m = match.matches[i];
      final hasNext = i < match.matches.length - 1;

      if (m.route case final LazyRouteBase r when (!hasNext || r is ShellRoute)) {
        final key = m.subloc;
        final l = (routeLoaders[key] ??= RouteLoader.from(r.load()));
        loaders.add(l);
      }
    }
    return RouteLoader.wait(loaders).then((_) => match);
  }

  Future<RouteMatchList> _matchRoute(String location, {Object? extra}) {
    return component._parser.parseRouteInformation(location, context, extra: extra);
  }

  @override
  Component build(BuildContext context) {
    return Component.fragment([
      if (_matchList?.title case final title?) Document.head(title: title),
      component._builder.build(this),
    ]);
  }
}

class RouteLoader {
  RouteLoader.from(this.future) : isPending = true {
    future.whenComplete(() {
      isPending = false;
    });
  }

  final Future<void> future;

  bool isPending;

  static Future<void> wait(Iterable<RouteLoader> loaders) {
    final pendingLoaders = loaders.where((l) => l.isPending).map((l) => l.future);
    if (pendingLoaders.isNotEmpty) {
      return pendingLoaders.wait;
    } else {
      return SynchronousFuture(null);
    }
  }
}
