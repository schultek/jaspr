# element_embedding_demo

This package contains the application used to demonstrate the
upcoming Flutter web feature: "Element Embedding".

This was first shown on the Flutter Forward event in Nairobi (Kenya), by Tim
Sneath. [See the replay here](https://www.youtube.com/watch?v=zKQYGKAe5W8&t=5799s).

## Running the demo

The demo is a Jaspr app with an embedded flutter web app. 
It can be run with:

```terminal
$ dart run jaspr serve --input=lib/main_jaspr.dart --flutter=lib/main_flutter.dart
```

## Points of Interest

* Check the new JS Interop:
  * Look at `lib/main.dart`, find the `@js.JSExport()` annotation.
  * Find the JS code that interacts with Dart in `web/js/demo-js-interop.js`.
* See how the Flutter web application is embedded into the page now:
  * Find `hostElement` in `web/index.html`.

_(Original built by @ditman, @kevmoo and @malloc-error)_

_(Pure-Dart version built by @schultek)_
