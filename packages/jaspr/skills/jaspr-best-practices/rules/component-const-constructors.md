---
title: Use const Constructors for Components
impact: MEDIUM-HIGH
impactDescription: Prevents redundant object allocations and optimizes virtual DOM reconciliation
tags: component, performance, const, memory
---

## Use const Constructors for Components

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
