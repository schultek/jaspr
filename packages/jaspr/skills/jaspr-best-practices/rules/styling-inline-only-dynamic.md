---
title: Restrict Inline Styles to Truly Dynamic Runtime Values
impact: MEDIUM
impactDescription: Eliminates bloated HTML markup and enables browser caching of CSS rules
tags: styling, inline-styles, performance, html-size
---

## Restrict Inline Styles to Truly Dynamic Runtime Values

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
