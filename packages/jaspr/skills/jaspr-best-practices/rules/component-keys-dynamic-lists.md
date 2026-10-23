---
title: Assign Stable Keys When Rendering Dynamic Lists
impact: HIGH
impactDescription: Prevents incorrect DOM element reuse, lost input/focus state, and UI glitches
tags: component, keys, lists, rendering
---

## Assign Stable Keys When Rendering Dynamic Lists

**Impact: HIGH (Prevents incorrect DOM element reuse, lost input/focus state, and UI glitches)**

When rendering dynamic lists of components where items can be reordered, inserted, or removed, Jaspr uses the `key` property to match old elements to new components.

Without a unique, stable `Key`, Jaspr matches elements by positional index. This causes stateful child components to retain stale local state from previous elements, causes text inputs to lose focus, and triggers unnecessary DOM re-creation.

Always use a stable identifier (e.g. `ValueKey(item.id)`). Never use array indices as keys.

**Incorrect (missing keys or using list indices as keys):**

```dart
ul([
  // Flawed: no key or using index causes state mixing during reorder or deletion:
  for (var i = 0; i < todos.length; i++)
    TodoItem(todo: todos[i], key: ValueKey(i)),
])
```

**Correct (using a unique, stable business identifier):**

```dart
ul([
  for (final todo in todos)
    TodoItem(
      key: ValueKey(todo.id), // Stable across reorders and deletions
      todo: todo,
    ),
])
```
