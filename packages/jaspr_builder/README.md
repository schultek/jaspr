# jaspr_builder

Polyfill builder for integrating js libraries with jaspr.

## How to Use

First, add `jaspr_builder` as a dev dependency to your project:

```shell
dart pub add jaspr_builder --dev
```

Next, create a new file named `<libname>.web.dart` and export any
element from the targeted js library:

> For example purpose, dart:html is used.

```dart
export 'dart:html' show window, Window, Storage;
```

The export directive **must** contain an explicit **show** constraint.

Finally run code generation:
```shell
dart run build_runner build
```

This will generate two files:

- `<libname>.stub.dart` contains interface-stubs for all the exported elements
- `<libname>.dart` combines the stub and web file with conditional imports

In you project, you should the only import the `<libname>.dart` file.