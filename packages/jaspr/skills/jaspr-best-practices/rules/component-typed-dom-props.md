---
title: Prefer Typed DOM Parameters Over Raw Attributes and Events Maps
impact: MEDIUM
impactDescription: Guarantees compile-time type safety, IDE autocompletion, and optimal event listener binding
tags: component, dom, safety, events
---

## Prefer Typed DOM Parameters Over Raw Attributes and Events Maps

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
