# dart_web

Experimental web framework for Dart. Supports SPA and SSR. 
Relies on [package:domino](https://pub.dev/packages/domino) and its incremental dom rendering approach for dynamic updates.

**Features:**

- Server Side Rendering
- Component model similar to Flutter
- Automatic hydration of component data in client

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
  runApp(App(), id: 'output');
}
```

This will import the `App` component and pass it to `runApp`, together with the id of the root element of our app. 
*Notice that this is the id of the generated `<div id="output"></div>` in the `index.html` file. You can change the id as you like but it must match in both files.*

2. For the server app create a new `main.dart` file inside the `lib/` folder and insert the following:

```dart
import 'package:dart_web/dart_web.dart';
import 'components/app.dart';

void main() {
  runApp(App(), id: 'output');
}
```

You will notice it is pretty much the same for both entrypoints, and this is by design. 
However you still want to keep them separate for later, when you need to add platform specific code.

Finally, run the development server using the following command:

```shell
dart run dart_web serve
```

This will spin up a server at `localhost:8080`. You can now start developing your web app. 
Also observe that the browser automatically refreshes the page when you change something in your code, like the `Hello World` text.


## Components

`dart_web` uses a similar structure to Flutter in building applications. 
You can define custom stateless or stateful components (not widgets) by overriding its `build()` method.

Since html rendering works different to flutters painting approach, here are the core aspects and differences of the component model:

1. The `build()` method returns an `Iterable<Component>` instead of a single component. This is because a html node can always have multiple child nodes.
   The recommended way of using this is with a **synchronous generator**. Simply use the `sync*` keyword in the method definition and `yield` one or multiple components.
   
2. There are only two existing components that you can use: `DomComponent` and `Text`.
  - `DomComponent` renders a html element with the given tag. You can also set an id, attributes and events. It also takes a child component.
  - `Text` renders some raw html text. It receives only a string and nothing else. *Style it through the parent element(s), as you normally would in html and css*.

3. The `State` of a `StatefulComponent` supports preloading some data on the server. To use this feature, override the `FutureOr<T?> preloadData()` method. See [Preloading Data](#preloading-data).
   
## Preloading Data

When using server side rendering, you have the ability to preload data for your components before rendering the html. 
Also when initializing the app on the client, we need access to this data to keep the rendering consistent.

With `dart_web` this is build into the package and easy to do.

First, when defining your `State` class for a `StatefulComponent`, it takes an additional type argument referring to the data type that you want to load: `class MyState extends State<MyStatefulWidget, T>`. 
Note that this type must be json serializable. 

To load your data, override the `FutureOr<T?> preloadData()` method. This will only be executed on the server and can return a future.

Now when overriding `initState(T? data)` you receive an additional parameter containing the loaded data, both on the server and on the client.

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