import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:jaspr_router/src/platform/platform.dart';
import 'package:jaspr_test/jaspr_test.dart';

RouterState findRouter(Element root) {
  RouterState? router;
  void findRouter(Element element) {
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

  @override
  void redirect(BuildContext context, String url) {}
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

Route homeRoute() => Route(
  path: '/',
  builder: (_, _) => Page(path: 'home'),
);

Route route(String path, [List<RouteBase> routes = const [], String? name, RouterRedirect? redirect]) => Route(
  path: path,
  name: name,
  redirect: redirect,
  builder: (_, state) => Page(path: state.subloc),
  routes: routes,
);

Route lazyRoute(String path, Future<void> future, [List<RouteBase> routes = const []]) => Route.lazy(
  path: path,
  builder: (_, state) => Page(path: state.subloc),
  load: () => future,
  routes: routes,
);

ShellRoute shellRoute(String name, List<RouteBase> routes) => ShellRoute(
  builder: (_, _, child) => Page(path: name, child: child),
  routes: routes,
);

ShellRoute lazyShellRoute(String name, Future<void> future, List<RouteBase> routes) => ShellRoute.lazy(
  builder: (_, _, child) => Page(path: name, child: child),
  load: () => future,
  routes: routes,
);

class Page extends StatelessComponent {
  Page({required this.path, this.child});

  final String path;
  final Component? child;

  @override
  Component build(BuildContext context) {
    final label = path.startsWith('/') ? path.substring(1) : path;
    final children = <Component>[];
    children.add(span([Component.text(label)]));

    final state = RouteState.of(context);
    if (state.params.isNotEmpty) {
      children.add(span([Component.text(state.params.entries.map((e) => '${e.key}=${e.value}').join(','))]));
    }

    if (child != null) {
      children.add(div([child!]));
    }
    return Component.fragment(children);
  }
}
