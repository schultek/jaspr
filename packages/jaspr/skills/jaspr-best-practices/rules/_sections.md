# Rule Categories & Priorities

This file defines all categories, their priority ordering, impact levels, and prefix conventions.

---

## 1. Server Components & Surgical Hydration (`server-`)

**Impact:** CRITICAL  
**Description:** Use Server Components to keep non-interactive markup and heavy subtrees on the server. Eliminate client JavaScript bundle bloat, ensure correct SSR hydration, and maintain safe boundaries.

## 2. Bundle Size & Code Isolation (`bundle-`)

**Impact:** CRITICAL  
**Description:** Strictly isolate platform-specific libraries (`dart:io` vs `dart:js_interop` / `package:web`), safeguard shared code with `kIsWeb`, and design compact interactive islands.

## 3. Async Data Fetching & Waterfalls (`async-`)

**Impact:** HIGH  
**Description:** Perform data fetching on the server using `AsyncStatelessComponent` / `AsyncBuilder` to eliminate client-side loading waterfalls, parallelize independent requests, and defer await calls.

## 4. Component Architecture & Composition (`component-`)

**Impact:** MEDIUM-HIGH  
**Description:** Follow idiomatic Jaspr component conventions: `const` constructors, stable keys for dynamic lists, dot-shorthands (`.text`, `.fragment`, `.empty`, `.apply`), typed DOM parameters, and primary constructors.

## 5. State & Reactivity Performance (`state-`)

**Impact:** MEDIUM  
**Description:** Scope client-side state tightly to small interactive leaves, use `package:listen` with `ListenableBuilder` to localize re-renders, cleanly dispose listeners, and use `InheritedComponent` to avoid prop drilling.

## 6. Styling & CSS Optimization (`styling-`)

**Impact:** MEDIUM  
**Description:** Co-locate styles using `@css`, avoid inline styles except for runtime-computed dynamic values, follow native CSS nesting rules, and use typed unit extensions.

## 7. JS Interop & Web Performance (`interop-`)

**Impact:** LOW-MEDIUM  
**Description:** Use zero-overhead extension types implementing `JSObject`, bind to browser events using `web.EventStreamProviders`, and cleanly convert JS/Dart types.

## 8. Content Sites with jaspr_content (`content-`)

**Impact:** MEDIUM-HIGH  
**Description:** Best practices for content-driven and documentation sites using `jaspr_content`: markdown parsing, custom component registration, route loaders, and frontmatter.

## 9. Flutter Embedding (`flutter-`)

**Impact:** HIGH  
**Description:** Safely embed Flutter applications within Jaspr sites using `jaspr_flutter_embed`: platform isolation with `@Import.onWeb`, view constraints, and loading states.

