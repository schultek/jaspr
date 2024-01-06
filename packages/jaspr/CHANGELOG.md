## Unreleased minor
- Added StyleSheet object to jaspr/lib/src/components/style.dart, so you can add custom CSS StyleSheets
- Modified _BaseDocument to inlcude option StyleSheet list attribute

## 0.9.3

- Fixed `melos format` on Windows.
- Fixed infinite loop attempting to find root directory on Windows when running a built jaspr executable.
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

  With the new `jaspr generate` command you can generate static pages from your jaspr app. This requires a normal 
  server-rendered jaspr app and will output separate `.html` pages for each of your routes.

  To specify which routes your application should handle, either use `jaspr_router` or call 
  `ServerApp.requestRouteGeneration('/my/route');` for each target route.

## 0.8.2

- Fixed client template to set `uses-ssr: false` correctly.

## 0.8.1

- Fixed bug with rebuilding the root component.

## 0.8.0

- Added `StyleRule.media({MediaRuleQuery query, List<StyleRule> styles})` to support `@media` css statements.

- Added support for Tailwind using the `jaspr_tailwind` integration.  
  Simply run `dart pub add jaspr_tailwind --dev` and start using tailwind classes in your jaspr components.  
  For a full setup and usage guide see [Tailwind Integration Docs](https://docs.page/schultek/jaspr/eco/tailwind).

## 0.7.0

- Improved cli experience with better logging and progress indicators.
- Removed `--ssr` and `--flutter` cli options.
- Added support `jaspr` config section in `pubspec.yaml`.

  It is now possible to define certain configuration options for the jaspr cli
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
  
  For an example see `experiments/flutter_plugin_interop`](https://github.com/schultek/jaspr/tree/main/experiments/flutter_plugin_interop).
  
- Improved **flutter element embedding**.

  Flutter apps can now be directly embedded from your jaspr codebase and integrated into
  the existing jaspr component tree.

  This removes the need for any kind of interop between apps as they can directly communicate
  through the usual primitives of passing properties and callbacks.

  For an example see `experiments/flutter_embedding_v2`](https://github.com/schultek/jaspr/tree/main/experiments/flutter_embedding_v2).

- `jaspr build` now outputs to `/build/jaspr` instead of `/build`.

## 0.5.0

- **BREAKING** Added `@client` as replacement for both `@app` and `@island`.

  Components annotated with `@client` act as entry points for the client application and are
  automatically detected, compiled and shipped to the client when using the `Document()` component.

  This combines the behaviour of the now removed `@app` and `@island` annotations, as well as the
  removed `Document.app()` and `Document.islands()` constructors. Use the default `Document()` constructor instead.
 
- **BREAKING** Removed `DeferRenderMixin` as async first builds are no longer permitted on clients.

- Added support for **Flutter element embedding**.

  Flutter apps can now easily be embedded within jaspr sites. The cli supports the `--flutter` argument for both
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
