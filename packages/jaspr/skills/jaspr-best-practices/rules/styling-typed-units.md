---
title: Use Typed Unit Extensions and Dot-Shorthands
impact: MEDIUM
impactDescription: Guarantees valid CSS values, eliminates unit string typos, and optimizes readability
tags: styling, units, shorthands, clean-code
---

## Use Typed Unit Extensions and Dot-Shorthands

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
