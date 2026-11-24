---
title: Use Dot-Shorthands for Core Component Primitives
impact: MEDIUM
impactDescription: Standardizes idiomatic Jaspr syntax, improves readability, and leverages constructor tear-offs
tags: component, syntax, shorthands, clean-code
---

## Use Dot-Shorthands for Core Component Primitives

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
