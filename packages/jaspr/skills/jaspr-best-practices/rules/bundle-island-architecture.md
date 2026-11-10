---
title: Design Small, Focused Interactive Islands Rather Than Monolithic Client Trees
impact: CRITICAL
impactDescription: Drastically decreases downloaded JS/Wasm payload and minimizes hydration work
tags: bundle, client, islands, architecture
---

## Design Small, Focused Interactive Islands Rather Than Monolithic Client Trees

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
