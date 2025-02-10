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
  dev-command: dart bin/main.dart --apply-migrations
```

Move everything from `web/static/` up to `web/`:
```shell
mv web/static/* web/
rm -d web/static/
```

> You can also delete the `web/templates/` directory if you don't need it.

## Route Setup

Now edit your `lib/server.dart` to initialize Jaspr and use `RootRoute()` for all paths:

```dart
import 'package:jaspr/jaspr.dart';

// This file will be generated when running `jaspr serve` later.
import 'jaspr_options.dart';

// ... Other imports

void run(List<String> args) async {
  
  // ... Other serverpod code

  Jaspr.initializeApp(options: defaultJasprOptions, useIsolates: false);
  
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

## Component Setup

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

> All Jaspr components must be kept outside the `src/` directory to function properly!

---

You are now set to run your server and render your website using Serverpod and Jaspr. 

Check the [Jaspr Docs](https://docs.jaspr.site) and [Serverpod Docs](https://docs.serverpod.dev/) for more information.
