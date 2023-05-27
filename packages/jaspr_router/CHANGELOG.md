## Unreleased breaking

- **BREAKING** Complete overhaul of the router package.

  *The router implementation is mainly adapted from the go_router package for Flutter.*

  Routing works by providing a set of routes to the router component. You can choose between a normal 
  `Route` and a `ShellRoute`. A `ShellRoute` acts as a layout wrapper around the child routes.
  
  Each `Route` takes a path which can contain parameters like `'/users/:userId'`.
  
  Both `Route` and `ShellRoute` have a `.lazy` variant used for lazy-loading parts of the application.

  ```dart
    Router(routes: [
      // simple routes
      Route(path: '/', builder: (context, state) => HomePage()),
      Route(path: '/about', builder: (context, state) => AboutPage()),
      // route with a path parameter
      Route(path: '/users/:userId', builder: (context, state) => UserPage(id: state.pathParameters['userId'])),
      // nested routes
      Route(path: '/base', builder: (context, state) => BasePage(), routes: [
        // full location will be '/base/details'
        Route(path: 'details', builder: (context, state) => DetailsPage()),
      ]),
      // shell route
      ShellRoute(
        builder: (context, state, child) => CustomLayout(child: child),
        routes: [
          Route(path: '/dashboard', builder: (context, state) => DashboardPage()),
        ]     
      ),
      // lazy loaded route
      // this assumes a deferred import like "import 'posts.dart' deferred as posts;"
      Route.lazy(path: '/posts', builder: (context, state) => posts.Posts(), load: posts.loadLibrary),
      // lazy loaded shell route
      ShellRoute.lazy(
        builder: (context, state, child) => CustomLayout(child: child),
        load: () => someAsyncTask(),
        routes: [
          Route(path: '/data', builder: (context, state) => DataPage()),
        ]
      )     
    ]);
  ```
  
  While the router docs are work in progress, you can refer to the [go_router docs](https://pub.dev/documentation/go_router/latest/topics/Configuration-topic.html)
  for some references (don't expect everything to work exactly the same, but the core concepts are similar).

## 0.1.1

- `jaspr` upgraded to `0.4.0`

## 0.1.0

- Initial version.
