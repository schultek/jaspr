# element_embedding_demo

This package contains the application used to demonstrate the
upcoming Flutter web feature: "Element Embedding" in combination with 
the [jaspr](https://github.com/schultek/jaspr) web framework.

This was first shown on the Flutter Forward event in Nairobi (Kenya), by Tim
Sneath. [See the replay here](https://www.youtube.com/watch?v=zKQYGKAe5W8&t=5799s).
The original implementation can be found [here](https://github.com/flutter/samples/tree/main/experimental/element_embedding_demo)

## Running the demo

The demo is a jaspr app with an embedded flutter web app. 
It can be run with:

```terminal
$ dart run jaspr serve --input=lib/main_jaspr.dart --flutter=lib/main_flutter.dart
```

https://user-images.githubusercontent.com/13920539/216588813-a06ac091-e897-4ebe-a9d4-806bfaf8759d.mov

https://user-images.githubusercontent.com/13920539/216588968-97797efe-47cc-47c7-b686-00fd71b07076.mov

## Building the website + app

The project cal be built with:

```terminal
$ dart run jaspr build --input=lib/main_jaspr.dart --flutter=lib/main_flutter.dart
```

Run the built app with:

```terminal
$ cd build
$ ./app
```

## Points of Interest

* Check the entrypoints for both dart apps
  * For flutter: `lib/main_flutter.dart`
  * For jaspr: `lib/main_jaspr.dart` and `web/main_jaspr.dart`

* Check the new JS Interop:
  * Look at `lib/shared/app_state.dart` and `lib/interop/state.dart`.
  * Find the `appStateProvider` and where it is used
    * `lib/components/interop_controls.dart` for the jaspr app
    * `lib/main_flutter.dart` for the flutter app

* See how the Flutter web application is embedded into the page now:
  * Find `FlutterTarget` in `lib/components/flutter_target.dart`.

_(Original built by @ditman, @kevmoo and @malloc-error)_
_(Pure-Dart version built by @schultek)_
