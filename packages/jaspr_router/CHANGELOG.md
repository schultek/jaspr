## 0.8.1

- `jaspr` upgraded to `0.22.0`

## 0.8.0

- Using a `redirect` function on `Router` or `Route` while rendering on the server will now trigger a HTTP redirect (302) instead of rendering the target page.

## 0.7.3

- `jaspr` upgraded to `0.21.1`
- `jaspr_test` upgraded to `0.21.1`

## 0.7.2

- `jaspr` upgraded to `0.21.0`
- `jaspr_test` upgraded to `0.21.0`

## 0.7.1

- `jaspr` upgraded to `0.20.0`

## 0.7.0

- Added `settings` parameter to `Route` for specifying sitemap settings like `priority` and `changefreq`.

## 0.6.4

- Fixed bug with router redirects.

## 0.6.3

- `jaspr` upgraded to `0.18.0`

## 0.6.2

- Update logo and website links.

## 0.6.1

- `jaspr` upgraded to `0.17.0`

## 0.6.0

- **BREAKING** Migrate to `package:web`.

## 0.5.1

- `jaspr` upgraded to `0.15.0`

## 0.5.0

- Changed the signature of the `Link` component, `children` is now a named parameter.

## 0.4.2

- The title of the browser tab will no be properly set to the `title` of the current route.
- Fixed race condition where routes were skipped during static rendering.

## 0.4.1

- Fixed issue where `replaceNamed` from `GoRouterHelper` was not passing parameters correctly.
- Fixed bug with redirects on the server.

## 0.4.0

- Added `Link` component to simplify router-aware navigation.
  
  The `Link` component lets the user navigate to another route by clicking or tapping on it. It uses client-side routing 
  if possible and fall back to the default browser navigation if no `Router` component is present in the tree. It will render 
  an accessible `<a>` element with a valid `href`, which means that things like right-clicking a `Link` work as you'd expect.

- Fixed redirects on initial load.
- Fixed proper handling of `<base>` path.

## 0.3.1

- `jaspr` upgraded to `0.10.0`

## 0.3.0

- Added *Static Site Generation* support. Pages are automatically generated for each route.

- Fixed bug where `Router.of(context).matchList.title` always returned null.

## 0.2.3

- `jaspr` upgraded to `0.8.0`

## 0.2.2

- `jaspr` upgraded to `0.7.0`

## 0.2.1

- `jaspr` upgraded to `0.6.0`

## 0.2.0

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
