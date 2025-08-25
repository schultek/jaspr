# jaspr_router

A simple `Router` component for [`jaspr`](https://github.com/schultek/jaspr)

```shell
dart pub add jaspr_router
```

Use can use the `Router` component for some basic routing. It takes a list of `Route`s.
A simple use looks like this:

```dart
import 'pages/home.dart';
import 'pages/about.dart' ;

class App extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return Router(routes: [
      Route(path: '/', builder: (context, state) => Home()),
      Route(path: '/about', builder: (context, state) => About()),
    ]);
  }
}
```

*jaspr_router is adapted from the `go_router` flutter package. If you know `go_router` a lot of the core concepts
should feel familiar.*

To push a new route call `Router.of(context).push('/path');` inside your child components. Similarly, you can call `.replace()` or `.back()`.

# 🐨 Lazy Routes & Code Splitting

For larger web apps, we don't want to load everything together, but rather split our pages into smaller chunks.
`jaspr` can do this automatically using `LazyRoutes` and deferred imports.

To use lazy routes, change the above code to the following:

```dart
import 'pages/home.dart';
import 'pages/about.dart' deferred as about;

class App extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return Router(
      routes: [
        Route(path: '/', builder: (context, state) => Home()),
        Route.lazy(path: '/about', builder: (context, state) => about.About(), load: about.loadLibrary),
      ],
    );
  }
}
```

This will lazy load the appropriate javascript files for the '/about' route when navigating to it.
