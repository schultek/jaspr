---
title: Use Server Components for Static Content Inside Interactive Shells
impact: CRITICAL
impactDescription: Eliminates client JS compilation and reduces bundle size to 0 KB for static content
tags: server, server-components, bundle, hydration
---

## Use Server Components for Static Content Inside Interactive Shells

**Impact: CRITICAL (Eliminates client JS compilation and reduces bundle size to 0 KB for static content)**

When an interactive container or layout shell (such as an expandable card, modal dialog, sidebar, or tab container) needs client interactivity, annotating it with `@client` traditionally pulls every nested child component into the client JavaScript bundle.

With Jaspr's Server Components, pass static or heavy subtrees as `Component` or `List<Component>` parameters to the `@client` component instead of hardcoding them inside the `@client` component's build method. Jaspr pre-renders them exclusively on the server and mounts the pre-rendered DOM elements into place during hydration without shipping their Dart code to the client.

**Incorrect (entire static subtree compiled and shipped to the client):**

```dart
// lib/components/shell.dart
@client
class CollapsibleShell extends StatefulComponent {
  const CollapsibleShell({super.key});

  @override
  State<CollapsibleShell> createState() => _CollapsibleShellState();
}

class _CollapsibleShellState extends State<CollapsibleShell> {
  bool isOpen = true;

  @override
  Component build(BuildContext context) {
    return div([
      button(onClick: () => setState(() => isOpen = !isOpen), [.text('Toggle')]),
      // HeavyArticleContent and all its static children get bundled into client JS!
      HeavyArticleContent(), 
    ]);
  }
}
```

**Correct (static content passed as a Server Component parameter):**

```dart
// lib/components/shell.dart
@client
class CollapsibleShell extends StatefulComponent {
  const CollapsibleShell({required this.content, super.key});

  // Passed as parameter -> remains a Server Component
  final Component content;

  @override
  State<CollapsibleShell> createState() => _CollapsibleShellState();
}

class _CollapsibleShellState extends State<CollapsibleShell> {
  bool isOpen = true;

  @override
  Component build(BuildContext context) {
    return div([
      button(onClick: () => setState(() => isOpen = !isOpen), [.text('Toggle')]),
      div(
        classes: isOpen ? 'open' : 'hidden',
        [component.content], // Slotted in from server pre-render!
      ),
    ]);
  }
}

// lib/main.server.dart
CollapsibleShell(
  // HeavyArticleContent is rendered ONLY on the server:
  content: HeavyArticleContent(),
)
```
