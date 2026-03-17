![Banner](https://raw.githubusercontent.com/schultek/jaspr/main/assets/banner.png)

<p align="center">
  <a href="https://pub.dev/packages/jaspr"><img src="https://img.shields.io/pub/v/jaspr?label=pub.dev&labelColor=333940&logo=dart&color=00589B" alt="pub"></a>
  <a href="https://github.com/schultek/jaspr"><img src="https://img.shields.io/github/stars/schultek/jaspr?style=flat&label=stars&labelColor=333940&color=8957e5&logo=github" alt="github"></a>
  <a href="https://github.com/schultek/jaspr/actions/workflows/test.yml"><img src="https://img.shields.io/github/actions/workflow/status/schultek/jaspr/test.yml?branch=main&label=tests&labelColor=333940&logo=github" alt="tests"></a>
  <a href="https://app.codecov.io/gh/schultek/jaspr"><img src="https://img.shields.io/codecov/c/github/schultek/jaspr?logo=codecov&logoColor=fff&labelColor=333940" alt="codecov"></a>
  <a href="https://discord.gg/XGXrGEk4c6"><img src="https://img.shields.io/discord/993167615587520602?logo=discord&logoColor=fff&labelColor=333940" alt="discord"></a>
  <a href="https://github.com/schultek/jaspr"><img src="https://img.shields.io/github/contributors/schultek/jaspr?logo=github&labelColor=333940" alt="contributors"></a>
</p>

<p align="center">
  <a href="https://jaspr.site">Website</a> •
  <a href="https://docs.jaspr.site/quick_start">Quickstart</a> •
  <a href="https://docs.jaspr.site">Documentation</a> •
  <a href="https://playground.jaspr.site">Playground</a> •
  <a href="https://github.com/schultek/jaspr/tree/main/examples/">Examples</a> •
  <a href="https://jaspr-benchmarks.web.app">Benchmarks</a>
</p>

<p align="center">
  <a href="https://github.com/sponsors/schultek"><img src="https://img.shields.io/badge/sponsor-30363D?style=for-the-badge&logo=GitHub-Sponsors&logoColor=#white" alt="sponsor"></a>
</p>

# Jaspr

> A modern web framework for building websites in Dart with support for both **client-side** and **server-side rendering**.

- 🔮 **Why?**: Jaspr was made with the premise to make a web-framework that looks and feels just like Flutter, but renders normal HTML and CSS like React or Vue.
- 👥 **Who?**: Jaspr is targeted mainly at Flutter developers that want to build any type of websites (especially ones that are not suitable for Flutter Web).
- 🚀 **What?**: Jaspr wants to push the boundaries of Dart on the web and server, by giving you a thought-through fullstack web framework written completely in Dart.

> Want to contribute to Jaspr? Join our open [Discord Community](https://discord.gg/XGXrGEk4c6) of developers around Jaspr and check out the [Contributing Guide](https://docs.jaspr.site/going_further/contributing).

### Core Features

- 💙 **Familiar**: Works with a similar component model to flutter widgets.
- 🏗 **Powerful**: Comes with server side rendering out of the box.
- ♻️ **Easy**: Syncs component state between server and client automatically.
- ⚡️ **Fast**: Performs optimized DOM updates only where needed.
- 🎛 **Flexible**: Runs on the server, client or both with manual or automatic setup. You decide.

> If you want to say thank you, star the project on GitHub and like the package on pub.dev 🙌💙

### Online Editor & Playground

Inspired by DartPad, **Jaspr** has it's own online editor and playground, called **JasprPad**.

[Check it out here!](https://playground.jaspr.site)

You can check out the samples, take the tutorial or try out jaspr for yourself, all live in the browser.
When you want to continue coding offline, you can quickly download the current files bundled in a complete dart project, ready to start coding locally.

JasprPad is also built with **Jaspr** itself, so you can [**check out its source code**](https://github.com/schultek/jaspr/tree/main/apps/jaspr_pad) to get a feel for how jaspr would be used in a larger app.

![JasprPad Screenshot](https://user-images.githubusercontent.com/13920539/170837732-9e09d5f3-e79e-4ddd-b118-72e49456a7cd.png)

## Outline

- [Get Started](#-get-started)
- [CLI Tool](#-jaspr-cli)
- [Framework](#framework)
- [Differences to Flutter(-Web)](#differences-to-flutter-web)
- [Building](#building)
- [Testing](#testing)

## 🛫 Get Started

To get started simply activate the `jasper_cli` command line tool and run `jaspr create`:

```shell
dart pub global activate jaspr_cli
jaspr create my_website
```

Next, run the development server using the following command:

```shell
cd my_website
jaspr serve
```

This will spin up a server at `localhost:8080`. You can now start developing your web app. 
Also observe that the browser automatically refreshes the page when you change something in your code, like the `Hello World` text.

## 🕹 Jaspr CLI

Jaspr comes with a cli tool to create, serve and build your website.

- `jaspr create` will create a new jaspr project. The cli will prompt you for a project name and setup options.
- `jaspr serve` will serve the website in the current directory, including hot-reloading.
- `jaspr build` will build the website containing the static assets (compiled js, html, images, etc.) and the optional server executable.

## Framework

Jaspr was developed with the premise to look and feel just like Flutter. Therefore when you know Flutter
you probably already know jaspr (in large parts).

The core building block of UIs build with jaspr are **Components**. These are just what you know 
as **Widgets** from Flutter. jaspr comes with all three base types of Components, namely:

- **StatelessComponent**: A basic component that has a single build method.
- **StatefulComponent**: A component that holds state and can trigger rebuilds using `setState()`.
- **InheritedComponent**: A component that can notify its dependents when its state changes.

In addition to these base components, there are also all **html** elements available as components:

```dart
div([
  h1([text('Welcome to Jaspr')]),
  p([text('This is some basic html!')])]),
]);
```

[Check the Docs for more](https://docs.jaspr.site)

## Differences to Flutter(-Web)

As you might know Flutter renders Widgets by manually painting pixels to a canvas. However rendering web-pages
with HTML & CSS works fundamentally different to Flutters painting approach. Also Flutter has a vast variety
of widgets with different purposes and styling, whereas in html you can uniquely style each html element however
you like.

Instead of trying to mirror every little thing from Flutter, `jaspr` tries to give a general Fluttery feeling
by matching features where it makes sense without compromising on the unique properties of the web platform.
Rather it embraces these differences to give the best of both worlds.

1. Jaspr does not care about the styling of components. There are (currently) no prestyled components
   like in Flutters material or cupertino libraries.
   
   *Trade-Off: Providing styled components would be a lot of extra work and is currently not feasible.
    Also there exist a lot of different, well established CSS frameworks for web that you can already
    integrate and use with jaspr (e.g. [Bulma](https://playground.jaspr.site/?sample=bulma).*
   
2. `Text` receives only a `String` and nothing else. As usual for web, styling is done through a combination
   of CSS attributes, either in a **Stylesheet** or though the **`style` attribute** of the parent elements. 
   
   *Trade-Off: Giving `Text` a style option would be superficial and not native to web, and thereby not
    a good practice.*
   
## Building

You can build your application using the following command:

```shell
jaspr build
```

This will build the app inside the `build/jaspr` directory.

## Testing

`jaspr` comes with it's own testing package `jaspr_test`.
It is built as a layer on top of `package:test` and has a similar api to `flutter_test`.

A simple component test looks like this:

```dart
// This also exports 'package:test' so no need for an additional import.
import 'package:jaspr_test/jaspr_test.dart';

// Import the components that you want to test.
import 'my_component.dart';

void main() {
  group('simple component test', () {
    testComponents('renders my component', (tester) async {
      // We want to test the MyComponent component.
      // Assume this shows a count and a button to increase it.
      tester.pumpComponent(MyComponent());

      // Should render a [Text] component with content 'Count: 0'.
      expect(find.text('Count: 0'), findsOneComponent);

      // Searches for the <button> element and simulates a click event.
      await tester.click(find.tag('button'));

      // Should render a [Text] component with content 'Count: 1'.
      expect(find.text('Count: 1'), findsOneComponent);
    });
  });
}
```

For more examples on how to use the testing package, check out the 
[documentation](https://docs.jaspr.site/dev/testing) and the 
[tests in the jaspr package](https://github.com/schultek/jaspr/tree/main/packages/jaspr/test).
