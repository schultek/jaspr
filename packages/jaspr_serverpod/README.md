# 🚀 Serverpod integration for Jaspr

This package provides an integration between [Jaspr](https://github.com/schultek/jaspr) and [Serverpod](https://serverpod.dev).

It provides:
- `JasprRoute` to use in your Serverpod webserver to server-side render Jaspr components.
- `context.session` extension to get the `Session` inside a components `build()` method. 
- `JasprConnectivityMonitor` for your generated Serverpod client.

Follow the setup below or check out one of our examples:
- [Basic Example](https://github.com/schultek/jaspr/tree/main/examples/backend_serverpod)
- [Full Demo Project](https://github.com/schultek/jaspr/tree/main/apps/dart_quotes_server)

## Setup

Refer to our official [Setup Guide](https://pub.dev/documentation/jaspr_serverpod/latest/topics/Setup-topic.html) on how to integrate Jaspr with Serverpod.

## Running during development

After you have [setup](https://pub.dev/documentation/jaspr_serverpod/latest/topics/Setup-topic.html) the integration, simply run `jaspr serve` in your terminal to start **both** the Jaspr development server and run Serverpod in debug mode. 

*This fully replaces the need to run `dart bin/main.dart` during development. To pass additional arguments to Serverpod, use an additional `--` before the arguments, for example: `jaspr serve -- --apply-migrations`.*

## Building and deploying

To build your project, run `jaspr build -i bin/main.dart` in your terminal.
If you are using docker to deploy your project, modify the `Dockerfile` like this:

```diff
  FROM dart:3.2.5 AS build

  ...

+ RUN dart pub global activate jaspr_cli
  RUN dart pub get
- RUN dart compile exe bin/main.dart -o bin/main
+ RUN jaspr build -i bin/main.dart -v

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
