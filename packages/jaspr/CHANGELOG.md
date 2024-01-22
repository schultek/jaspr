## 0.10.0

- **BREAKING** Restructured core libraries:
  - Removed `package:jaspr/html.dart` -> Use `package:jaspr/jaspr.dart` instead.
  - Renamed `package:jaspr/components.dart` to `package:jaspr/ui.dart`.

- **BREAKING** Updated `@client` components for a more streamlined usage.
  
  Annotated components no longer generate a `.g.dart` file and don't need to implement any generated mixin anymore.
  Instead, a single `lib/jaspr_options.dart` file is generated when using `@client` components.

  You must now call `Jaspr.initializeApp(options: defaultJasprOptions)` at the start of your app, where 
  `defaultJasprOptions` is part of the newly generated `jaspr_options.dart` file.

  *Note:* Calling `Jaspr.initializeApp()` will be required in a future version of Jaspr, and the cli will warn you
  when it's not called.

- **BREAKING** Changed type of the `classes` property of html components from `List<String>` to `String`. Multiple class
  names can be set using a single space-delimited string, e.g. `classes: 'class1 class2'`.
  
- **BREAKING** Event callbacks are now typed. The `events` property of html components now expects a 
  `Map<String, void Function(Event)>` instead of the old `Map<String, void Function(dynamic)>`.

  In addition to this Jaspr comes with a new `events()` function to provide typed event handlers for common events, like 
  `onClick`, `onInput` and `onChange`. Use it like this:

  ```dart
  anyelement(
    // Uses the [events] method to provide typed event handlers.
    events: events(
      onClick: () {
        print("Clicked");
      },
      // [value] can be typed depending on the element, e.g. `String` for text inputs or `bool` for checkboxes.
      onInput: (String value) {
        print("Value: $value");
      },
    ),
    [...]
  )
  ```
  
  Moreover, the html components `button`, `input`, `textarea` and `select` now also come with additional shorthand 
  properties for their supported event handlers:

  ```dart
  button(
    onClick: () {
      print("Clicked");  
    },
    [...]
  )
  ```

- **BREAKING** Refactored components inside the `package:jaspr/ui.dart` library. Some component properties have 
  changed or been discontinued. Check the separate components for details.

- **BREAKING** Promoted `jaspr_web_compilers` to non-experimental status.

  This also changes the respective cli option from `jaspr create --experimental-web-compilers` (old) to 
  `jaspr create --jaspr-web-compilers` (new).

- Added support for rendering `svg` elements. 
  Also added `svg()`, `rect()`, `circle()`, `ellipse()`, `line()`, `path()` and `polygon()` components.

- Refactored rendering implementation to use `RenderObject`s.
- Added `NotificationListener` component.

- Added `Colors.transparent`.
- Added `Unit.auto`, `Unit.vw()` and `Unit.vh()` for responsive styling.
- Added `StyleRule.fontFace()` to add external font files.

- Several bug fixes and stability improvements when running `jaspr serve` or `jaspr build`.

## 0.9.3

- Fixed `melos format` on Windows.
- Fixed infinite loop attempting to find root directory on Windows when running a built Jaspr executable.
- Add `.exe` extension to the output of `jaspr build` on Windows.

## 0.9.2

- Fixed cli execution on windows.

## 0.9.1

- Improved the stability and logging of the cli and added the commands:
  - `clean` command to clean your project directory
  - `update` command to automatically update the cli to the latest version
  - `doctor` command to print information about the environment and project
  
- We added lightweight anonymous usage tracking to the cli. We use [mixpanel.com](https://mixpanel.com/home) and
  only process anonymized data. The usage statistics are made public and can be viewed here (TODO: Link will be added in next release).

  To opt out of usage tracking, use `jaspr --disable-analytics`.

## 0.9.0

- Added *Static Site Generation* support.

  With the new `jaspr generate` command you can generate static pages from your Jaspr app. This requires a normal 
  server-rendered Jaspr app and will output separate `.html` pages for each of your routes.

  To specify which routes your application should handle, either use `jaspr_router` or call 
  `ServerApp.requestRouteGeneration('/my/route');` for each target route.

## 0.8.2

- Fixed client template to set `uses-ssr: false` correctly.

## 0.8.1

- Fixed bug with rebuilding the root component.

## 0.8.0

- Added `StyleRule.media({MediaRuleQuery query, List<StyleRule> styles})` to support `@media` css statements.

- Added support for Tailwind using the `jaspr_tailwind` integration.  
  Simply run `dart pub add jaspr_tailwind --dev` and start using tailwind classes in your Jaspr components.  
  For a full setup and usage guide see [Tailwind Integration Docs](https://docs.page/schultek/jaspr/eco/tailwind).

## 0.7.0

- Improved cli experience with better logging and progress indicators.
- Removed `--ssr` and `--flutter` cli options.
- Added support `jaspr` config section in `pubspec.yaml`.

  It is now possible to define certain configuration options for the Jaspr cli
  directly inside the `pubspec.yaml` file under the `jaspr` section.
  Initially supported options are:

  ```yaml
  jaspr:
    uses-ssr: true # or false; Toggles server-side-rendering on or off.
    uses-flutter: true # or false; Whether the project uses flutter element embedding.
  ```

## 0.6.2

- Added integrated support for seamless **flutter element embedding**.
  Refer to [Flutter Embedding Docs](https://docs.page/schultek/jaspr/eco/flutter_embedding) on how to setup and use this.

## 0.6.1

- Fixed bug with `jaspr create`.

- Added prompts when running `jaspr create` without any arguments.
  This way the developer is guided through the creation process more dynamically.

## 0.6.0

- Added support for **flutter web plugins**.

  Jaspr apps can now depend-on and import flutter plugins that work on web. This is achieved by 
  using a modified compiler toolchain: `jaspr_web_compilers`.

  To enable support for flutter plugins simply exchange your `build_web_compilers` dependency for `jaspr_web_compilers`:

  ```yaml
  dev_dependencies:
    jaspr_web_compilers: ^4.0.4
  ```
  
  For an example see `examples/flutter_plugin_interop`](https://github.com/schultek/Jaspr/tree/main/examples/flutter_plugin_interop).
  
- Improved **flutter element embedding**.

  Flutter apps can now be directly embedded from your Jaspr codebase and integrated into
  the existing Jaspr component tree.

  This removes the need for any kind of interop between apps as they can directly communicate
  through the usual primitives of passing properties and callbacks.

  For an example see `examples/flutter_embedding`](https://github.com/schultek/jaspr/tree/main/examples/flutter_embedding).

- `jaspr build` now outputs to `/build/jaspr` instead of `/build`.

## 0.5.0

- **BREAKING** Added `@client` as replacement for both `@app` and `@island`.

  Components annotated with `@client` act as entry points for the client application and are
  automatically detected, compiled and shipped to the client when using the `Document()` component.

  This combines the behaviour of the now removed `@app` and `@island` annotations, as well as the
  removed `Document.app()` and `Document.islands()` constructors. Use the default `Document()` constructor instead.
 
- **BREAKING** Removed `DeferRenderMixin` as async first builds are no longer permitted on clients.

- Added support for **Flutter element embedding**.

  Flutter apps can now easily be embedded within Jaspr sites. The cli supports the `--flutter` argument for both
  the `serve` and `build` commands to specify the entrypoint of the flutter application.

  The complete setup is demonstrated in the [flutter_embedding](https://github.com/schultek/jaspr/tree/main/examples/flutter_embedding) 
  example.

- Fixed handling of initial uri.
- Added `SynchronousFuture`.

## 0.4.0

- **BREAKING** Bindings are no longer singletons. 
  - `ComponentsBinding.instance`, `SchedulerBinding.instance` etc. were removed.
  - You can access the current binding through `BuildContext`s `context.binding` property.

- **BREAKING** Removed `ComponentTester.setUp()`, `BrowserTester.setUp()` and `ServerTester.setUp()`.
  - Use `testComponents()`, `testBrowser()` and `testServer()` instead.

- Requires Dart 3.0 or later.

## 0.3.0

- **BREAKING** The cli is now a separate package: `jaspr_cli`. To migrate run:
  ```shell
    dart pub global deactivate jaspr
    dart pub global activate jaspr_cli
  ```
  The usage stays the same with `jaspr create`, `jaspr serve` and `jaspr build`.

## 0.2.0

**BREAKING**: This is the first major release after the initial publish and contains several breaking changes.

- Update to Dart 2.17
- Rewrite of the rendering system that comes with a lot of improvements in stability and performance.
- Added support for custom backend & server setup.
- Added support for multiple apps on the client as well as island components.
- Added html utility components for common elements.
- Added `Styles` class for writing typed css in dart.
- Various other improvements throughout the framework.

## 0.1.5

- Refactor cli code [#12](https://github.com/schultek/jaspr/pull/12)
- Fixed issue with `jaspr serve`

## 0.1.4

- Added `--port` option to `jaspr serve` ([#6](https://github.com/schultek/jaspr/issues/6))
- Fixed `webdev` dependency constraint ([#5](https://github.com/schultek/jaspr/issues/5))

## 0.1.3

- Fixed domino dependency ([#4](https://github.com/schultek/jaspr/pull/4))
- Fixed build on windows ([#3](https://github.com/schultek/jaspr/issues/3))

## 0.1.2

- Added executable to `pubspec.yaml` ([#2](https://github.com/schultek/jaspr/issues/2))

## 0.1.1

- Fixed template for `jaspr create` ([#1](https://github.com/schultek/jaspr/pull/1))

## 0.1.0

- Initial version
