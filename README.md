# dart_web

Experimental web framework for Dart. Supports SPAs and SSR. 

**Main Features:**

- Familiar component model similar to Flutter widgets
- Easy Server Side Rendering
- Automatic hydration of component data on the client
- Fast incremental DOM updates using [package:domino](https://pub.dev/packages/domino)

> I'm looking for contributors. Don't hesitate to contact me if you want to help in any way.

## Outline

- [Get Started](#get-started)
- [Components](#components)
- [Preloading Data](#preloading-data)
- [Routing](#routing)
  - [Lazy Routes](#lazy-routes)
- [Building](#building)

## Get Started

To get started create a new dart web app using the `web-simple` template with the `dart create` tool:

```shell
dart create -t web-simple my_web_app
cd my_web_app
```

Next you need to activate `webdev` which handles the general serving and building of the web app, and also add `dart_web` as a dependency:

```shell
dart pub global activate webdev
dart pub add dart_web --git-url=https://github.com/schultek/dart_web
```

Now it is time to create your main component, which will be the starting point of your app. Place the following code in `lib/components/app.dart`:

```dart
import 'package:dart_web/dart_web.dart';

class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'p',
      child: Text('Hello World'),
    );
  }
}
```

This will later render a single paragraph element with the content `Hello World`.

Now you need to use this component by passing it to the `runApp` method that is available through `dart_web`.
Since we are effectively building two apps - one in the browser and one on the server - we need separate entry points for this.

1. For the browser app there is already a `main.dart` inside the `web/` folder. Change its content to the following:

```dart
import 'package:dart_web/dart_web.dart';
import 'package:my_web_app/components/app.dart';

void main() {
  runApp(() => App(), id: 'output');
}
```

This will import the `App` component and pass it to `runApp`, together with the id of the root element of our app. 
*Notice that this is the id of the generated `<div id="output"></div>` in the `index.html` file. You can change the id as you like but it must match in both files.*

> If you want to build an SPA, that's all you need. Run `webdev serve` and see your running webapp. Read on for server side rendering

2. For the server app create a new `main.dart` file inside the `lib/` folder and insert the following:

```dart
import 'package:dart_web/dart_web.dart';
import 'components/app.dart';

void main() {
  runApp(() => App(), id: 'output');
}
```

You will notice it is pretty much the same for both entrypoints, and this is by design. 
However you still want to keep them separate for later, when you need to add server or client specific code.

Finally, run the development server using the following command:

```shell
dart run dart_web serve
```

This will spin up a server at `localhost:8080`. You can now start developing your web app. 
Also observe that the browser automatically refreshes the page when you change something in your code, like the `Hello World` text.

**I also highly recommend having a look at the example [here](https://github.com/schultek/dart_web/tree/main/example)**

## Components

`dart_web` uses a similar structure to Flutter in building applications. 
You can define custom stateless or stateful components (not widgets) by overriding the `build()` method, or use inherited components for managing state inside the component tree.

Since html rendering works different to flutters painting approach, here are the core aspects and differences of the component model:

1. The `build()` method returns an `Iterable<Component>` instead of a single component. This is because a html node can always have multiple child nodes.
   The recommended way of using this is with a **synchronous generator**. Simply use the `sync*` keyword in the method definition and `yield` one or multiple components.
   
2. There are two main predefined components that you can use: `DomComponent` and `Text`.
  - `DomComponent` renders a html element with the given tag. You can also set an id, attributes and events. It also takes a child component.
  - `Text` renders some raw html text. It receives only a string and nothing else. *You can style it through the parent element(s), as you normally would in html and css*.

3. A `StatefulComponent` supports preloading some data on the server. See [Preloading Data](#preloading-data) on how to use this feature.
   
## Preloading Data

When using server side rendering, you have the ability to preload data for your stateful components before rendering the html. 
Also when initializing the app on the client, you can access to this data to keep the rendering consistent.

With `dart_web` this is build into the package and easy to do.

Start by using the `PreloadStateMixin` on your component state and set the type argument `T` to the data type that you want to load. 
Note that this type must be json serializable.

```dart
class MyState extends State<MyStatefulComponent> with PreloadStateMixin<MyStatefulComponent, T> {
  
}
```

In your component class, provide a `StateKey` to the super constructor. It takes an id that has to be globally unique.

```dart
class MyStatefulComponent extends StatefulComponent {
   MyStatefulComponent() : super(key: StateKey(id: 'some_unique_id'));

   ...
}
```

To load your state, override the `Future<T> preloadState()` method. This will only be executed on the server and must return a future.
Now inside your component both on the server and client, you can use the `preloadedState` getter to access the preloaded state, e.g. in the `initState()` method.

```dart
@override
void initState() {
  super.initState();
  var myState = preloadedState; // do something with the preloaded state
}
```

## Routing

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
        Route('/', (context) => Home()),
        Route('/about', (context) => About()),
      ],
    );
  }
}
```

To push a new route call `Router.of(context).push('/path');` inside your child components. Similarly you can call `.replace()` or `.back()`.

### Lazy Routes

For larger web apps, we don't want to load everything together, but rather split our pages into smaller chunks.
`dart_web` can do this automatically using `LazyRoutes` and deferred imports.

To use lazy routes, change the above code to the following:

```dart
import 'pages/home.dart' deferred as home;
import 'pages/about.dart' deferred as about;

class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Router(
      routes: [
        Route.lazy('/', (context) => home.Home(), home.loadLibrary),
        Route.lazy('/about', (context) => About(), about.loadLibrary),
      ],
    );
  }
}
```

This will lazy load the appropriate javascript files for each route when navigating to it. 
You can also mix normal and lazy routes.

## Building

You can build your application using the following command:

```shell
dart run dart_web build
```

This will build the app inside the `build` directory. 
You can choose whether to build a standalone executable or an aot or jit snapshot with the `--target` option.

To run your built application do:

```shell
cd build
./app
```