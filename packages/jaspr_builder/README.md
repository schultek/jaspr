Builders for [jaspr](https://pub.dev/packages/jaspr)

# Setup

First, add `jaspr_builder` as a dev dependency to your project:

```shell
dart pub add jaspr_builder --dev
```

# Builders

## Apps and Islands

Builder for automatic setup of app and island components.

View [islands architecture](https://docs.page/schultek/jaspr~develop/advanced/islands) for documentation.

## web_mock

Builder for mocking web-only libraries. Used for integrating js-libraries with jaspr.

### How to use

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

> You don't need the code-generation step if you are running `jaspr serve`, since it will automatically
> build and watch your files for changes.

This will generate two files:

- `<libname>.stub.dart` contains interface-stubs for all the exported elements
- `<libname>.dart` combines the stub and web file with conditional imports

In you project, you should the only import the `<libname>.dart` file.
