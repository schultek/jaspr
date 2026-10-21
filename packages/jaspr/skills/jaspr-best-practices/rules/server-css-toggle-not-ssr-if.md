---
title: Toggle Server Component Visibility with CSS, Never Conditional Dart If
impact: CRITICAL
impactDescription: Prevents missing DOM nodes and broken hydration when toggling client state
tags: server, server-components, ssr, hydration
---

## Toggle Server Component Visibility with CSS, Never Conditional Dart If

**Impact: CRITICAL (Prevents missing DOM nodes and broken hydration when toggling client state)**

Server Components are executed and rendered **only on the server during the initial Server-Side Rendering (SSR) build**. The browser client does not receive the Dart code required to build the server component.

If a server component passed as a parameter is placed inside a Dart `if (condition)` check that evaluates to `false` during SSR, it is never rendered on the server. When that condition subsequently becomes `true` in the browser, the client attempts to render the component but has no code to do so, resulting in an empty view.

Always ensure server components are included in the component tree during SSR, and toggle their visibility interactively on the client using CSS classes (e.g., `display: none` or `.hidden`).

**Incorrect (component not rendered during SSR, renders as empty when opened):**

```dart
@client
class Accordion extends StatefulComponent {
  const Accordion({required this.details, super.key});
  final Component details;

  @override
  State<Accordion> createState() => _AccordionState();
}

class _AccordionState extends State<Accordion> {
  // Evaluates to false during initial SSR!
  bool isOpen = false; 

  @override
  Component build(BuildContext context) {
    return div([
      button(onClick: () => setState(() => isOpen = !isOpen), [.text('Details')]),
      // BROKEN: 'details' was never rendered on the server!
      // When isOpen becomes true on the client, nothing appears.
      if (isOpen) component.details, 
    ]);
  }
}
```

**Correct (rendered on server, visibility toggled via CSS):**

```dart
@client
class Accordion extends StatefulComponent {
  const Accordion({required this.details, super.key});
  final Component details;

  @override
  State<Accordion> createState() => _AccordionState();
}

class _AccordionState extends State<Accordion> {
  bool isOpen = false;

  @override
  Component build(BuildContext context) {
    return div([
      button(onClick: () => setState(() => isOpen = !isOpen), [.text('Details')]),
      // ALWAYS rendered during SSR. Toggled via CSS class.
      div(
        classes: 'accordion-content ${isOpen ? 'expanded' : 'collapsed'}',
        [component.details],
      ),
    ]);
  }
}
```
