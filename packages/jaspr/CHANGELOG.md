## 0.22.2

- Added `--web-port` and `--proxy-port` options to `jaspr serve` for configuring webdev and proxy server ports.
  - Allows running multiple Jaspr projects simultaneously with different ports.

- Fixed `testComponents` failing with `RawText` components due to `MarkupRenderObject` cast error.
  - Added `RawableRenderObject` and `RawableRenderText` interfaces for raw HTML text rendering support.
  - `MarkupRenderObject` and `TestRenderObject` now implement `RawableRenderObject`.
  - `MarkupRenderText` and `TestRenderText` now implement `RawableRenderText`.

- Fixed encoding of `lastmod` property in generated sitemap to be a valid W3C date string.
- Fixed launching debug builds in Safari.

- Added `--target-os` and `--target-arch` options to the build command to cross-compile server binaries.
- Added `--dart-define-from-file` option to the serve and build commands.
- Respect `PUB_HOSTED_URL` environment variable for custom pub mirrors.

- Added an example to show on pub.dev.

## 0.22.1

- Fixed bug when using `flutter: plugins` or `flutter: embedded` on Windows.
- Fixed generation of `*.client.options.dart` file in client mode.
- Improved detection of Flutter plugins by reading the generated `.flutter-plugins-dependencies` file.
- Fixed bug preventing event handlers from being updated in rebuilds.

## 0.22.0

- **Breaking** Changed project entrypoint conventions:

  - Any server entrypoint file must now end in `.server.dart` (e.g. `lib/main.server.dart`).
  - The generated server-side options file is now generated alongside the server entrypoint (e.g. as `lib/main.server.options.dart`) containing `defaultServerOptions`.
  - `Jaspr.initializeApp()` now requires the `package:jaspr/server.dart` import.

  - The project can contain at least one client entrypoint file ending in `.client.dart` (e.g. `lib/main.client.dart`) for client-side rendering (also available in **client** mode).
  - A new client-side Jaspr options file is generated alongside the client entrypoint (e.g. as `lib/main.client.options.dart`) containing `defaultClientOptions`.
  - Added a new `ClientApp` component that should be used inside the client entrypoint like this:

    ```dart
    // This file is lib/main.client.dart

    import 'package:jaspr/client.dart';
    import 'main.client.options.dart';

    void main() {
      Jaspr.initializeApp(
        options: defaultClientOptions,
      );

      runApp(
        const ClientApp(),
      );
    }
    ```

- **Breaking** Renamed `package:jaspr/browser.dart` library to `package:jaspr/client.dart`, as well as:

  - Renamed `BrowserAppBinding` class to `ClientAppBinding`.
  - Renamed `package:jaspr_test/browser_test.dart` library to `package:jaspr_test/client_test.dart`.
  - Renamed `testBrowser()` class to `testClient()`.

- **Breaking** Moved all html components, style classes and dom utilities including `div()` et al., `Styles`, `css`, `Color` et al., `events()`, `RawText`, and `ViewTransitionMixin` to a separate `package:jaspr/dom.dart` library.

  This reduces the "pollution" of the global namespace when importing `package:jaspr/jaspr.dart` and allows for more fine-grained control of imported APIs.

- **Breaking** All html components are now implemented as classes instead of functions, and can thereby used with `const`.

  This is mostly a structural change, as all components keep their lowercase names to have the familiar html-like syntax and differentiate to other Components. All standard uses of these components should still work as before, with a few exceptions when used with inferred typing (such as `var child = div([]);`), which may now require an explicit type annotation (such as `Component child = div([]);`) when assigning other values (such as `child = span([]);`).

- Deprecated `text()`, `fragment()` and `raw()` functions in favor of `Component.text()`, `Component.fragment()` and `RawText`, respectively.

  ```dart
  // Before:
  text('Hello World');
  fragment([ ... ]);
  raw('<div>Raw HTML</div>');

  // After (with dot-shorthands):
  .text('Hello World');
  .fragment([ ... ]);
  RawText('<div>Raw HTML</div>');
  ```

- Added `dl`, `dt`, and `dd` html components to `package:jaspr/dom.dart`.

- **Breaking** Removed deprecated `package:jaspr/ui.dart` library.

- **Breaking** Removed support for `jaspr.dev-command` option in `pubspec.yaml`.

- Added support for `jaspr.port` option in `pubspec.yaml` to specify the default port used by `jaspr serve`.
  This can still be overridden using the `--port` flag. If neither is set, the default port stays `8080`.

- Added support for `jaspr.flutter` option in `pubspec.yaml` to specify either support for Flutter embedding with `'embedded'` or support for Flutter plugins with `'plugins'`.

  This replaces the dependency on `jaspr_web_compilers` package, which is now discontinued. Instead, make sure to depend on `build_web_compilers` with a minimum version constraint of `4.4.6` or higher.

- **Breaking**: Removed `jaspr analyze` command, as the latest version of `jaspr_lints` can now be used directly with `dart analyze`.

- **Breaking**: `ResponseLike.body` (returned from `renderComponent()`) is now a `Uint8List` instead of `String`.
- Allow binary responses in `AppContext.setStatusCode`.

- Global `@css` styles from other packages will no longer be included automatically. To include them, import the file where they are defined.

- **Breaking** Changed `events()` method to accept only one optional type parameter for both `onInput` and `onChange` events.

- Added `Animation`, `Quotes` CSS properties.
- Added `Curve.linearFn()` easing function.
- Added `Gap.row()` and `Gap.column()` constructors.
- Added `Flex.grow()`, `Flex.shrink()` and `Flex.basis()` constructors.
- Added `Border.all()` constructor and deprecate the unnamed `Border` constructor.
- **Breaking**: `Transition`'s `duration` and `delay` are now of type `Duration` instead of `double`.
- Added `ms` and `seconds` extensions to `int` for simple conversion to `Duration`.
- **Breaking**: Changed `FontStyle.obliqueAngle` to accept `Angle` instead of `double`.
- Added `initial`, `inherit`, `revert`, `revertLayer` and `unset` to `Transition`, `TextShadow` and `BoxShadow`.
- Allow nesting non-empty `Filter.list` inside each other.

## 0.21.7

- `@Import` now supports defining extensions and properly checks elements inside the `show` parameter.
- Fixed bug when using `SyncStateMixin` or `@sync` on a `@client` component.
- Fixed bug with `checked` and `indeterminate` attributes not rendering correctly on `input` elements.
- Fixed allowing children for `path` tag by removing it from the list of self-closing tags.
- Deprecate the `package:jaspr/ui.dart` library that provides legacy utility components.
  For accessing Jaspr APIs, import `package:jaspr/jaspr.dart` instead.
  For the utility components, build your own or use a component library.

## 0.21.6

- Added `checked` and `indeterminate` parameters to `input()`. These will control the state of a checkbox or radio input.
- Fixed client hydration and debugging bug on chrome when running the app under a base path.

## 0.21.5

- Fixed regression in rendering implementation.

## 0.21.4

- Added `JasprBadge` component that renders a "Built with Jaspr" badge.
- Add the `--no-managed-build-options` flag to commands launching a build daemon. Without managed
  build options, users are responsible for configuring `build_web_compilers`.
- Fixed another whitespace rendering bug.

## 0.21.3

- Fix tooling daemon crash while analyzing component scopes.

## 0.21.2

- Added html domain to tooling daemon.

## 0.21.1

- Fix rendering issue with fragments.

## 0.21.0

**Read the full [Release Notes](https://docs.jaspr.site/releases/v/0.21.0) for this version.**

- **Breaking** Changed all `build()` methods and `builder` functions to return a single `Component` instead of `Iterable<Component>`. Use `jaspr migrate` to migrate automatically after updating.

- **Breaking** Introduced new `Component.element()`, `Component.text()`, `Component.fragment()` and `Component.wrapElement()` constructors, replacing `DomComponent()`, `Text()`, `Fragment()` and `DomComponent.wrap()`, respectively. Also added `Component.empty()` to create an empty fragment.

- Allow setting `Document(base: )` to `null`, and fix the path to the generated client script when no `<base>` element exists.

- Added `justifyItems`, `justifySelf` and `alignContent` styles properties.
- Added `filter` and `backdropFilter` styles properties.
- Added `all`, `appearance` and `aspectRatio` styles properties.

- Added `--include-source-maps` option to `jaspr build` command.

- Added `jaspr tooling-daemon` command and component scope analysis.
- Fixed sitemap generation bug in top-level route ('/')

- Require `sdk: ^3.8.0`.
- Update `analyzer` to `^8.0.0` and `build` to `^4.0.0`.

## 0.20.0

- **Breaking**: Removed the children parameter from `input` and `col` methods as
  they are void elements and shouldn't be passed children.
- **Breaking**: Replaced the children parameter from `script` method with a `String? content` parameter, as it can only contain text content. Also made `src` parameter optional.

- **Breaking**: Removed deprecated `Color.hex` and `Color.named` constructors.
- **Breaking**: Removed deprecated style groups (`Styles.box()`, `Styles.text()`, `Styles.background()`, etc. as well as `.box()`, `.text()`, etc.).
- **Breaking**: Removed deprecated `EdgeInsets` type.
- **Breaking**: Removed deprecated `Border.all` constructor.

- Added `withOpacity()`, `withLightness()`, `withHue()` and `withValues()` methods to `Color`.
- Added `figure` and `figcaption` html methods.
- Added the `wbr` html method for creating a line-break opportunity element.

- Moved `DomValidator` class to foundation library.
- Added support for disabling the sitemap generation for specific pages of `jaspr_content` sites.
- Better error handling for async components.
- Fixed an error where building too many routes in succession caused ports to be exhausted on macOS.

## 0.19.1

- Added `Color.currentColor` constant.
- Added `rx` and `ry` properties for svg `rect()`.
- Added `prefersContrast: Contrast.<more|less|noPreference>` to `MediaQuery`.
- Added `MediaQuery.raw()` for creating a custom media query from a `String`.

- Fixed rendering bug when nesting components with empty children.

## 0.19.0

- **BREAKING** `JasprOptions.useIsolates` is now `false` by default (was `true`).

  If you want to keep the old behaviour of rendering each request in a separate isolate, use `Jaspr.initializeApp(..., useIsolates: true)`.

- Added `allowedPathSuffixes` option to `Jaspr.initializeApp()` to enable handling route paths with extensions other than `html`.

- Added support for generating a **sitemap.xml** in static mode. To enable this, pass `--sitemap-domain=my.domain.com` to `jaspr build`.

  Add sitemap params like `changefreq` and `priority` to your routes by using `Route(settings: RouteSettings(priority: 0.5))` or set them through `ServerApp.requestRouteGeneration()`.

  Exclude routes from the sitemap through the `--sitemap-exclude` option to `jaspr build`.

  Read more about [Generating a Sitemap](https://docs.jaspr.site/dev/static_sites#generating-a-sitemap).

- Added support `@client` components from other packages.

  Components annotated with `@client` from other dependent packages are now also part of the js bundle when used during pre-rendering.

- **BREAKING** The `Flex(basis: ...)` style now accepts a `Unit` value directly instead of a `FlexBasis`.

- Allow nesting `css.media` and `css.supports` rules.
- Deprecated `Color.hex()` and `Color.named()` in favor of the default `Color()` constructor.

- Added `onReassemble` stream to `ServerApp`.

- Various bug fixes.

## 0.18.2

- Added `jaspr daemon` command to run a daemon server (used by the new [VSCode extension]()).
- Added `--launch-in-chrome` option to `jaspr serve` command to open the browser automatically.
- Added support for running `jaspr create .` in an empty directory.

## 0.18.1

- Better report errors during static build.
- Fixed flutter embedding issue with version 3.29.0.
- Added `onClick` override to the `a` html tag. When used, this will override the default behaviour of the link and not visit its url when clicked.
- Added `--extra-js-compiler-option` and `--extra-wasm-compiler-option` to `jaspr build` command.
- Added `// dart format off` and `// ignore_for_file: type=lint` headers to all generated files.

## 0.18.0

- **BREAKING** Changed `AppBinding`s `Uri get currentUri` to `String get currentUrl`.

- **BREAKING** Changed return type of `renderComponent()` from `Future<String>` to `Future<({int statusCode, String body, Map<String, List<String>> headers})>`.

  The rendered html is accessible through the `body` property. `statusCode` and `headers` can be used to create a response object when part of a custom http handler.

- Added `context.url` extension getter on both client and server.
- Added `context.headers`, `context.headersAll` and `context.cookies` extension getters on the server. These can be used to access the headers and cookies of the currently handled request.
- Added `context.setHeader()` and `context.setCookie()` and `context.setStatusCode()` extension on the server. These can be used to set headers, cookies and the status code of the response.

- Deprecated having seperate style groups (`Styles.box()`, `Styles.text()`, `Styles.background()`, etc. as well as `.box()`, `.text()`, etc.). All styling properties are now available under the single `Styles()` constructur and `.styles()` method.

  **Before:**

  ```dart
  css('.main')
    .box(width: 100.px, height: 100.px)
    .text(align: TextAlign.center)
    .background(color: Colors.blue);
  ```

  **After:**

  ```dart
  css('.main').styles(
    width: 100.px,
    height: 100.px,
    textAlign: TextAlign.center,
    backgroundColor: Colors.blue,
  );
  ```

- Deprecated `EdgeInsets` in favor of `Padding` and `Margin` types.
- **BREAKING** Moved `zIndex` property out of `Position` and directly into `Styles`.

- Added `userSelect`, `pointerEvents` and `content` properties to `Styles`.
- Added `Unit.maxContent`, `Unit.minContent`, `Unit.fitContent` and `Unit.expression()`.

## 0.17.1

- Update logo and website links.

## 0.17.0

- **BREAKING** Removed `currentState` from `GlobalKey`, use `GlobalStateKey` instead.
- Added `GlobalStateKey<T extends State>` to access the state of a component using `currentState`.

  ```dart
  // Use any State type as the type parameter.
  final GlobalStateKey<MyComponentState> myComponentKey = GlobalStateKey();

  /* ... */

  // Access the state from the key.
  MyComponentState? state = myComponentKey.currentState;
  ```

- Added `GlobalNodeKey<T extends Node>` to access native dom nodes using `currentNode`.

  ```dart
  import 'package:universal_web/web.dart';

  // Use any Node type (from package:universal_web) as the type parameter.
  final GlobalNodeKey<HTMLFormElement> myFormKey = GlobalNodeKey();

  /* ... */

  // Access the dom node from the key.
  HTMLFormElement? node = myFormKey.currentNode;
  ```

- Migrated all web imports from `package:web` to `package:universal_web`.
- Added `prefersColorScheme` parameter to `MediaQuery`.

## 0.16.4

- Added `--dart-define`, `--dart-define-client` and `--dart-define-server` to `serve` and `build` commands.
- Fixed attribute validation to support attribute names including `@` and `:`.

## 0.16.3

- Added `table` and related html methods.
- Added `value` parameter to `select()` method.
- Add 'standalone' option to `renderComponent` method.

## 0.16.2

- Fixed bug with empty `text('')` components.
- Fixed bug in `raw()` component.

## 0.16.1

- Fixed flutter embedding in new project scaffold.
- Fixed flutter embedding on mobile to always use canvaskit renderer.
- Fixed build command on windows to correctly end child process.

## 0.16.0

- **BREAKING** Migrated all packages to `package:web`, replacing `dart:html`.
- **BREAKING** Made `ComponentsBinding.attachRootComponent()` and `ComponentTester.pumpComponent()` synchronous.

- Added `InheritedModel<T>` similar to Flutters [InheritedModel](https://api.flutter.dev/flutter/widgets/InheritedModel-class.html)
- Added `css.layer()`, `css.supports()` and `css.keyframes()` rules.
- Added `ViewTransitionMixin` to use [view transitions](https://developer.mozilla.org/en-US/docs/Web/API/View_Transitions_API) in a `StatefulComponent`.

- Improved html formatting on the server to not introduce unwanted whitespaces.

- Fixed server issue during tests where the web directory would never resolve.
- Fixed issue with unhandled parameter types of client components.

## 0.15.1

- Include and setup `jaspr_lints` in newly created projects.
- Added `jaspr analyze` command to check all custom lints.
- Added css variable support with `Unit.variable()`, `Color.variable()`, `Angle.variable()` and `FontFamily.variable()`.

## 0.15.0

- Added support for using `@css` and `@encoder`/`@decoder` across other packages.

  1. Styles annotated with `@css` from other dependent packages are now also included in the pre-rendered css.
  2. Models (or extension types) that define `@encoder` and `@decoder` annotations from other dependent packages can
     now also be used together with `@client` components and `@sync` fields.

- **BREAKING** Component (or any class member) styles annotated with `@css` are now only included in the pre-rendered css if
  the file they are defined in is actually imported somewhere in the project.

  Top-level styles continue to be always included.

- Fixed issue with wrongly generated imports of `@encoder`/`@decoder` methods.
- Fixed spelling mistake from `spaceRvenly` to `spaceEvenly`
- Added default `BorderStyle.solid` to `BorderSide` constructor.

## 0.14.0

- **BREAKING** Calling `Jaspr.initializeApp()` is now required in static and server mode.

- **BREAKING** Removed `Head` component in favor of new `Document.head()` component.
  `Document.head()` has the same parameters as the old `Head` component and renders its children inside
  the `<head>` element.
- Added `Document.html()` and `Document.body()` to modify the attributes of `<html>` and `<body>`.

- **BREAKING** Removed `syncId` and `syncCodec` parameters from `SyncStateMixin`.
  `SyncStateMixin` now embeds its data locally in the pre-rendered html using standard json encoding.
- Added `@sync` annotation. Can be used on any field of a `StatefulComponent` to automatically sync its value.

  ```dart
  class MyComponentState extends State<MyComponent> with MyComponentStateSyncMixin {
    @sync
    String myValue;
  }
  ```

- **BREAKING** Removed `MediaRuleQuery` in favor of `MediaQuery`.
- Added `css.import()`, `css.fontFace()` and `css.media()` shorthands.
- Added `@css` annotation. Can be used on a list of style rules to automatically include them in the global styles.

  ```dart
  @css
  final styles = [
    css('.main').box(width: 100.px),
  ];
  ```

- Added `Fragment` component.
- Fixed missing html unescape in hydrated data.

## 0.13.3

- Added support for custom models as parameters to `@client` components.

  To enable this a custom model class must have two methods:

  - An instance method that encodes the model to a primitive value and is annotated with `@encoder`:

    ```dart
    @encoder
    String toJson() { ... }
    ```

  - A static method that decodes the model from a primitive value and is annotated with `@decoder`:

    ```dart
    @decoder
    static MyModel fromJson(String json) { ... }
    ```

  The method names can be freely chosen.
  The encoding type must be any primitive type (`String`, `int`, `List`, `Map`, etc.).

- Added `ListenableBuilder` and `ValueListenableBuilder` components.

- Added `Styles.list` for styling `ul` and `ol` elements.
- Added `TextDecoration.none` shorthand.

## 0.13.2

- Improved the performance of the building and diffing algorithm, and other performance improvements.
- Added `StatelessComponent.shouldRebuild` and `State.shouldRebuild` for possible skipping rebuilds as a performance improvement.

## 0.13.1

- Fixed namespace handling for nested svg elements.
- Fixed global key conflicts during server-side rendering by disabling them on the server.
- Change `testComponents(isClient: _)` default to true.

## 0.13.0

- Added `Head` component to render metadata inside the documents `<head>`.

  You can specify a title, metadata or custom children:

  ```dart
  Head(
    title: 'My Title',
    meta: {
      'description': 'My Page Description',
      'custom': 'my-custom-metadata',
    },
    children: [
      link(rel: "canonical" href: "https://mysite.com/example"),
    ],
  )
  ```

  Deeper or latter `Head` components will override duplicate elements:

  ```dart
  Parent(children: [
    Head(
      title: "My Title",
      meta: {"description": "My Page Description"}
    ),
    Child(children: [
      Head(
        title: "Nested Title"
      ),
    ]),
  ]),
  ```

  will render:

  ```html
  <head>
    <title>Nested Title</title>
    <meta name="description" content="My Page Description" />
  </head>
  ```

- Added `AsyncStatelessComponent` and `AsyncBuilder`.
  These are special components that are only available on the server (using `package:jaspr/server.dart`) and have an
  asynchronous build function.

- Improved internal framework implementation of different element types.

  - Added `BuildableElement` and `ProxyElement` as replacement for `MultiChildElement` and `SingleChildElement`.
  - Added `Element.didMount()` and `Element.didUpdate()` lifecycle methods.

- Fixed race condition where routes were skipped during static rendering.
- Fixed infinite loading bug for async server builds.
- Fixed hydration bug with empty or nested client components.
- Added documentation comments.

## 0.12.0

- **BREAKING** Removed `Document.file()`, instead use new `Document.template()`.

- Added `Document.template()` for loading template html files.

  Files that should be used with `Document.template()` must have the `.template.html` extension to differentiate
  between normal `.html` files that are served as-is. The `name` parameter provided to `Document.template()` must be the
  simple name of the file without extension, e.g. `Document.template(name: 'index')` loads the `web/index.template.html` file.

- Added the `lang` attribute to `Document()` constructor.
- Added `<main>` as `main_()` to the standard html components.

- Fixed bug with `PreloadStateMixin` and improved async server builds.
- Fixed crash with server hot-reload.
- Improved the shelf backend template for proper handling of server hot-reload.
- Fixed `DomValidator` to allow attributes with `.`.

## 0.11.1

- Fixed bug with base paths.

## 0.11.0

- **BREAKING** Changed jaspr configuration to require `jaspr.mode` in `pubspec.yaml`:

  The `jaspr.mode` option now sets the rendering mode and must be one of:

  - **static**: For building a statically pre-rendered site (SSG) with optional client-side hydration.
  - **server**: For building a server-rendered site (SSR) with optional client-side hydration.
  - **client**: For building a purely client-rendered site (SPA).

  This replaces the old `jaspr.uses-ssr` option.

- **BREAKING** Removed `jaspr generate` command in favor using the `jaspr build` command in combination with
  the new `jaspr.mode = static` option in `pubspec.yaml`.

- **BREAKING** Removed the `runServer()` method along with its support for adding middleware and listeners. Users should instead
  migrate to the custom backend setup using `package:shelf`.

- **BREAKING** Removed `rawHtml` flag from `Text` component and `text()` method, in favor of
  new `RawText` component and `raw()` method respectively, which fixes multiple bugs with the old implementation.

- Improved the `jaspr create` command by changing to a scaffolding system as replacement for templates.
  You will now be walked through a configuration wizard that creates a starting project based on the selected options.

- Removed `jaspr.uses-flutter` option. This is now auto-detected based on the dependencies.

- Styles can now be written more concise using the ability to chain style groups as well as the new `css()` method.

- Changes made to `main.dart` are now also hot-reloaded on the server.

- `Document` is no longer required when using server-side rendering. A basic document structure (`<html><head>...<body>...`)
  is automatically filled in.

- Improved how `@client` components are hydrated.

- The `jaspr build` command now accepts an optimization option. Minification (`-O 2`) enabled by default.

- Fixed `DomValidator` to allow special attributes with uppercase letters and colons.

- Exceptions thrown during `renderHtml` are now correctly passed through to the spawning isolate.

## 0.10.0

- **BREAKING** Restructured core libraries:

  - Removed `package:jaspr/html.dart` -> Use `package:jaspr/jaspr.dart` instead.
  - Renamed `package:jaspr/components.dart` to `package:jaspr/ui.dart`.

- **BREAKING** Updated `@client` components for a more streamlined usage.

  Annotated components no longer generate a `.g.dart` file and don't need to implement any generated mixin anymore.
  Instead, a single `lib/jaspr_options.dart` file is generated when using `@client` components.

  You must now call `Jaspr.initializeApp(options: defaultJasprOptions)` at the start of your app, where
  `defaultJasprOptions` is part of the newly generated `jaspr_options.dart` file.

  _Note:_ Calling `Jaspr.initializeApp()` will be required in a future version of Jaspr, and the cli will warn you
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

- Added _Static Site Generation_ support.

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
  For a full setup and usage guide see [Tailwind Integration Docs](https://docs.jaspr.site/eco/tailwind)

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
  Refer to [Flutter Embedding Docs](https://docs.jaspr.site/going_further/flutter_embedding) on how to setup and use this.

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

  For an example see [`examples/flutter_plugin_interop`](https://github.com/schultek/Jaspr/tree/main/examples/flutter_plugin_interop).

- Improved **flutter element embedding**.

  Flutter apps can now be directly embedded from your Jaspr codebase and integrated into
  the existing Jaspr component tree.

  This removes the need for any kind of interop between apps as they can directly communicate
  through the usual primitives of passing properties and callbacks.

  For an example see [`examples/flutter_embedding`](https://github.com/schultek/jaspr/tree/main/examples/flutter_embedding).

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
