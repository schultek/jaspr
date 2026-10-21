---
title: Use Component.apply to Style Server Components from Client Shells
impact: MEDIUM-HIGH
impactDescription: Allows dynamic styling and class augmentation of server-rendered markup without forcing components into the client scope
tags: server, styling, server-components, apply
---

## Use Component.apply to Style Server Components from Client Shells

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
      child: component.child,
    );
  }
}
```
