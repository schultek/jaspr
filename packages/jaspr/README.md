# jaspr

Experimental web framework for Dart. Supports SPAs and SSR.

**Main Features:**

- Familiar component model similar to Flutter widgets
- Easy Server Side Rendering
- Automatic hydration of component data on the client
- Fast incremental DOM updates
- Well tested (>70% test coverage)

> I'm looking for contributors. Don't hesitate to contact me if you want to help in any way.

## Outline

- [Get Started](#get-started)
- [CLI Tool](#cli-tool)
- [Framework](#framework)
  - [Components](#components)
  - [Differences to Flutter](#differences-to-flutter)
  - [Preloading Data](#preloading-data)
  - [Syncing Data](#syncing-data)
  - [Routing](#routing)
    - [Lazy Routes](#lazy-routes)
- [Building](#building)
- [Testing](#testing)

## Get Started

To get started simply activate the `jasper` command line tool and run `jaspr create`:

```shell
dart pub global activate jaspr
jaspr create my_web_app
```

Next, run the development server using the following command:

```shell
cd my_web_app
dart run jaspr serve
```

This will spin up a server at `localhost:8080`. You can now start developing your web app. 
Also observe that the browser automatically refreshes the page when you change something in your code, like the `Hello World` text.

**I also highly recommend having a look at the example [here](https://github.com/schultek/jaspr/tree/main/jaspr/example)**

## CLI Tool

Jaspr comes with a cli tool to create, serve and build your web app.

- `jaspr create my_web_app` will create a new jaspr project inside the `my_web_app` directory
- `jaspr serve` will serve the web-app in the current directory, including hot-reloading
- `jaspr build` will build the web-app containing the static web assets (compiled js, html, ...) and the server executable

## Framework

Jaspr was developed with the premise to look and feel just like Flutter. Therefore when you know Flutter
you probably already know jaspr.

### Components

The core building block of UIs build with jaspr are **Components**. These are just what you know 
as **Widgets** from Flutter. jaspr comes with all three base types of Components, namely:

- **StatelessComponent**: A basic component that has a single build method.
- **StatefulComponent**: A component that holds state and can trigger rebuilds using `setState()`.
- **InheritedComponent**: A component that can notify its dependents when its state changes.

In addition to these base components, there are two more components that don't exist in Flutter:

- **DomComponent**: A component that renders any HTML element given a tag, attributes and events.
  ```dart
  var component = DomComponent(
    tag: 'div',
    id: 'my-id',
    classes: ['class-a', 'class-b'],
    attributes: {'my-attribute': 'my-value'},
    events: {'click': (e) => print('clicked')},
    children: [
      ...
    ],
  );
  ```
  
- **Text**: A simple component that renders a text node.
  `var text = Text('Hello World!');`


### Differences to Flutter

As you might know Flutter renders Widgets by manually painting pixels to a canvas. However rendering web-pages
with HTML & CSS works fundamentally different to Flutters painting approach. Also Flutter has a vast variety
of widgets with different purposes and styling, whereas in html you can uniquely style each html element however
you like.

Instead of trying to mirror every little thing from Flutter, `jaspr` tries to give a general Fluttery feeling
by matching features where it makes sense without compromising on the unique properties of the web platform.
Rather it embraces these differences to give the best of both worlds.

1. The `build()` method of a `StatelessComponent` or `StatefulComponent` returns an `Iterable<Component>` 
   instead of a single component. This is because a HTML element can always have multiple child elements.
   The recommended way of using this is with a [**synchronous generator**](https://dart.dev/guides/language/language-tour#generators). 
   Simply use the `sync*` keyword in the method definition and `yield` one or multiple components:
   
   ```dart
   class MyComponent extends StatelessComponent {
     @override
     Iterable<Component> build(BuildContext context) sync* {
       yield ChildA();
       yield ChildB();
     } 
   }
   ```
   
   *Trade-Off: Returning a single component and having an extra multi-child component would be superficial 
   to how html works and thereby not a good practice.*
   
2. Jaspr does not care about the styling of components. There are (currently) no prestyled components
   like in Flutters material or cupertino libraries.
   
   *Trade-Off: Providing styled components would be a lot of extra work and is currently not feasible.
    Also there exist a lot of different, well established CSS frameworks for web that you can already
    integrate and use with jaspr (e.g. [Bulma](https://jasprpad.schultek.de/?sample=bulma).*
   
3. `Text` receives only a `String` and nothing else. As usual for web, styling is done through a combination
   of CSS attributes, either in a **Stylesheet** or though the **`style` attribute** of the parent elements. 
   
   *Trade-Off: Giving `Text` a style option would be superficial and not native to web, and thereby not
    a good practice.*
   

### Preloading Data

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

### Syncing Data

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

### Routing

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

#### Lazy Routes

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

## Testing

`jaspr` comes with it's own testing package `jaspr_test`.

A simple component test looks like this:

```dart
import 'package:jaspr_test/jaspr_test.dart';

import 'app.dart';

void main() {
  group('simple component test', () {
    late ComponentTester tester;

    setUp(() {
      tester = ComponentTester.setUp();
    });

    test('should render component', () async {
      await tester.pumpComponent(App());

      expect(find.text('Count: 0'), findsOneComponent);

      await tester.click(find.tag('button'));

      expect(find.text('Count: 1'), findsOneComponent);
    });
  });
}
```

For more examples on how to use the testing package, check out the [tests in the jaspr package](https://github.com/schultek/jaspr/tree/main/jaspr/test).