import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:jaspr_router/src/platform/platform.dart';
import 'package:jaspr_test/jaspr_test.dart';

RouterState findRouter(Element root) {
  RouterState? router;
  findRouter(Element element) {
    if (element is StatefulElement && element.state is RouterState) {
      router = element.state as RouterState;
    } else {
      element.visitChildren(findRouter);
    }
  }

  root.visitChildren(findRouter);
  return router!;
}

extension TestRouter on ComponentTester {
  RouterState get router {
    return findRouter(binding.rootElement!);
  }

  RouteState routeOf(Finder finder) {
    return RouteState.of(finder.evaluate().first);
  }
}

void mockPlatform() {
  PlatformRouter.instance = MockPlatformRouter();
}

class MockPlatformRouter implements PlatformRouter {
  @override
  final HistoryManager history = MockHistoryManager();

  @override
  final RouteRegistry registry = MockRouteRegistry();
}

class MockHistoryManager implements HistoryManager {
  List<String> history = [];
  late void Function(Object? state, {String? url})? onChangeState;

  @override
  void init(BuildContext context, {void Function(Object? state, {String? url})? onChangeState}) {
    history = [context.url];
    this.onChangeState = onChangeState;
  }

  @override
  void push(String url, {String? title, Object? data}) {
    history.add(url);
  }

  @override
  void replace(String url, {String? title, Object? data}) {
    history
      ..removeLast()
      ..add(url);
  }

  @override
  void back() {
    history.removeLast();
    onChangeState?.call(null, url: history.last);
  }
}

class MockRouteRegistry implements RouteRegistry {
  @override
  Future<void> registerRoutes(List<RouteBase> routes) async {}
}

Route homeRoute() => Route(path: '/', builder: (_, __) => Page(path: 'home'));
Route route(String path, [List<RouteBase> routes = const [], String? name, RouterRedirect? redirect]) => Route(
      path: path,
      name: name,
      redirect: redirect,
      builder: (_, s) => Page(path: s.subloc),
      routes: routes,
    );
Route lazyRoute(String path, Future future, [List<RouteBase> routes = const []]) => Route.lazy(
      path: path,
      builder: (_, s) => Page(path: s.subloc),
      load: () => future,
      routes: routes,
    );
ShellRoute shellRoute(String name, List<RouteBase> routes) => ShellRoute(
      builder: (_, s, c) => Page(path: name, child: c),
      routes: routes,
    );
ShellRoute lazyShellRoute(String name, Future future, List<RouteBase> routes) => ShellRoute.lazy(
      builder: (_, s, c) => Page(path: name, child: c),
      load: () => future,
      routes: routes,
    );

class Page extends StatelessComponent {
  Page({required this.path, this.child});

  final String path;
  final Component? child;

  @override
  Component build(BuildContext context) {
    var label = path.startsWith('/') ? path.substring(1) : path;
    final children = <Component>[];
    children.add(span([text(label)]));

    var state = RouteState.of(context);
    if (state.params.isNotEmpty) {
      children.add(span([text(state.params.entries.map((e) => '${e.key}=${e.value}').join(','))]));
    }

    if (child != null) {
      children.add(div([child!]));
    }
    return Fragment(children: children);
  }
}
