# jaspr_router

A simple `Router` component for [`jaspr`](https://github.com/schultek/jaspr)

```shell
dart pub add jaspr_router
```

Use can use the `Router` component for some basic routing. It takes a list of `Route`s or
optionally a `onGenerateRoute` callback.

A simple use looks like this:

```dart
import 'pages/home.dart';
import 'pages/about.dart' ;

class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Router(
      routes: [
        Route('/', (context) => [Home()]),
        Route('/about', (context) => [About()]),
      ],
    );
  }
}
```

To push a new route call `Router.of(context).push('/path');` inside your child components. Similarly you can call `.replace()` or `.back()`.

# 🐨 Lazy Routes & Code Splitting

For larger web apps, we don't want to load everything together, but rather split our pages into smaller chunks.
`jaspr` can do this automatically using `LazyRoutes` and deferred imports.

To use lazy routes, change the above code to the following:

```dart
import 'pages/home.dart' deferred as home;
import 'pages/about.dart' deferred as about;

class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Router(
      routes: [
        Route.lazy('/', (context) => [home.Home()], home.loadLibrary),
        Route.lazy('/about', (context) => [about.About()], about.loadLibrary),
      ],
    );
  }
}
```

This will lazy load the appropriate javascript files for each route when navigating to it.
You can also mix normal and lazy routes.
