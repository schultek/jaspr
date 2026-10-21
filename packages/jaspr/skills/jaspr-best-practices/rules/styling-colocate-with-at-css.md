---
title: Co-Locate Styles with Components Using the @css Annotation
impact: MEDIUM-HIGH
impactDescription: Keeps component logic and design together while generating deduplicated external CSS stylesheets
tags: styling, css, colocation, maintainability
---

## Co-Locate Styles with Components Using the @css Annotation

**Impact: MEDIUM-HIGH (Keeps component logic and design together while generating deduplicated external CSS stylesheets)**

Jaspr provides the `@css` annotation to define styles directly alongside the component that uses them.

In `server` and `static` modes, Jaspr automatically extracts all `@css` declarations across your components into a unified, deduplicated stylesheet during compilation or serving. This provides the modularity of CSS-in-JS without the runtime penalty of stylesheet injection in the browser.

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
