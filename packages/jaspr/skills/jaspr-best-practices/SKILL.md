---
name: jaspr-best-practices
description: Comprehensive Jaspr performance and architecture guidelines. Covers Server Components, surgical hydration, bundle optimization, SSR data fetching, state management, and CSS-in-Dart patterns. Triggers when writing, reviewing, or refactoring Jaspr web components, pages, or full applications.
---

# Jaspr Best Practices

Comprehensive performance, architecture, and reliability guidelines for Jaspr web applications. Inspired by modern web engineering standards, this guide provides rules prioritized by impact to guide automated refactoring, code generation, and manual development.

## When to Apply

Reference these guidelines when:
- Designing new Jaspr components, layouts, or pages
- Deciding between Server Components and Client Components (`@client`)
- Implementing server-side data fetching or client-side interactivity
- Optimizing bundle size, Time-to-Interactive (TTI), or Largest Contentful Paint (LCP)
- Writing or reviewing type-safe CSS-in-Dart styles with `@css`
- Refactoring existing Jaspr codebases for the latest features and patterns

## Rule Categories by Priority

| Priority | Category | Impact | Prefix | Description |
|---|---|---|---|---|
| 1 | Server Components & Surgical Hydration | CRITICAL | `server-` | Use Server Components to keep non-interactive markup and heavy subtrees on the server. Eliminate client JavaScript bundle bloat, ensure correct SSR hydration, and maintain safe boundaries. |
| 2 | Bundle Size & Code Isolation | CRITICAL | `bundle-` | Strictly isolate platform-specific libraries (`dart:io` vs `dart:js_interop` / `package:web`), safeguard shared code with `kIsWeb`, and design compact interactive islands. |
| 3 | Async Data Fetching & Waterfalls | HIGH | `async-` | Perform data fetching on the server using `AsyncStatelessComponent` / `AsyncBuilder` to eliminate client-side loading waterfalls, parallelize independent requests, and defer await calls. |
| 4 | Component Architecture & Composition | MEDIUM-HIGH | `component-` | Follow idiomatic Jaspr component conventions: `const` constructors, stable keys for dynamic lists, dot-shorthands (`.text`, `.fragment`, `.empty`, `.apply`), typed DOM parameters, and primary constructors. |
| 5 | State & Reactivity Performance | MEDIUM | `state-` | Scope client-side state tightly to small interactive leaves, use `package:listen` with `ListenableBuilder` to localize re-renders, cleanly dispose listeners, and use `InheritedComponent` to avoid prop drilling. |
| 6 | Styling & CSS Optimization | MEDIUM | `styling-` | Co-locate styles using `@css`, avoid inline styles except for runtime-computed dynamic values, follow native CSS nesting rules, and use typed unit extensions. |
| 7 | JS Interop & Web Performance | LOW-MEDIUM | `interop-` | Use zero-overhead extension types implementing `JSObject`, bind to browser events using `web.EventStreamProviders`, and cleanly convert JS/Dart types. |
| 8 | Content Sites with jaspr_content | MEDIUM-HIGH | `content-` | Best practices for content-driven and documentation sites using `jaspr_content`: markdown parsing, custom component registration, route loaders, and frontmatter. |
| 9 | Flutter Embedding | HIGH | `flutter-` | Safely embed Flutter applications within Jaspr sites using `jaspr_flutter_embed`: platform isolation with `@Import.onWeb`, view constraints, and loading states. |

---

## Quick Reference

### 1. Server Components & Surgical Hydration (CRITICAL)

- [server-component-apply-styling](rules/server-component-apply-styling.md) — Use Component.apply to Style Server Components from Client Shells — Allows dynamic styling and class augmentation of server-rendered markup without forcing components into the client scope.
- [server-components-static-subtrees](rules/server-components-static-subtrees.md) — Use Server Components for Static Content Inside Interactive Shells — Eliminates client JS compilation and reduces bundle size to 0 KB for static content.
- [server-css-toggle-not-ssr-if](rules/server-css-toggle-not-ssr-if.md) — Toggle Server Component Visibility with CSS, Never Conditional Dart If — Prevents missing DOM nodes and broken hydration when toggling client state.
- [server-serializable-props](rules/server-serializable-props.md) — Ensure Non-Component Props Across @client Boundaries Are Serializable — Prevents serialization crashes during SSR and hydration decode errors in the browser.
- [server-uppermost-client-boundary](rules/server-uppermost-client-boundary.md) — Only Annotate the Root Component of an Interactive Client Island — Avoids unnecessary client component registrations and clarifies island boundaries.

### 2. Bundle Size & Code Isolation (CRITICAL)

- [bundle-island-architecture](rules/bundle-island-architecture.md) — Design Small, Focused Interactive Islands Rather Than Monolithic Client Trees — Drastically decreases downloaded JS/Wasm payload and minimizes hydration work.
- [bundle-isolate-platform-libraries](rules/bundle-isolate-platform-libraries.md) — Strictly Isolate Platform Libraries Between Server and Client — Eliminates build failures and runtime crashes caused by incompatible platform imports.
- [bundle-universal-web-guard](rules/bundle-universal-web-guard.md) — Guard Browser API Calls with kIsWeb When Using universal_web — Prevents UnsupportedError exceptions during server-side pre-rendering.

### 3. Async Data Fetching & Waterfalls (HIGH)

- [async-defer-await](rules/async-defer-await.md) — Defer Await Until Value is Needed in Conditional Branches — Avoids paying latency cost when early checks bypass the need for fetched data.
- [async-parallel-fetches](rules/async-parallel-fetches.md) — Use Future.wait for Independent Asynchronous Operations — Cuts server response time from the sum of requests to the longest single request.
- [async-server-components-for-data](rules/async-server-components-for-data.md) — Fetch Data on the Server with AsyncStatelessComponent to Eliminate Client Waterfalls — Eliminates loading spinners, renders full HTML on initial request, and improves SEO/LCP.

### 4. Component Architecture & Composition (MEDIUM-HIGH)

- [component-const-constructors](rules/component-const-constructors.md) — Use const Constructors for Components — Prevents redundant object allocations and optimizes virtual DOM reconciliation.
- [component-dot-shorthands](rules/component-dot-shorthands.md) — Use Dot-Shorthands for Core Component Primitives — Standardizes idiomatic Jaspr syntax, improves readability, and leverages constructor tear-offs.
- [component-global-node-key](rules/component-global-node-key.md) — Use GlobalNodeKey with Explicit HTML Element Types for Direct DOM Access — Guarantees type safety, prevents element mismatch, and avoids fragile manual DOM queries.
- [component-keys-dynamic-lists](rules/component-keys-dynamic-lists.md) — Assign Stable Keys When Rendering Dynamic Lists — Prevents incorrect DOM element reuse, lost input/focus state, and UI glitches.
- [component-primary-constructors](rules/component-primary-constructors.md) — Use Dart Primary Constructors for Concise Component Definitions — Eliminates boilerplate constructor and field declarations in component classes.
- [component-typed-dom-props](rules/component-typed-dom-props.md) — Prefer Typed DOM Parameters Over Raw Attributes and Events Maps — Guarantees compile-time type safety, IDE autocompletion, and optimal event listener binding.

### 5. State & Reactivity Performance (MEDIUM)

- [state-dispose-listeners](rules/state-dispose-listeners.md) — Always Clean Up Subscriptions, Streams, and Notifiers in dispose() — Prevents memory leaks and zombie listeners executing callbacks on unmounted components.
- [state-inherited-components](rules/state-inherited-components.md) — Use InheritedComponent to Avoid Prop Drilling Across Deep Trees — Decouples intermediary components from shared dependencies and optimizes dependency tracking.
- [state-listenable-builder](rules/state-listenable-builder.md) — Localize Re-Renders with ListenableBuilder and package:listen — Eliminates widespread full-tree rebuilds by isolating reactivity to specific subtrees.

### 6. Styling & CSS Optimization (MEDIUM)

- [styling-colocate-with-at-css](rules/styling-colocate-with-at-css.md) — Co-Locate Styles with Components Using the @css Annotation — Keeps component logic and design together while generating external CSS stylesheets.
- [styling-inline-only-dynamic](rules/styling-inline-only-dynamic.md) — Restrict Inline Styles to Truly Dynamic Runtime Values — Eliminates bloated HTML markup and enables browser caching of CSS rules.
- [styling-typed-units](rules/styling-typed-units.md) — Use Typed Unit Extensions and Dot-Shorthands — Guarantees valid CSS values, eliminates unit string typos, and optimizes readability.
- [styling-valid-css-nesting](rules/styling-valid-css-nesting.md) — Follow Native CSS Nesting Rules in css() — Prevents silent CSS styling bugs caused by invalid selector concatenation.

### 7. JS Interop & Web Performance (LOW-MEDIUM)

- [interop-event-stream-providers](rules/interop-event-stream-providers.md) — Use web.EventStreamProviders for Global Event Streams — Provides typed Dart Streams for browser window and document events.
- [interop-extension-types](rules/interop-extension-types.md) — Use Dart Extension Types Implementing JSObject for Zero-Cost JS Interop — Eliminates wrapper object allocation overhead and provides compile-time type safety.

### 8. Content Sites with jaspr_content (MEDIUM-HIGH)

- [content-custom-components](rules/content-custom-components.md) — Register Custom Components in ContentApp for Rich Embedded Content — Allows embedding interactive client widgets and rich callouts directly inside Markdown content.
- [content-structured-frontmatter](rules/content-structured-frontmatter.md) — Use Structured Frontmatter for Page Metadata and Layout Selection — Enables automated metadata generation, SEO tags, and layout routing.
- [content-theme-tokens](rules/content-theme-tokens.md) — Use ContentTheme and Tokenized CSS Variables for Universal Theming — Guarantees consistent dark/light mode adaptation across built-in and custom components.

### 9. Flutter Embedding (HIGH)

- [flutter-web-isolation-import](rules/flutter-web-isolation-import.md) — Use @Import.onWeb and Deferred Imports to Isolate and Lazy-Load Flutter Widgets — Prevents Dart VM compilation crashes during SSR and delays heavy Flutter bundle downloads until needed.

---

## Detailed Rules Reference

For an all-in-one compiled view of all rules complete with incorrect and correct code comparisons, see [AGENTS.md](AGENTS.md).

