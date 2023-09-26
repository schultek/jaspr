# Flutter Element Embedding Demo

This package contains the application used to demonstrate the
new Flutter web feature: "Element Embedding" in combination with 
the [jaspr](https://github.com/schultek/jaspr) web framework.

This was first shown on the Flutter Forward event in Nairobi (Kenya), by Tim
Sneath. [See the replay here](https://www.youtube.com/watch?v=zKQYGKAe5W8&t=5799s).
The original implementation can be found [here](https://github.com/flutter/samples/tree/main/web_embedding/element_embedding_demo)

## Running the demo

The demo is a jaspr app with an embedded flutter web app. 
It can be run with:

```terminal
$ jaspr serve
```

https://user-images.githubusercontent.com/13920539/216588813-a06ac091-e897-4ebe-a9d4-806bfaf8759d.mov

https://user-images.githubusercontent.com/13920539/216588968-97797efe-47cc-47c7-b686-00fd71b07076.mov

## Building the website + app

The project can be built with:

```terminal
$ jaspr build
```

Run the built app with:

```terminal
$ ./build/jaspr/app
```

## Points of Interest

* Check the files for both dart apps
  * For flutter: `lib/widgets/app.dart`
  * For jaspr: `lib/components/app.dart`

* See how the Flutter web application is embedded into the page now:
  * Find `FlutterAppContainer` in `lib/components/flutter_app_container_web.dart`.
  * Find `FlutterEmbedView` in `lib/components/flutter_target.dart`.

* Check the new data binding:
  * Look at the usage of `ProviderScope` in `lib/components/flutter_app_container_web.dart`.
  * Find the `appStateProvider` and where it is used
    * `lib/components/interop_controls.dart` for the jaspr app
    * `lib/widgets/app.dart` for the flutter app

_(Original built by @ditman, @kevmoo and @malloc-error)_
_(Pure-Dart version built by @schultek)_
