# Jaspr Best Practices

Comprehensive performance, architecture, and reliability guidelines for Jaspr applications, optimized for AI agents, LLMs, and automated workflows.

---

## Table of Contents

1. [Server Components & Surgical Hydration](#1-server-components--surgical-hydration) (CRITICAL)
   - 1.1 [Use Component.apply to Style Server Components from Client Shells](#11-use-componentapply-to-style-server-components-from-client-shells)
   - 1.2 [Use Server Components for Static Content Inside Interactive Shells](#12-use-server-components-for-static-content-inside-interactive-shells)
   - 1.3 [Toggle Server Component Visibility with CSS, Never Conditional Dart If](#13-toggle-server-component-visibility-with-css-never-conditional-dart-if)
   - 1.4 [Ensure Non-Component Props Across @client Boundaries Are Serializable](#14-ensure-non-component-props-across-client-boundaries-are-serializable)
   - 1.5 [Only Annotate the Root Component of an Interactive Client Island](#15-only-annotate-the-root-component-of-an-interactive-client-island)
2. [Bundle Size & Code Isolation](#2-bundle-size--code-isolation) (CRITICAL)
   - 2.1 [Design Small, Focused Interactive Islands Rather Than Monolithic Client Trees](#21-design-small-focused-interactive-islands-rather-than-monolithic-client-trees)
   - 2.2 [Strictly Isolate Platform Libraries Between Server and Client](#22-strictly-isolate-platform-libraries-between-server-and-client)
   - 2.3 [Guard Browser API Calls with kIsWeb When Using universal_web](#23-guard-browser-api-calls-with-kisweb-when-using-universal_web)
3. [Async Data Fetching & Waterfalls](#3-async-data-fetching--waterfalls) (HIGH)
   - 3.1 [Defer Await Until Value is Needed in Conditional Branches](#31-defer-await-until-value-is-needed-in-conditional-branches)
   - 3.2 [Use Future.wait for Independent Asynchronous Operations](#32-use-futurewait-for-independent-asynchronous-operations)
   - 3.3 [Fetch Data on the Server with AsyncStatelessComponent to Eliminate Client Waterfalls](#33-fetch-data-on-the-server-with-asyncstatelesscomponent-to-eliminate-client-waterfalls)
4. [Component Architecture & Composition](#4-component-architecture--composition) (MEDIUM-HIGH)
   - 4.1 [Use const Constructors for Components](#41-use-const-constructors-for-components)
   - 4.2 [Use Dot-Shorthands for Core Component Primitives](#42-use-dot-shorthands-for-core-component-primitives)
   - 4.3 [Use GlobalNodeKey with Explicit HTML Element Types for Direct DOM Access](#43-use-globalnodekey-with-explicit-html-element-types-for-direct-dom-access)
   - 4.4 [Assign Stable Keys When Rendering Dynamic Lists](#44-assign-stable-keys-when-rendering-dynamic-lists)
   - 4.5 [Use Dart Primary Constructors for Concise Component Definitions](#45-use-dart-primary-constructors-for-concise-component-definitions)
   - 4.6 [Prefer Typed DOM Parameters Over Raw Attributes and Events Maps](#46-prefer-typed-dom-parameters-over-raw-attributes-and-events-maps)
5. [State & Reactivity Performance](#5-state--reactivity-performance) (MEDIUM)
   - 5.1 [Always Clean Up Subscriptions, Streams, and Notifiers in dispose()](#51-always-clean-up-subscriptions-streams-and-notifiers-in-dispose)
   - 5.2 [Use InheritedComponent to Avoid Prop Drilling Across Deep Trees](#52-use-inheritedcomponent-to-avoid-prop-drilling-across-deep-trees)
   - 5.3 [Localize Re-Renders with ListenableBuilder and package:listen](#53-localize-re-renders-with-listenablebuilder-and-packagelisten)
6. [Styling & CSS Optimization](#6-styling--css-optimization) (MEDIUM)
   - 6.1 [Co-Locate Styles with Components Using the @css Annotation](#61-co-locate-styles-with-components-using-the-css-annotation)
   - 6.2 [Restrict Inline Styles to Truly Dynamic Runtime Values](#62-restrict-inline-styles-to-truly-dynamic-runtime-values)
   - 6.3 [Use Typed Unit Extensions and Dot-Shorthands](#63-use-typed-unit-extensions-and-dot-shorthands)
   - 6.4 [Follow Native CSS Nesting Rules in css()](#64-follow-native-css-nesting-rules-in-css)
7. [JS Interop & Web Performance](#7-js-interop--web-performance) (LOW-MEDIUM)
   - 7.1 [Use web.EventStreamProviders for Global Event Streams](#71-use-webeventstreamproviders-for-global-event-streams)
   - 7.2 [Use Dart Extension Types Implementing JSObject for Zero-Cost JS Interop](#72-use-dart-extension-types-implementing-jsobject-for-zero-cost-js-interop)
8. [Content Sites with jaspr_content](#8-content-sites-with-jaspr_content) (MEDIUM-HIGH)
   - 8.1 [Register Custom Components in ContentApp for Rich Embedded Content](#81-register-custom-components-in-contentapp-for-rich-embedded-content)
   - 8.2 [Use Structured Frontmatter for Page Metadata and Layout Selection](#82-use-structured-frontmatter-for-page-metadata-and-layout-selection)
   - 8.3 [Use ContentTheme and Tokenized CSS Variables for Universal Theming](#83-use-contenttheme-and-tokenized-css-variables-for-universal-theming)
9. [Flutter Embedding](#9-flutter-embedding) (HIGH)
   - 9.1 [Use @Import.onWeb and Deferred Imports to Isolate and Lazy-Load Flutter Widgets](#91-use-importonweb-and-deferred-imports-to-isolate-and-lazy-load-flutter-widgets)

---

## 1. Server Components & Surgical Hydration

### 1.1 Use Component.apply to Style Server Components from Client Shells
**Impact: MEDIUM-HIGH (Allows dynamic styling and class augmentation of server-rendered markup without forcing components into the client scope)**

When wrapping a server component inside an interactive client component, you may want to apply CSS classes, styles, or attributes to the server-rendered elements (such as setting theme colors or layout classes) without modifying the server component's code or pulling it into the client scope.

Use `Component.apply` (or `.apply(...)`). It seamlessly attaches classes, styles, attributes, and events to matching elements in child subtrees, and on the client, it specifically works on the server-rendered DOM elements of server components.

**Incorrect (forcing server content into a client component just to apply styles):**

```dart
// Converting what could be a static server component into a client component
// just to pass dynamic style properties:
@client
class StyledArticle extends StatelessComponent {
  const StyledArticle({required this.themeClass, super.key});
  final String themeClass;

  @override
  Component build(BuildContext context) {
    // Massive static article now has to be shipped in client JS!
    return div(classes: 'article $themeClass', [
      ...largeStaticArticleContent,
    ]);
  }
}
```

**Correct (keeping article as a server component and applying styles via Component.apply):**

```dart
@client
class ThemeWrapper extends StatelessComponent {
  const ThemeWrapper({required this.isDarkMode, required this.child, super.key});

  final bool isDarkMode;
  final Component child; // Server Component

  @override
  Component build(BuildContext context) {
    return Component.apply(
      classes: isDarkMode ? 'dark-theme' : 'light-theme',
      styles: Styles(padding: .all(16.px)),
      child: child,
    );
  }
}
```

---

### 1.2 Use Server Components for Static Content Inside Interactive Shells
**Impact: CRITICAL (Eliminates client JS compilation and reduces bundle size to 0 KB for static content)**

When an interactive container or layout shell (such as an expandable card, modal dialog, sidebar, or tab container) needs client interactivity, annotating it with `@client` traditionally pulls every nested child component into the client JavaScript bundle.

With Jaspr's Server Components, pass static or heavy subtrees as `Component` or `List<Component>` parameters to the `@client` component instead of hardcoding them inside the `@client` component's build method. Jaspr pre-renders them exclusively on the server and mounts the pre-rendered DOM elements into place during hydration without shipping their Dart code to the client.

**Incorrect (entire static subtree compiled and shipped to the client):**

```dart
// lib/components/shell.dart
@client
class CollapsibleShell extends StatefulComponent {
  const CollapsibleShell({super.key});

  @override
  State<CollapsibleShell> createState() => _CollapsibleShellState();
}

class _CollapsibleShellState extends State<CollapsibleShell> {
  bool isOpen = true;

  @override
  Component build(BuildContext context) {
    return div([
      button(onClick: () => setState(() => isOpen = !isOpen), [.text('Toggle')]),
      // HeavyArticleContent and all its static children get bundled into client JS!
      HeavyArticleContent(), 
    ]);
  }
}
```

**Correct (static content passed as a Server Component parameter):**

```dart
// lib/components/shell.dart
@client
class CollapsibleShell extends StatefulComponent {
  const CollapsibleShell({required this.content, super.key});

  // Passed as parameter -> remains a Server Component
  final Component content;

  @override
  State<CollapsibleShell> createState() => _CollapsibleShellState();
}

class _CollapsibleShellState extends State<CollapsibleShell> {
  bool isOpen = true;

  @override
  Component build(BuildContext context) {
    return div([
      button(onClick: () => setState(() => isOpen = !isOpen), [.text('Toggle')]),
      div(
        classes: isOpen ? 'open' : 'hidden',
        [component.content], // Slotted in from server pre-render!
      ),
    ]);
  }
}

// lib/main.server.dart
CollapsibleShell(
  // HeavyArticleContent is rendered ONLY on the server:
  content: HeavyArticleContent(),
)
```

---

### 1.3 Toggle Server Component Visibility with CSS, Never Conditional Dart If
**Impact: CRITICAL (Prevents missing DOM nodes and broken hydration when toggling client state)**

Server Components are executed and rendered **only on the server during the initial Server-Side Rendering (SSR) build**. The browser client does not receive the Dart code required to build the server component.

If a server component passed as a parameter is placed inside a Dart `if (condition)` check that evaluates to `false` during SSR, it is never rendered on the server. When that condition subsequently becomes `true` in the browser, the client attempts to render the component but has no code to do so, resulting in an empty view.

Always ensure server components are included in the component tree during SSR, and toggle their visibility interactively on the client using CSS classes (e.g., `display: none` or `.hidden`).

**Incorrect (component not rendered during SSR, renders as empty when opened):**

```dart
@client
class Accordion extends StatefulComponent {
  const Accordion({required this.details, super.key});
  final Component details;

  @override
  State<Accordion> createState() => _AccordionState();
}

class _AccordionState extends State<Accordion> {
  // Evaluates to false during initial SSR!
  bool isOpen = false; 

  @override
  Component build(BuildContext context) {
    return div([
      button(onClick: () => setState(() => isOpen = !isOpen), [.text('Details')]),
      // BROKEN: 'details' was never rendered on the server!
      // When isOpen becomes true on the client, nothing appears.
      if (isOpen) component.details, 
    ]);
  }
}
```

**Correct (rendered on server, visibility toggled via CSS):**

```dart
@client
class Accordion extends StatefulComponent {
  const Accordion({required this.details, super.key});
  final Component details;

  @override
  State<Accordion> createState() => _AccordionState();
}

class _AccordionState extends State<Accordion> {
  bool isOpen = false;

  @override
  Component build(BuildContext context) {
    return div([
      button(onClick: () => setState(() => isOpen = !isOpen), [.text('Details')]),
      // ALWAYS rendered during SSR. Toggled via CSS class.
      div(
        classes: 'accordion-content ${isOpen ? 'expanded' : 'collapsed'}',
        [component.details],
      ),
    ]);
  }
}
```

---

### 1.4 Ensure Non-Component Props Across @client Boundaries Are Serializable
**Impact: CRITICAL (Prevents serialization crashes during SSR and hydration decode errors in the browser)**

Data passed from server-rendered components to `@client` components must be serialized into the HTML output on the server and deserialized by the client during hydration.

- Allowed parameter types:
  - Component types: `Component`, `List<Component>` (handled as Server Components).
  - Primitive types: `int`, `double`, `String`, `bool`.
  - Collections:
    - Lists: `List`, `List<dynamic>`, `List<Object?>`, or typed `List<T>` where `T` is a supported serializable type.
    - Maps: `Map<String, dynamic>`, `Map<String, Object?>`, or typed `Map<String, V>` where `V` is a supported serializable type. (Note: Map keys MUST be `String`; raw untyped `Map` or maps with non-string keys such as `Map<int, String>` will fail client-code generation).
  - Custom classes or Enums: MUST define `@encoder` and `@decoder` methods.
- Parameters MUST NOT be functions, callbacks, or complex unsupported objects.

**Incorrect (passing non-serializable objects or functions to @client components):**

```dart
enum UserRole { admin, user }

class Config {
  final String api;
  Config(this.api);
}

@client
class UserDashboard extends StatelessComponent {
  // CRASH: Config and UserRole have no @encoder/@decoder, and onSelect is a function!
  const UserDashboard({
    required this.config,
    required this.role,
    required this.onSelect,
    super.key,
  });

  final Config config;
  final UserRole role;
  final void Function(int) onSelect;

  @override
  Component build(BuildContext context) => ...;
}
```

**Correct (providing codecs for enums/classes, using primitive callbacks or state):**

```dart
enum UserRole {
  admin,
  user;

  @encoder
  String encode() => name;

  @decoder
  static UserRole decode(String value) => values.byName(value);
}

class Config {
  final String api;
  const Config(this.api);

  @encoder
  Map<String, dynamic> encode() => {'api': api};

  @decoder
  static Config decode(Map<String, dynamic> map) => Config(map['api'] as String);
}

@client
class UserDashboard extends StatelessComponent {
  const UserDashboard({
    required this.config,
    required this.role,
    super.key,
  });

  final Config config;
  final UserRole role;

  @override
  Component build(BuildContext context) => ...;
}
```

---

### 1.5 Only Annotate the Root Component of an Interactive Client Island
**Impact: LOW-MEDIUM (Avoids unnecessary client component registrations and clarifies island boundaries)**

Annotating a component with `@client` registers it as an entrypoint for client-side hydration. When building an interactive feature composed of multiple components, you only need to annotate the root of the interactive island.

While Jaspr automatically suppresses nested `@client` boundaries during hydration when there is no intervening server component, adding `@client` to internal child components that are only ever used inside an existing client island creates unnecessary registration boilerplate.

- For **internal child components** that are only used within a specific client island (e.g. `FormInput` and `SubmitButton` inside `MyForm`), omit `@client`. They are compiled and executed in the browser automatically as part of the parent island.
- For **reusable components** that are also instantiated directly in server components (e.g. a shared `Button` or `Modal`), keep `@client` so they can hydrate independently when used directly from server scope.

**Unnecessary (annotating internal child components used only inside a client island):**

```dart
// Redundant: FormInput and SubmitButton are only used inside MyForm:
@client
class FormInput extends StatelessComponent { ... }

@client
class SubmitButton extends StatelessComponent { ... }

@client
class MyForm extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return form([
      FormInput(),
      SubmitButton(),
    ]);
  }
}
```

**Correct (only the island root is annotated):**

```dart
// Plain components - executed on client because they are inside MyForm:
class FormInput extends StatelessComponent { ... }

class SubmitButton extends StatelessComponent { ... }

// Only the root boundary gets @client:
@client
class MyForm extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return form([
      FormInput(),
      SubmitButton(),
    ]);
  }
}
```

---

## 2. Bundle Size & Code Isolation

### 2.1 Design Small, Focused Interactive Islands Rather Than Monolithic Client Trees
**Impact: CRITICAL (Drastically decreases downloaded JS/Wasm payload and minimizes hydration work)**

In Jaspr, pre-rendered components have zero client-side JavaScript overhead. Marking a high-level layout component (like `App` or `PageLayout`) with `@client` turns your entire website into a monolithic Single-Page Application (SPA) on the client, negating the performance benefits of SSR/SSG.

Instead, structure your app using Islands Architecture:
- Keep the page layout, navigation structure, headers, footers, and static article copy as Server Components.
- Make only the specific dynamic widgets (e.g. `ThemeToggle`, `SearchModal`, `AddToCartButton`) `@client` islands.

**Incorrect (annotating root application or whole page as @client):**

```dart
// lib/app.dart
// Everything in this entire page is forced into the client JS bundle:
@client
class FullPageApp extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return div([
      HeaderWithStaticLinks(),
      HeroBanner(),
      MarketingCopy(),
      InteractiveNewsletterSignup(),
      FooterWithSiteMap(),
    ]);
  }
}
```

**Correct (page remains server-rendered, only the interactive widget is @client):**

```dart
// lib/app.dart - Server Component (0 KB JS shipped!)
class FullPageApp extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return div([
      HeaderWithStaticLinks(),
      HeroBanner(),
      MarketingCopy(),
      // Only this small component is an interactive island:
      InteractiveNewsletterSignup(), 
      FooterWithSiteMap(),
    ]);
  }
}

// lib/components/newsletter.dart
@client
class InteractiveNewsletterSignup extends StatefulComponent {
  ...
}
```

---

### 2.2 Strictly Isolate Platform Libraries Between Server and Client
**Impact: CRITICAL (Eliminates build failures and runtime crashes caused by incompatible platform imports)**

In `server` and `static` modes, Jaspr code runs in two different environments:
1. **Server environment (Dart VM):** Compiles natively and has access to `dart:io`, databases, and files, but CANNOT import `dart:js_interop` or `package:web`.
2. **Client environment (Browser JS/Wasm):** Compiles to JS/Wasm and has access to browser APIs, but CANNOT import `dart:io` or `dart:ffi`.

To prevent compilation failures:
- Keep `dart:io` imports strictly inside `.server.dart` entrypoints and server-only files.
- Keep `dart:js_interop` and `package:web` strictly inside `.client.dart` entrypoints and browser-only files.
- For shared code, use `package:universal_web` and conditionally check `if (kIsWeb)`.

**Incorrect (importing dart:io in code reachable by client or dart:js_interop reachable by server):**

```dart
// lib/components/my_component.dart - shared file!
import 'dart:io'; // Breaks client compilation when compiled to JS/Wasm!
import 'package:web/web.dart'; // Breaks server compilation on Dart VM!

class MyComponent extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return div([.text('Hello')]);
  }
}
```

**Correct (entrypoints properly split and shared code safe):**

```dart
// lib/main.server.dart (Server only)
import 'dart:io'; // Safe here!
import 'package:jaspr/server.dart';

// lib/main.client.dart (Client only)
import 'package:jaspr/client.dart';

// lib/components/shared_component.dart (Shared code)
import 'package:universal_web/web.dart' as web; // Safe stub on VM!
import 'package:jaspr/jaspr.dart';

class SharedComponent extends StatelessComponent {
  void handleClick() {
    if (kIsWeb) {
      web.window.alert('Safe browser alert!');
    }
  }

  @override
  Component build(BuildContext context) => button(onClick: handleClick, [.text('Click')]);
}
```

---

### 2.3 Guard Browser API Calls with kIsWeb When Using universal_web
**Impact: HIGH (Prevents UnsupportedError exceptions during server-side pre-rendering)**

`package:universal_web` provides cross-platform stubs for `package:web` and `dart:js_interop` so your shared components can compile cleanly on both the Dart VM (server) and the browser.

However, invoking browser APIs on the server (such as reading `web.window.innerWidth` or manipulating `web.document`) will throw an `UnsupportedError` at runtime during SSR. You must wrap any browser API invocations in `if (kIsWeb)`.

**Incorrect (accessing web APIs without kIsWeb guard during SSR):**

```dart
import 'package:universal_web/web.dart' as web;

class ViewportIndicator extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    // CRASHES during server-side pre-rendering!
    final width = web.window.innerWidth; 
    return div([.text('Width: $width')]);
  }
}
```

**Correct (guarded inside lifecycle methods or event callbacks with kIsWeb):**

```dart
import 'package:universal_web/web.dart' as web;

@client
class ViewportIndicator extends StatefulComponent {
  const ViewportIndicator({super.key});

  @override
  State<ViewportIndicator> createState() => _ViewportIndicatorState();
}

class _ViewportIndicatorState extends State<ViewportIndicator> {
  int? width;

  @override
  void initState() {
    super.initState();
    // Guarded: only runs in browser environment
    if (kIsWeb) {
      width = web.window.innerWidth;
    }
  }

  @override
  Component build(BuildContext context) {
    return div([.text('Width: ${width ?? "calculating..."}')]);
  }
}
```

---

## 3. Async Data Fetching & Waterfalls

### 3.1 Defer Await Until Value is Needed in Conditional Branches
**Impact: MEDIUM (Avoids paying latency cost when early checks bypass the need for fetched data)**

Do not await asynchronous values upfront if a simple synchronous condition might render them unnecessary. Check cheap synchronous conditions or cache hits first before awaiting costly asynchronous operations.

**Incorrect (always paying async latency even when not needed):**

```dart
class ProfilePage extends AsyncStatelessComponent {
  const ProfilePage({required this.isLoggedIn, super.key});
  final bool isLoggedIn;

  @override
  Future<Component> build(BuildContext context) async {
    // Awaiting regardless of whether user is logged in!
    final extraDetails = await fetchExtraDetails();

    if (!isLoggedIn) {
      return div([.text('Please log in.')]);
    }

    return div([.text(extraDetails)]);
  }
}
```

**Correct (checking synchronous condition before awaiting):**

```dart
class ProfilePage extends AsyncStatelessComponent {
  const ProfilePage({required this.isLoggedIn, super.key});
  final bool isLoggedIn;

  @override
  Future<Component> build(BuildContext context) async {
    // Fast synchronous exit:
    if (!isLoggedIn) {
      return div([.text('Please log in.')]);
    }

    // Only await when needed:
    final extraDetails = await fetchExtraDetails();
    return div([.text(extraDetails)]);
  }
}
```

---

### 3.2 Use Future.wait for Independent Asynchronous Operations
**Impact: HIGH (Cuts server response time from the sum of requests to the longest single request)**

Awaiting multiple independent asynchronous calls in sequence creates an unnecessary server-side waterfall. If operation A takes 100ms and operation B takes 120ms, running them sequentially takes 220ms.

Run independent operations in parallel using `Future.wait` or Dart records with futures so they execute concurrently.

**Incorrect (sequential awaits accumulating latency):**

```dart
class DashboardPage extends AsyncStatelessComponent {
  @override
  Future<Component> build(BuildContext context) async {
    // Sequential: 100ms + 150ms + 80ms = 330ms server delay!
    final user = await api.getUser();
    final notifications = await api.getNotifications();
    final analytics = await api.getAnalytics();

    return div([ ... ]);
  }
}
```

**Correct (concurrent execution with Future.wait):**

```dart
class DashboardPage extends AsyncStatelessComponent {
  @override
  Future<Component> build(BuildContext context) async {
    // Concurrent: runs all three simultaneously (max delay ~150ms):
    final (user, notifications, analytics) = await (
      api.getUser(),
      api.getNotifications(),
      api.getAnalytics(),
    ).wait;

    return div([ ... ]);
  }
}
```

---

### 3.3 Fetch Data on the Server with AsyncStatelessComponent to Eliminate Client Waterfalls
**Impact: HIGH (Eliminates loading spinners, renders full HTML on initial request, and improves SEO/LCP)**

Fetching data inside a client component's `initState()` causes a network waterfall: the user waits for the initial HTML, downloads and parses the JavaScript bundle, and only then initiates the HTTP request to fetch data, seeing a flash of loading spinners or skeletons.

In Jaspr's server or static mode, fetch data directly on the server during the build phase using `AsyncStatelessComponent` or `AsyncBuilder`. The server waits for the data to resolve and renders the complete, populated HTML in the initial HTTP response. If client interactivity is needed, pass the resolved data down to a `@client` component as initial state.

**Incorrect (client-side data fetching causing network waterfall and blank layout):**

```dart
@client
class ProductList extends StatefulComponent {
  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  List<Product>? products;

  @override
  void initState() {
    super.initState();
    // Waterfall: user waits for JS to load, then waits for API response:
    fetchProducts().then((data) => setState(() => products = data));
  }

  @override
  Component build(BuildContext context) {
    if (products == null) return div([.text('Loading...')]); // Blank during SSR!
    return ul([
      for (final p in products!) li([.text(p.title)]),
    ]);
  }
}
```

**Correct (server fetches data before responding with complete HTML):**

```dart
import 'package:jaspr/server.dart';
import 'package:jaspr/dom.dart';

class ServerProductList extends AsyncStatelessComponent {
  const ServerProductList({super.key});

  @override
  Future<Component> build(BuildContext context) async {
    // Data is fetched on server directly before HTML is generated:
    final products = await database.getProducts();

    return ul([
      for (final p in products) li([.text(p.title)]),
    ]);
  }
}
```

---

## 4. Component Architecture & Composition

### 4.1 Use const Constructors for Components
**Impact: MEDIUM-HIGH (Prevents redundant object allocations and optimizes virtual DOM reconciliation)**

Just like in Flutter, components in Jaspr are immutable configurations for elements in the component tree. When a component is declared with a `const` constructor, the Dart compiler can canonicalize its instances, eliminating object allocations during builds.

Furthermore, when a parent component rebuilds, identical `const` child components can be recognized immediately by Jaspr's reconciler as unchanged, avoiding rebuilding unchanged subtrees.

**Incorrect (omitting const constructors):**

```dart
class Badge extends StatelessComponent {
  // Non-const constructor forces new heap allocation on every parent build:
  Badge({this.label = 'New', super.key});
  final String label;

  @override
  Component build(BuildContext context) => span(classes: 'badge', [.text(label)]);
}

// In parent:
div([
  Badge(), // Re-allocated on every rebuild!
])
```

**Correct (providing and utilizing const constructors):**

```dart
class Badge extends StatelessComponent {
  // const constructor allows canonicalization and memoization:
  const Badge({this.label = 'New', super.key});
  final String label;

  @override
  Component build(BuildContext context) => span(classes: 'badge', [.text(label)]);
}

// In parent:
div([
  const Badge(), // Zero allocation, identical reference preserved across rebuilds
])
```

---

### 4.2 Use Dot-Shorthands for Core Component Primitives
**Impact: MEDIUM (Standardizes idiomatic Jaspr syntax, improves readability, and leverages constructor tear-offs)**

Jaspr provides dot-shorthand constructors on `Component` to construct primitive nodes cleanly:
- `.text('...')` instead of `Text('...')` or `text('...')`
- `.fragment([...])` instead of `Fragment([...])` or `fragment([...])`
- `.empty()` instead of `Fragment([])` or null hacks
- `.apply(...)` instead of legacy wrapElement methods

Always use dot-shorthands in component trees.

**Incorrect (using legacy or verbose constructors):**

```dart
div([
  Text('Welcome'), // Verbose
  Fragment([       // Verbose
    Text('Subtext'),
  ]),
  if (!hasItems)
    Fragment([]),  // Unclear intention
])
```

**Correct (using standard dot-shorthands):**

```dart
div([
  .text('Welcome'),
  .fragment([
    .text('Subtext'),
  ]),
  if (!hasItems)
    .empty(),
])
```

---

### 4.3 Use GlobalNodeKey with Explicit HTML Element Types for Direct DOM Access
**Impact: MEDIUM (Guarantees type safety, prevents element mismatch, and avoids fragile manual DOM queries)**

When you need direct, imperative access to an underlying DOM node (such as focusing an `<input>`, measuring bounding rects, controlling video/audio playback, or interacting with a `<canvas>`), use `GlobalNodeKey`.

- **Rule 1:** Always specify the concrete element type as the generic type parameter (e.g. `GlobalNodeKey<web.HTMLInputElement>()`), not `web.Element` or `dynamic`.
- **Rule 2:** Access `key.currentNode` only in lifecycle callbacks (`initState` post-frame / event listeners) and guarded with `if (kIsWeb)`.
- **Rule 3:** Do NOT use `GlobalNodeKey` to imperatively mutate innerHTML, append child elements, or manually bind event listeners. Use Jaspr's declarative components and event bindings instead.

**Incorrect (manual DOM queries or untyped keys):**

```dart
// Fragile, untyped, and risks querying the wrong element across components:
void focusInput() {
  if (kIsWeb) {
    (web.document.getElementById('my-input') as web.HTMLInputElement).focus();
  }
}
```

**Correct (typed GlobalNodeKey linked directly to component):**

```dart
import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';
import 'package:universal_web/web.dart' as web;

@client
class SearchField extends StatefulComponent {
  const SearchField({super.key});

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  // Strongly typed to the HTMLInputElement:
  final inputKey = GlobalNodeKey<web.HTMLInputElement>();

  void handleFocus() {
    if (kIsWeb) {
      inputKey.currentNode?.focus();
    }
  }

  @override
  Component build(BuildContext context) {
    return div([
      input(key: inputKey, type: InputType.text, attributes: {'placeholder': 'Search...'}),
      button(onClick: handleFocus, [.text('Focus Input')]),
    ]);
  }
}
```

---

### 4.4 Assign Stable Keys When Rendering Dynamic Lists
**Impact: HIGH (Prevents incorrect DOM element reuse, lost input/focus state, and UI glitches)**

When rendering dynamic lists of components where items can be reordered, inserted, or removed, Jaspr uses the `key` property to match old elements to new components.

Without a unique, stable `Key`, Jaspr matches elements by positional index. This causes stateful child components to retain stale local state from previous elements, causes text inputs to lose focus, and triggers unnecessary DOM re-creation.

Always use a stable identifier (e.g. `ValueKey(item.id)`). Never use array indices as keys.

**Incorrect (missing keys or using list indices as keys):**

```dart
ul([
  // Flawed: no key or using index causes state mixing during reorder or deletion:
  for (var i = 0; i < todos.length; i++)
    TodoItem(todo: todos[i], key: ValueKey(i)),
])
```

**Correct (using a unique, stable business identifier):**

```dart
ul([
  for (final todo in todos)
    TodoItem(
      key: ValueKey(todo.id), // Stable across reorders and deletions
      todo: todo,
    ),
])
```

---

### 4.5 Use Dart Primary Constructors for Concise Component Definitions
**Impact: LOW-MEDIUM (Eliminates boilerplate constructor and field declarations in component classes)**

Jaspr natively supports Dart primary constructors for components, including `@client` components and Server Components.

Instead of declaring separate constructor parameters, initializing formals, and field declarations, use primary constructors to keep components concise, legible, and easy to maintain.

**Incorrect (verbose traditional constructor ceremony):**

```dart
@client
class UserAvatar extends StatelessComponent {
  const UserAvatar({
    required this.name,
    required this.imageUrl,
    this.size = 40,
    super.key,
  });

  final String name;
  final String imageUrl;
  final int size;

  @override
  Component build(BuildContext context) {
    return img(src: imageUrl, alt: name, width: size, height: size);
  }
}
```

**Correct (concise component with primary constructor):**

```dart
@client
class UserAvatar({
  required final String name,
  required final String imageUrl,
  final int size = 40,
  super.key,
}) extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return img(src: imageUrl, alt: name, width: size, height: size);
  }
}
```

---

### 4.6 Prefer Typed DOM Parameters Over Raw Attributes and Events Maps
**Impact: MEDIUM (Guarantees compile-time type safety, IDE autocompletion, and optimal event listener binding)**

Jaspr's typed HTML components (from `package:jaspr/dom.dart`) provide first-class typed named parameters for standard HTML attributes (such as `href`, `src`, `target`, `type`, `value`, `placeholder`, `disabled`) and common event handlers (such as `onClick`, `onInput`, `onChange`).

Prefer these typed parameters over writing strings into generic `attributes: {}` and `events: {}` maps. For events or attributes without dedicated named parameters (such as form submission via `'submit'` on `form()`, or custom data/aria attributes), use the `events` or `attributes` map (e.g. `events: {'submit': (event) => ...}`).

**Incorrect (string-based maps prone to typos and missing compiler checks):**

```dart
button(
  attributes: {
    'type': 'submit',
    'disabled': 'true',
  },
  events: {
    'click': (event) => handleSubmit(),
  },
  [.text('Submit')],
)
```

**Correct (typed parameters with compile-time verification):**

```dart
button(
  type: ButtonType.submit,
  disabled: true,
  onClick: handleSubmit,
  [.text('Submit')],
)
```

---

## 5. State & Reactivity Performance

### 5.1 Always Clean Up Subscriptions, Streams, and Notifiers in dispose()
**Impact: HIGH (Prevents memory leaks and zombie listeners executing callbacks on unmounted components)**

In client components, `StreamSubscription`s, global window event listeners, or timers created in `initState()` will remain active in memory if not cancelled when the component unmounts. If a callback fires on an unmounted component and calls `setState()`, it can throw errors or leak memory.

Always override `dispose()` in `StatefulComponent` state classes to cancel subscriptions, detach listeners, and dispose owned notifiers.

**Incorrect (abandoning subscriptions when component unmounts):**

```dart
@client
class ResizeObserverView extends StatefulComponent {
  @override
  State<ResizeObserverView> createState() => _ResizeObserverViewState();
}

class _ResizeObserverViewState extends State<ResizeObserverView> {
  int windowWidth = 0;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      // Memory leak: subscription never cancelled on unmount!
      web.EventStreamProviders.resizeEvent.forTarget(web.window).listen((event) {
        setState(() => windowWidth = web.window.innerWidth);
      });
    }
  }

  @override
  Component build(BuildContext context) => div([.text('Width: $windowWidth')]);
}
```

**Correct (retaining and cancelling subscription in dispose):**

```dart
import 'dart:async';

@client
class ResizeObserverView extends StatefulComponent {
  @override
  State<ResizeObserverView> createState() => _ResizeObserverViewState();
}

class _ResizeObserverViewState extends State<ResizeObserverView> {
  int windowWidth = 0;
  StreamSubscription? _resizeSub;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _resizeSub = web.EventStreamProviders.resizeEvent.forTarget(web.window).listen((event) {
        if (mounted) {
          setState(() => windowWidth = web.window.innerWidth);
        }
      });
    }
  }

  @override
  void dispose() {
    _resizeSub?.cancel(); // Cleanly detached
    super.dispose();
  }

  @override
  Component build(BuildContext context) => div([.text('Width: $windowWidth')]);
}
```

---

### 5.2 Use InheritedComponent to Avoid Prop Drilling Across Deep Trees
**Impact: MEDIUM (Decouples intermediary components from shared dependencies and optimizes dependency tracking)**

Passing shared dependencies, user sessions, or theme configs through dozens of intermediate constructor parameters (prop drilling) tightly couples your component hierarchy and complicates maintenance.

Use Jaspr's `InheritedComponent` to provide data at the top of a subtree and allow any descendant to consume it using `context.dependOnInheritedComponentOfExactType<T>()`.

**Incorrect (prop drilling through every intermediary component):**

```dart
class AppShell extends StatelessComponent {
  const AppShell({required this.theme, super.key});
  final ThemeConfig theme;

  @override
  Component build(BuildContext context) => MainLayout(theme: theme);
}

class MainLayout extends StatelessComponent {
  const MainLayout({required this.theme, super.key});
  final ThemeConfig theme;

  @override
  Component build(BuildContext context) => Sidebar(theme: theme); // Intermediary just passing props
}
```

**Correct (providing via InheritedComponent and consuming directly where needed):**

```dart
class ThemeScope extends InheritedComponent {
  const ThemeScope({required this.theme, required super.child, super.key});
  final ThemeConfig theme;

  static ThemeConfig of(BuildContext context) {
    final scope = context.dependOnInheritedComponentOfExactType<ThemeScope>();
    assert(scope != null, 'No ThemeScope found in context');
    return scope!.theme;
  }

  @override
  bool updateShouldNotify(ThemeScope oldComponent) => theme != oldComponent.theme;
}

// In any deep descendant:
class ThemedButton extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    final theme = ThemeScope.of(context);
    return button(styles: Styles(backgroundColor: theme.primaryColor), [
      .text('Action'),
    ]);
  }
}
```

---

### 5.3 Localize Re-Renders with ListenableBuilder and package:listen
**Impact: MEDIUM-HIGH (Eliminates widespread full-tree rebuilds by isolating reactivity to specific subtrees)**

Calling `setState()` in a high-level `StatefulComponent` triggers a rebuild of that entire component and all of its descendants, causing unnecessary virtual DOM reconciliation.

Jaspr exports `ChangeNotifier`, `ValueNotifier`, and `Listenable` from `package:listen`, as well as `ListenableBuilder`. Use `ListenableBuilder` to narrow rebuilds strictly to the smallest subtree that actually displays the changing state.

**Incorrect (calling setState high in the tree, rebuilding static children):**

```dart
// Ordinary component inside a client island:
class Dashboard extends StatefulComponent {
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int notificationCount = 0;

  @override
  Component build(BuildContext context) {
    // Every time notificationCount changes, the ENTIRE dashboard re-renders:
    return div([
      HeavySidebar(),
      LargeDataGrid(),
      Badge(count: notificationCount),
    ]);
  }
}
```

**Correct (isolating updates to a ListenableBuilder):**

```dart
// Ordinary component inside an existing client island:
class Dashboard extends StatelessComponent {
  const Dashboard({required this.notifications, super.key});
  final ValueNotifier<int> notifications;

  @override
  Component build(BuildContext context) {
    return div([
      const HeavySidebar(), // Never rebuilds when count changes!
      const LargeDataGrid(),
      ListenableBuilder(
        listenable: notifications,
        // Only this tiny closure rebuilds:
        builder: (context) => Badge(count: notifications.value),
      ),
    ]);
  }
}
```

---

## 6. Styling & CSS Optimization

### 6.1 Co-Locate Styles with Components Using the @css Annotation
**Impact: MEDIUM-HIGH (Keeps component logic and design together while generating external CSS stylesheets)**

Jaspr provides the `@css` annotation to define styles directly alongside the component that uses them.

In `server` and `static` modes, Jaspr automatically collects all `@css` declarations across your components into a unified stylesheet.

**Always recommend standalone mode:** For production applications, always configure `styles: standalone` in `pubspec.yaml`:

```yaml
jaspr:
  styles: standalone
```

This extracts all `@css` styles into an external, cacheable `.css` file (instead of embedding them as an inline `<style>` tag during pre-rendering) and inserts a `<link>` in `<head>`, minimizing initial HTML payload size and leveraging browser HTTP caching.

Always define component-specific styling in a `@css static List<StyleRule> get styles` getter.

**Incorrect (relying on separate untyped external css files or scattering style rules):**

```dart
// styles.css: .card-custom { padding: 16px; background: white; }
// Component is decoupled from styles; no type-checking on style values:
class Card extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return div(classes: 'card-custom', [ ... ]);
  }
}
```

**Correct (co-locating type-safe styles with the component using @css):**

```dart
class Card extends StatelessComponent {
  const Card({super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'card', [ ... ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.card', [
      css('&').styles(
        padding: .all(16.px),
        backgroundColor: Colors.white,
        radius: .circular(8.px),
        shadow: BoxShadow(
          offsetX: 0.px,
          offsetY: 2.px,
          blur: 4.px,
          color: Colors.black.withOpacity(0.1),
        ),
      ),
      css('&:hover').styles(
        backgroundColor: Color('#f9fafb'),
      ),
    ]),
  ];
}
```

---

### 6.2 Restrict Inline Styles to Truly Dynamic Runtime Values
**Impact: MEDIUM (Eliminates bloated HTML markup and enables browser caching of CSS rules)**

Passing `styles: Styles(...)` directly into HTML components outputs an inline `style="..."` attribute on the HTML element. When used for static styling across repeating list elements, inline styles significantly inflate the HTML payload size and prevent the browser from caching CSS rules.

- **Rule 1:** Use `@css` for static rules, hover states, animations, and media queries.
- **Rule 2:** Restrict inline `styles:` exclusively to **dynamic values** computed at runtime (e.g. coordinates driven by mouse position, progress bar widths, or user-selected colors).

**Incorrect (using inline styles for static properties on repeating components):**

```dart
// Repeated 100 times in a list: generates huge HTML markup:
div(
  styles: Styles(
    display: .flex,
    padding: .all(12.px),
    border: .all(width: 1.px, color: Colors.grey),
    radius: .circular(6.px),
  ),
  [ ... ],
)
```

**Correct (static properties moved to @css class, inline reserved for dynamic state):**

```dart
div(
  classes: 'progress-bar-container',
  [
    div(
      classes: 'progress-bar-fill',
      // ONLY the dynamic width percentage is rendered inline:
      styles: Styles(width: (progress * 100).percent),
      [],
    ),
  ],
)
```

---

### 6.3 Use Typed Unit Extensions and Dot-Shorthands
**Impact: MEDIUM (Guarantees valid CSS values, eliminates unit string typos, and optimizes readability)**

Jaspr provides typed numeric extensions for all CSS measurement units (`.px`, `.pt`, `.rem`, `.em`, `.percent`, `.vh`, `.vw`) and dot-shorthands for enums and utility constructors (`.all()`, `.symmetric()`, `.flex`, `.center`, `.zero`).

Always use these typed extensions instead of manual unit constructors or raw string values.

**Incorrect (verbose constructor calls or raw strings):**

```dart
Styles(
  width: Unit.pixels(200),
  height: Unit.percent(100),
  padding: Padding.all(Unit.rem(1.5)),
  display: Display.flex,
  justifyContent: JustifyContent.center,
)
```

**Correct (typed extensions and dot-shorthands):**

```dart
Styles(
  width: 200.px,
  height: 100.percent,
  padding: .all(1.5.rem),
  display: .flex,
  justifyContent: .center,
)
```

---

### 6.4 Follow Native CSS Nesting Rules in css()
**Impact: HIGH (Prevents silent CSS styling bugs caused by invalid selector concatenation)**

Jaspr's `css()` function compiles nested rules directly into standard [Native CSS Nesting](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_nesting).

In native CSS nesting:
- The `&` symbol represents the parent selector (e.g., `css('&:hover')`, `css('&.active')`, `css('& > span')`).
- Concatenating suffixes onto `&` (such as `css('&-item')` inside `css('.list')` to mean `.list-item`) **is not supported in native CSS nesting**. It will not produce `.list-item`.

Always write suffix variant classes as separate rules.

**Incorrect (attempting selector name concatenation):**

```dart
css('.button', [
  // INVALID in native CSS nesting: Does NOT produce .button-primary!
  css('&-primary').styles(
    backgroundColor: Colors.blue,
  ),
])
```

**Correct (separate rules for suffix variants, '&' reserved for pseudo-classes and compound selectors):**

```dart
// Parent rule
css('.button', [
  css('&').styles(padding: .all(8.px)),
  // Pseudo-classes are completely valid:
  css('&:hover').styles(opacity: 0.9),
  // Child element selectors are valid:
  css('& > svg').styles(width: 16.px),
]),

// Modifier variant written as its own rule:
css('.button-primary', [
  css('&').styles(backgroundColor: Colors.blue, color: Colors.white),
])
```

---

## 7. JS Interop & Web Performance

### 7.1 Use web.EventStreamProviders for Global Event Streams
**Impact: LOW-MEDIUM (Provides typed Dart Streams for browser window and document events)**

When listening to global browser events (such as `window.onResize`, `window.onScroll`, `document.onKeyDown`), avoid using raw `addEventListener` callbacks or untyped JS functions.

`package:universal_web` (and `package:web`) provides `EventStreamProviders` which transforms DOM events into typed Dart `Stream`s. This gives you full access to standard Dart `Stream` operators (`where`, `map`, `distinct`), stream transformers or extensions (such as `debounce` from `package:stream_transform`), and safe cancellation via `StreamSubscription`.

**Incorrect (raw string-based addEventListener calls without typed event handling):**

```dart
// Untyped, difficult to compose with Dart streams:
web.window.addEventListener('scroll', ((web.Event event) {
  print('Scrolled');
}).toJS);
```

**Correct (typed EventStreamProvider with Dart StreamSubscription):**

```dart
// Typed, returns a standard Dart Stream:
final subscription = web.EventStreamProviders.scrollEvent
    .forTarget(web.window)
    .listen((web.Event event) {
      print('Scrolled: ${web.window.scrollY}');
    });

// Easily cancelled in dispose():
subscription.cancel();
```

---

### 7.2 Use Dart Extension Types Implementing JSObject for Zero-Cost JS Interop
**Impact: MEDIUM (Eliminates wrapper object allocation overhead and provides compile-time type safety)**

Modern Dart JS interop uses extension types on `JSObject`. Unlike legacy wrapper classes that wrap JS objects in a separate Dart heap allocation, extension types are zero-cost compile-time abstractions erased at runtime.

When binding to third-party JavaScript libraries or JS object literals:
- Define an `extension type Name._(JSObject _) implements JSObject`.
- Use `@anonymous` on extension types intended to represent JavaScript object options/configs.
- Use `.toJS` and `.toDart` extension properties for explicit type conversions.

**Incorrect (legacy untyped interop or manually constructed maps passed to JS):**

```dart
// Untyped, unsafe, and incurs conversion overhead:
void initMap(Map<String, dynamic> config) {
  // Passing raw Dart Map to JS requires costly deep-conversions
}
```

**Correct (zero-cost typed anonymous extension type):**

```dart
import 'dart:js_interop';

@JS()
@anonymous
extension type MapConfig._(JSObject _) implements JSObject {
  external factory MapConfig({
    JSNumber zoom,
    JSString style,
  });

  external JSNumber get zoom;
  external JSString get style;
}

@JS('createMap')
external void createMap(JSString containerId, MapConfig config);

void setupMap() {
  createMap(
    'map-root'.toJS,
    MapConfig(zoom: 12.toJS, style: 'dark'.toJS),
  );
}
```

---

## 8. Content Sites with jaspr_content

### 8.1 Register Custom Components in ContentApp for Rich Embedded Content
**Impact: MEDIUM-HIGH (Allows embedding interactive client widgets and rich callouts directly inside Markdown content)**

`jaspr_content` enables authoring rich content sites where Markdown files can include custom HTML-like tags (e.g. `<Warning>`, `<Tabs>`, `<Demo>`).

Instead of writing fragile raw HTML snippets or scripts inside Markdown files, register components using `ContentApp(components: [...])`. You can use built-in components (such as `Callout()`, `Tabs()`, `FileTree()`), or create custom components by constructing a `CustomComponent` or extending `CustomComponentBase`. This enables:
- Seamless embedding of interactive `@client` islands inside static Markdown documentation.
- Consistent styling and layout across all content pages.
- Access to parsed tag attributes as strongly typed component parameters.

**Incorrect (raw HTML or script embeds inside markdown):**

```markdown
<!-- Fragile, untyped, and unmaintainable across documentation pages: -->
<div class="custom-callout-warning" style="border-left: 4px solid orange; padding: 10px;">
  <strong>Warning:</strong> Be careful with this configuration!
</div>
```

**Correct (defining and registering custom components in ContentApp):**

```dart
// lib/main.server.dart
import 'package:jaspr/server.dart';
import 'package:jaspr_content/components/callout.dart';
import 'package:jaspr_content/components/tabs.dart';
import 'package:jaspr_content/jaspr_content.dart';

import 'main.server.options.dart';

void main() {
  Jaspr.initializeApp(options: defaultServerOptions);

  runApp(ContentApp(
    parsers: [
      MarkdownParser(),
    ],
    components: [
      // 1. Built-in components:
      Callout(),
      Tabs(),

      // 2. Custom components via CustomComponent factory:
      CustomComponent(
        pattern: 'Demo',
        builder: (name, attributes, child) => DemoWidget(
          title: attributes['title'] ?? 'Live Demo',
          child: child,
        ),
      ),
    ],
  ));
}
```

In your Markdown (`content/guide.md`):

```markdown
# Configuration Guide

<Warning>
  Be careful with this configuration!
</Warning>

<Demo title="Interactive Preview">
  Check out this demo component embedded directly in markdown.
</Demo>
```

---

### 8.2 Use Structured Frontmatter for Page Metadata and Layout Selection
**Impact: MEDIUM (Enables automated metadata generation, SEO tags, and layout routing)**

`jaspr_content` parses YAML frontmatter at the head of content Markdown files. This frontmatter drives automatic metadata generation (page titles, `<meta name="description">`, OpenGraph tags) and layout selection (`layout: docs`, `layout: blog`).

Always provide structured frontmatter on Markdown pages rather than hardcoding headings and metadata manually.

**Incorrect (missing frontmatter, leaving pages without metadata or automated layout):**

```markdown
# My Post
Posted on Jan 2026 by Author

Here is the body text...
```

**Correct (structured frontmatter providing layout and SEO metadata):**

```markdown
---
title: Getting Started with Jaspr
description: A comprehensive beginner's guide to building with Jaspr.
layout: docs
date: 2026-10-21
tags: [tutorial, beginner]
---

Here is the body text...
```

---

### 8.3 Use ContentTheme and Tokenized CSS Variables for Universal Theming
**Impact: MEDIUM (Guarantees consistent dark/light mode adaptation across built-in and custom components)**

`jaspr_content` includes a built-in theming system (`ContentTheme`) that automatically handles light and dark mode through CSS custom properties (variables like `--primary`, `--background`, `--text`, and `--content-font`).

Every `ColorToken` (such as `ContentColors.background` or `ContentColors.text`) implements `Color` directly and resolves to `var(--name)` in CSS.

When styling custom components or creating layouts:
- Use `ContentColors.<token>` directly anywhere a `Color` is expected.
- Add custom color tokens with light and dark variants using `ColorToken('token-name', lightColor, dark: darkColor)` and provide them to `ContentTheme(colors: [...])`.
- In component styles, reference theme variables via `ContentColors` tokens, custom `ColorToken`s, or `ContentTheme.currentFont` instead of hardcoded hex values, ensuring seamless dark mode switching.

**Incorrect (hardcoding fixed color values that break in dark mode):**

```dart
@css
static List<StyleRule> get styles => [
  css('.custom-card').styles(
    backgroundColor: Colors.white, // Breaks in dark mode!
    color: Colors.black,
  ),
];
```

**Correct (leveraging ContentTheme tokens and custom ColorToken):**

```dart
// 1. Defining a custom color token with light and dark variants:
final customAccent = ColorToken(
  'custom-accent',
  Colors.blue,
  dark: Colors.lightBlue,
);

// 2. Setting the theme and registering custom tokens in ContentApp:
ContentApp(
  theme: ContentTheme(
    primary: Colors.indigo,
    colors: [customAccent],
  ),
  ...
)

// 3. Using tokens directly as Colors in component styles:
@css
static List<StyleRule> get styles => [
  css('.custom-card').styles(
    backgroundColor: ContentColors.background, // ColorToken implements Color directly
    color: ContentColors.text,
    border: .all(color: customAccent),
    fontFamily: ContentTheme.currentFont,
  ),
];
```

---

## 9. Flutter Embedding

### 9.1 Use @Import.onWeb and Deferred Imports to Isolate and Lazy-Load Flutter Widgets
**Impact: CRITICAL (Prevents Dart VM compilation crashes during SSR and delays heavy Flutter bundle downloads until needed)**

Flutter web widgets import the Flutter framework and web rendering engines, which cannot run on the Dart VM during server pre-rendering. Furthermore, Flutter applications introduce significant JavaScript/Wasm code that shouldn't block the initial Jaspr page load.

When embedding a Flutter app using `jaspr_flutter_embed`:
1. Isolate the Flutter widget import using `@Import.onWeb('path/to/flutter_app.dart', show: [#MyFlutterApp])`.
2. Import the generated `<filename>.imports.dart` using a **deferred import**: `import '<filename>.imports.dart' deferred as widget;`.
3. Use `FlutterEmbedView.deferred` with `loadLibrary: widget.loadLibrary()` and `builder: () => widget.MyFlutterApp(...)`.

This ensures the surrounding Jaspr page renders full HTML on the server without crashing, and delays loading the Flutter JS bundle until the component is mounted in the browser.

**Incorrect (direct unisolated import of Flutter widget in Jaspr server code):**

```dart
// lib/components/embed_section.dart
import 'my_flutter_app.dart'; // CRASHES during `jaspr build` or `jaspr serve` on the server!

class EmbedSection extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return FlutterEmbedView(
      widget: MyFlutterApp(),
    );
  }
}
```

**Correct (isolated web import with deferred loading via FlutterEmbedView.deferred):**

```dart
// lib/components/embed_section.dart
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_flutter_embed/jaspr_flutter_embed.dart';

// 1. Isolate Flutter widget for web only:
@Import.onWeb('my_flutter_app.dart', show: [#MyFlutterApp])
// 2. Import as deferred to lazy-load the Flutter bundle:
import 'embed_section.imports.dart' deferred as widget;

// 3. Mark with @client so it hydrates in the browser and initializes Flutter:
@client
class EmbedSection extends StatelessComponent {
  const EmbedSection({super.key});

  @override
  Component build(BuildContext context) {
    // 4. Use FlutterEmbedView.deferred:
    return FlutterEmbedView.deferred(
      constraints: ViewConstraints(minWidth: 300, minHeight: 400),
      loader: div([.text('Loading Flutter experience...')]),
      loadLibrary: widget.loadLibrary(),
      builder: () => widget.MyFlutterApp(),
    );
  }
}
```

---
