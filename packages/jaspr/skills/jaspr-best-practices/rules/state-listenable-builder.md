---
title: Localize Re-Renders with ListenableBuilder and package:listen
impact: MEDIUM-HIGH
impactDescription: Eliminates widespread full-tree rebuilds by isolating reactivity to specific subtrees
tags: state, reactivity, listen, performance
---

## Localize Re-Renders with ListenableBuilder and package:listen

**Impact: MEDIUM-HIGH (Eliminates widespread full-tree rebuilds by isolating reactivity to specific subtrees)**

Calling `setState()` in a high-level `StatefulComponent` triggers a rebuild of that entire component and all of its descendants, causing unnecessary virtual DOM reconciliation.

Jaspr exports `ChangeNotifier`, `ValueNotifier`, and `Listenable` from `package:listen`, as well as `ListenableBuilder`. Use `ListenableBuilder` to narrow rebuilds strictly to the smallest subtree that actually displays the changing state.

**Incorrect (calling setState high in the tree, rebuilding static children):**

```dart
@client
class Dashboard extends StatefulComponent {
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int notificationCount = 0;

  @override
  Component build(BuildContext context) {
    // Every time notificationCount changes, the ENTIRE dashboard re-renders:
    return div([
      HeavySidebar(),
      LargeDataGrid(),
      Badge(count: notificationCount),
    ]);
  }
}
```

**Correct (isolating updates to a ListenableBuilder):**

```dart
@client
class Dashboard extends StatelessComponent {
  const Dashboard({required this.notifications, super.key});
  final ValueNotifier<int> notifications;

  @override
  Component build(BuildContext context) {
    return div([
      const HeavySidebar(), // Never rebuilds when count changes!
      const LargeDataGrid(),
      ListenableBuilder(
        listenable: notifications,
        // Only this tiny closure rebuilds:
        builder: (context) => Badge(count: notifications.value),
      ),
    ]);
  }
}
```
