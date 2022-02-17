# jaspr

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

Next you need to activate `webdev` which handles the general serving and building of the web app, and also add `jaspr` as a dependency:

```shell
dart pub global activate webdev
dart pub add jaspr --git-url=https://github.com/schultek/jaspr --git-path=jaspr
```

Now it is time to create your main component, which will be the starting point of your app. Place the following code in `lib/app.dart`:

```dart
import 'package:jaspr/jaspr.dart';

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

Now you need to use this component by passing it to the `runApp` method that is available through `jaspr`.

`Change the content of `web/main.dart to the following:

```dart
import 'package:jaspr/jaspr.dart';
import 'package:my_web_app/app.dart';

void main() {
  runApp(() => App(), id: 'output');
}
```

This will import the `App` component and pass it to `runApp`, together with the id of the root element of our app. 
*Notice that this is the id of the generated `<div id="output"></div>` in the `index.html` file. You can change the id as you like but it must match in both files.*

Finally, run the development server using the following command:

```shell
dart run jaspr serve
```

This will spin up a server at `localhost:8080`. You can now start developing your web app. 
Also observe that the browser automatically refreshes the page when you change something in your code, like the `Hello World` text.

**I also highly recommend having a look at the example [here](https://github.com/schultek/jaspr/tree/main/example)**

## Components

`jaspr` uses a similar structure to Flutter in building applications. 
You can define custom stateless or stateful components (not widgets) by overriding the `build()` method, or use inherited components for managing state inside the component tree.

Since html rendering works different to flutters painting approach, here are the core aspects and differences of the component model:

1. The `build()` method returns an `Iterable<Component>` instead of a single component. This is because a html node can always have multiple child nodes.
   The recommended way of using this is with a **synchronous generator**. Simply use the `sync*` keyword in the method definition and `yield` one or multiple components.
   
2. There are two main predefined components that you can use: `DomComponent` and `Text`.
  - `DomComponent` renders a html element with the given tag. You can also set an id, attributes and events. It also takes a child component.
  - `Text` renders some raw html text. It receives only a string and nothing else. *You can style it through the parent element(s), as you normally would in html and css*.

3. A `StatefulComponent` supports preloading some data on the server and automatic syncing data with the client. See [Preloading Data](#preloading-data) and [Syncing Data](#sync-data) on how to use this feature.
   
## Preloading Data

When using server side rendering, you have the ability to preload data for your stateful components before rendering the html.
With `jaspr` this is build into the package and easy to do.

Start by using the `PreloadStateMixin` on your component state and implement the `Future<T> preloadState()` method.

```dart
class MyState extends State<MyStatefulComponent> with PreloadStateMixin<MyStatefulComponent> {
  
  @override
  Future<void> preloadState() async {
    ...
  }
}
```

## Syncing Data

Alongside with preloading some data on the server, you often want to sync the data with the client.
You can simply add the `SyncStateMixin` which will automatically sync state from the server with the client.

The `SyncStateMixin` accepts a second type argument for the data type that you want to sync. You the have to
implement the the `saveState` and `updateState()` methods.

```dart
class MyState extends State<MyStatefulComponent> with SyncStateMixin<MyStatefulComponent, MyStateModel> {

  MyStateModel? model;
  
  // a globally unique id that is used to identify the state
  @override
  String get syncId => 'my_id';

  // this will save the state to be sent to the client
  // and is only executed on the server
  @override
  MyStateModel? saveState() {
    return model;
  }

  // this will receive the state on the client
  // and it is safe to call setState
  void updateState(MyStateModel? value) {
    setState(() {
      model = value;
    });
  }
}
```

In order to send the data, it needs to be serialized on the server and deserialized on the client.
The serialization format is defined by the `syncCodec` getter defined in `SyncStateMixin`.

By default, this is set to `StateJsonCodec()` which will encode your state to JSON. Be aware that this 
only works for JSON-encodable types, like primitives, `List`s and `Map`s.

When you want to use another type like a custom model class, you have to override the `syncCodec` getter, which
has to return a `Codec` that encodes to `String`. This can be any codec, however a typical use would be to 
encode your model to `Map<String, dynamic>` and the fuse this with the json codec to get a json string.

```dart

class MyState extends State<MyStatefulComponent> with SyncStateMixin<MyStatefulComponent, MyStateModel> {

  @override
  Codec<MyStateModel, String> get syncCodec => MyStateModelCodec().fuse(StateJsonCodec());

  ...
}

// codec that encodes a value of MyStateModel to Map<String, dynamic>
class MyStateModelCodec extends Codec<MyStateModel, Map<String, dynamic>> {
  
  ...
  
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
dart run jaspr build
```

This will build the app inside the `build` directory. 
You can choose whether to build a standalone executable or an aot or jit snapshot with the `--target` option.

To run your built application do:

```shell
cd build
./app
```