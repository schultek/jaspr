# Setup

> This setup guide assumes you have an existing Serverpod project.
> It will integrate Jaspr in this project for rendering your website.

## Installing

Inside your Serverpod `..._server` package perform the following setup steps:

Add all the necessary dependencies to Jaspr and related packages:

- `dart pub add jaspr jaspr_serverpod`
- `dart pub add --dev build_runner jaspr_web_compilers jaspr_builder`

## Project Setup

Add the following to the bottom of `pubspec.yaml`:

```yaml
jaspr:
  mode: server
  port: 8082
```

Move everything from `web/static/` up to `web/`:
```shell
mv web/static/* web/
rm -d web/static/
```

> You can also delete the `web/templates/` directory if you don't need it.

Finally rename `lib/server.dart` to `lib/main.server.dart` and delete `bin/main.dart`.

## Route Setup

Edit your `lib/main.server.dart` to:

- import `package:jaspr/server.dart`,
- contain the `main()` method (previously named `run()`),
- initialize Jaspr and
- use `RootRoute()` for all paths.

```dart
import 'package:jaspr/server.dart';

// This file will be generated when running `jaspr serve` later.
import 'main.server.g.dart';

// ... Other imports

// Renamed from `run` to `main`.
void main(List<String> args) async {
  
  // ... Other serverpod code

  Jaspr.initializeApp(options: defaultServerOptions);
  
  // If you need other special routes, like authentication redirects, 
  // add them here.
  
  // Point all paths to the root route.
  pod.webServer.addRoute(RootRoute(), '/*');
  
  // Remove all other routes like 
  // - `pod.webServer.addRoute(RootRoute(), '...')` 
  // - `pod.webServer.addRoute(RouteStaticDirectory(...), '/*')`

  // ... Other serverpod code
}

```

> The 'lib/main.server.g.dart' file will be generated when you first run `jaspr serve`.

Then change your root route inside `lib/src/web/routes/root.dart` to this:

```dart
import 'dart:io';

import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:jaspr_serverpod/jaspr_serverpod.dart';
import 'package:serverpod/serverpod.dart';

import '/components/home.dart';

class RootRoute extends JasprRoute {
  @override
  Future<Component> build(Session session, HttpRequest request) async {
    return Document(
      title: "Built with Serverpod & Jaspr",
      head: [
        link(rel: "stylesheet", href: "/css/style.css"),
      ],
      body: Home(),
    );
  }
}
```

## Component Setup

Next create the `Home` component inside `lib/components/home.dart`:

```dart
import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import 'counter.dart';

class Home extends StatelessComponent {
  const Home({super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: "content", [
      div(classes: "logo-box", [
        img(
          src: "/images/serverpod-logo.svg",
          width: 160,
          styles: Styles.box(margin: EdgeInsets.only(top: 8.px, bottom: 12.px)),
        ),
        p([
          a(href: "https://serverpod.dev/", [text("Serverpod + Jaspr")])
        ])
      ]),
      hr(),
      div(classes: "info-box", [
        p([text("Served at ${DateTime.now()}")]),
        div(id: "counter", [Counter()]),
      ]),
      hr(),
      div(classes: "link-box", [
        a(href: "https://serverpod.dev", [text("Serverpod")]),
        text('•'),
        a(href: "https://docs.serverpod.dev", [text("Get Started")]),
        text('•'),
        a(href: "https://github.com/serverpod/serverpod", [text("Github")]),
      ]),
      div(classes: "link-box", [
        a(href: "https://docs.jaspr.site", [text("Jaspr")]),
        text('•'),
        a(href: "https://docs.jaspr.site/quick-start", [text("Get Started")]),
        text('•'),
        a(href: "https://github.com/schultek/jaspr", [text("Github")]),
      ])
    ]);
  }
}
```

As well as the `Counter` component in `lib/components/counter.dart`:

```dart
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

@client
class Counter extends StatefulComponent {
  const Counter({super.key});

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int counter = 0;

  @override
  Component build(BuildContext context) {
    return div([
      span([text("Count: $counter ")]),
      button(onClick: () {
        setState(() {
          counter++;
        });
      }, [
        text("Increase"),
      ]),
    ]);
  }
}
```

> All Jaspr components must be kept outside the `src/` directory to function properly!

## Client Setup

Finally, to setup hydration on the client, create a `lib/main.client.dart` file with the following content:

```dart
// The entrypoint for the **client** environment.
//
// The [main] method will only be executed on the client after loading the page.

// Client-specific Jaspr import.
import 'package:jaspr/client.dart';

// This file is generated automatically by Jaspr, do not remove or edit.
import 'main.client.g.dart';

void main() {
  // Initializes the client environment with the generated default options.
  Jaspr.initializeApp(
    options: defaultClientOptions,
  );

  // Starts the app.
  //
  // [ClientApp] automatically loads and renders all components annotated with @client.
  //
  // You can wrap this with additional [InheritedComponent]s to share state across multiple
  // @client components if needed.
  runApp(
    const ClientApp(),
  );
}
```

---

You are now set to run your server and render your website using Serverpod and Jaspr. 

To start **both** the Jaspr development server and run Serverpod in debug mode, use the following command:

```shell
jaspr serve
```

To pass command line arguments to your serverpod server (like `--apply-migrations`) add an additional `--` before the arguments:

```shell
jaspr serve -- --apply-migrations
```

Check the [Jaspr Docs](https://docs.jaspr.site) and [Serverpod Docs](https://docs.serverpod.dev/) for more information.
