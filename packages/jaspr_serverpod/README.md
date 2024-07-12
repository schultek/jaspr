# 🚀 Serverpod integration for jaspr

This package provides a `JasprRoute` to use in your Serverpod webserver to render Jaspr components.

## Setup

Inside your Serverpod `..._server` package perform the following setup steps:

Run in your terminal:

- `dart pub add jaspr jaspr_serverpod`
- `dart pub add --dev build_runner jaspr_web_compilers jaspr_builder`

Add the following to the bottom of `pubspec.yaml`:

```yaml
jaspr:
  mode: server
  dev-command: dart bin/main.dart
```

Move everything from `web/static/` up to `web/`:
```shell
mv web/static/* web/
```

> You can also delete the `web/templates/` directory if you don't need it.

Now edit your `lib/server.dart` to use `RootRoute()` for all paths:

```dart
import 'package:jaspr/jaspr.dart';

// This will be generated when running `jaspr serve` later.
import 'jaspr_options.dart';

// ... Other imports

void run(List<String> args) async {
  
  // ... Other serverpod code

  Jaspr.initializeApp(options: defaultJasprOptions, useIsolates: false);
  
  // If you need other special routes, like authentication redirects, 
  // add them before `RootRoute` above.
  
  // Point all paths to the root route.
  pod.webServer.addRoute(RootRoute(), '/*');
  
  // Remove all other routes like 
  // - `pod.webServer.addRoute(RootRoute(), '...')` 
  // - `pod.webServer.addRoute(RouteStaticDirectory(...), '/*')`

  // ... Other serverpod code
}

```

> The 'lib/jaspr_options.dart' file will be generated when you first run `jaspr serve`.

Then change your root route inside `lib/src/web/routes/root.dart` to this:

```dart
import 'dart:io';

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

Next create the `Home` component inside `lib/components/home.dart`:

```dart
import 'package:jaspr/server.dart';

import 'counter.dart';

class Home extends StatelessComponent {
  const Home({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: "content", [
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
        a(href: "https://docs.page/schultek/jaspr", [text("Jaspr")]),
        text('•'),
        a(href: "https://docs.page/schultek/jaspr/quick-start", [text("Get Started")]),
        text('•'),
        a(href: "https://github.com/schultek/jaspr", [text("Github")]),
      ])
    ]);
  }
}
```

As well as the `Counter` component in `lib/components/counter.dart`:

```dart
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
  Iterable<Component> build(BuildContext context) sync* {
    yield span([text("Count: $counter ")]);
    yield button(onClick: () {
      setState(() {
        counter++;
      });
    }, [
      text("Increase"),
    ]);
  }
}
```

> All Jaspr components must be kept outside of the `src/` directory to function properly!

You are now set to run your server and render a webpage using Serverpod and Jaspr.

---

## Running during development

To start your server, simply run `jaspr serve` in your terminal. 

*This fully replaces the need to run `dart bin/main.dart` during development. However on a fresh project or update
your models, you might need to run `dart bin/main.dart --apply-migrations` from time to time.*

## Building and deploying

To build your project, run `jaspr build -i bin/main.dart` in your terminal.
If you are using docker to deploy your project, modify the `Dockerfile` like this:

```diff
  FROM dart:3.2.5 AS build

  ...

+ RUN dart pub global activate jaspr_cli
  RUN dart pub get
- RUN dart compile exe bin/main.dart -o bin/main
+ RUN jaspr build -i lib/main.dart -v

  ...
  
  FROM busybox:1.36.1-glibc  
  
  ...
  
  COPY --from=build /runtime/ /
- COPY --from=build /app/bin/main /app/bin/main
+ COPY --from=build /app/build/jaspr/app /app/bin/main
  COPY --from=build /app/config/ config/
- COPY --from=build /app/web/ web/
+ COPY --from=build /app/build/jaspr/web/ web/

  ...
```
