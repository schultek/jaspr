import 'package:jaspr/html.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:jaspr_router/src/history/history.dart';
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

void mockHistory() {
  HistoryManager.instance = MockHistoryManager();
}

class MockHistoryManager implements HistoryManager {
  List<String> history = [];
  late void Function(String url) onChange;

  @override
  void init(String location, void Function(String url) onChange) {
    history = [location];
    this.onChange = onChange;
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
    onChange(history.last);
  }
}

Route homeRoute() => Route(path: '/', builder: (_, __) => Page(path: 'home'));
Route route(String path, [List<RouteBase> routes = const [], String? name, RouterRedirect? redirect]) => Route(
      path: path,
      name: name,
      redirect: redirect,
      builder: (_, __) => Page(path: path),
      routes: routes,
    );
Route lazyRoute(String path, Future future, [List<RouteBase> routes = const []]) => Route.lazy(
      path: path,
      builder: (_, __) => Page(path: path),
      load: () => future,
      routes: routes,
    );
ShellRoute shellRoute(String name, [List<RouteBase> routes = const []]) => ShellRoute(
      builder: (_, __, c) => Page(path: name, child: c),
      routes: routes,
    );
ShellRoute lazyShellRoute(String name, Future future, [List<RouteBase> routes = const []]) => ShellRoute.lazy(
      builder: (_, __, c) => Page(path: name, child: c),
      load: () => future,
      routes: routes,
    );

class Page extends StatelessComponent {
  Page({required this.path, this.child});

  final String path;
  final Component? child;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    var label = path.startsWith('/') ? path.substring(1) : path;
    yield span([text(label)]);
    if (child != null) {
      yield div([child!]);
    }
  }
}
