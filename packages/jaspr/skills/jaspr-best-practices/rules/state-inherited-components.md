---
title: Use InheritedComponent to Avoid Prop Drilling Across Deep Trees
impact: MEDIUM
impactDescription: Decouples intermediary components from shared dependencies and optimizes dependency tracking
tags: state, inherited-component, context, architecture
---

## Use InheritedComponent to Avoid Prop Drilling Across Deep Trees

**Impact: MEDIUM (Decouples intermediary components from shared dependencies and optimizes dependency tracking)**

Passing shared dependencies, user sessions, or theme configs through dozens of intermediate constructor parameters (prop drilling) tightly couples your component hierarchy and complicates maintenance.

Use Jaspr's `InheritedComponent` to provide data at the top of a subtree and allow any descendant to consume it using `context.dependOnInheritedComponentOfExactType<T>()`.

**Incorrect (prop drilling through every intermediary component):**

```dart
class AppShell extends StatelessComponent {
  const AppShell({required this.theme, super.key});
  final ThemeConfig theme;

  @override
  Component build(BuildContext context) => MainLayout(theme: theme);
}

class MainLayout extends StatelessComponent {
  const MainLayout({required this.theme, super.key});
  final ThemeConfig theme;

  @override
  Component build(BuildContext context) => Sidebar(theme: theme); // Intermediary just passing props
}
```

**Correct (providing via InheritedComponent and consuming directly where needed):**

```dart
class ThemeScope extends InheritedComponent {
  const ThemeScope({required this.theme, required super.child, super.key});
  final ThemeConfig theme;

  static ThemeConfig of(BuildContext context) {
    final scope = context.dependOnInheritedComponentOfExactType<ThemeScope>();
    assert(scope != null, 'No ThemeScope found in context');
    return scope!.theme;
  }

  @override
  bool updateShouldNotify(ThemeScope oldComponent) => theme != oldComponent.theme;
}

// In any deep descendant:
class ThemedButton extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    final theme = ThemeScope.of(context);
    return button(styles: Styles(backgroundColor: theme.primaryColor), [
      .text('Action'),
    ]);
  }
}
```
