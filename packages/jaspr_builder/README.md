Builders for [jaspr](https://pub.dev/packages/jaspr)

# Setup

First, add `jaspr_builder` as a dev dependency to your project:

```shell
dart pub add jaspr_builder --dev
```

# Builders

## @client

Builder for automatic setup of client components.

View [client components](https://docs.jaspr.site/core/app#client-components) for documentation.

## @Import

Builder for mocking platform-specific libraries. Used for integrating js-libraries with jaspr.

### How to use

Instead of importing those libraries directly, use the `@Import.onWeb` or `@Import.onServer` annotation.

```dart
@Import.onWeb('dart:html', show: [#window, #HtmlDocument])
@Import.onServer('dart:io', show: [#Platform])
import 'app.imports.dart';
```

The actual import directive **must** be the filename plus `.imports.dart`.

Finally, run code generation using `dart run build_runner build`.

> You don't need the code-generation step if you are running `jaspr serve`, since it will automatically
> build and watch your files for changes.
