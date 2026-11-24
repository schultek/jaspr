---
title: Use GlobalNodeKey with Explicit HTML Element Types for Direct DOM Access
impact: MEDIUM
impactDescription: Guarantees type safety, prevents element mismatch, and avoids fragile manual DOM queries
tags: component, dom, global-node-key, input, focus
---

## Use GlobalNodeKey with Explicit HTML Element Types for Direct DOM Access

**Impact: MEDIUM (Guarantees type safety, prevents element mismatch, and avoids fragile manual DOM queries)**

When you need direct, imperative access to an underlying DOM node (such as focusing an `<input>`, measuring bounding rects, controlling video/audio playback, or interacting with a `<canvas>`), use `GlobalNodeKey`.

- **Rule 1:** Always specify the concrete element type as the generic type parameter (e.g. `GlobalNodeKey<web.HTMLInputElement>()`), not `web.Element` or `dynamic`.
- **Rule 2:** Access `key.currentNode` only in lifecycle callbacks (`initState` post-frame / event listeners) and guarded with `if (kIsWeb)`.
- **Rule 3:** Do NOT use `GlobalNodeKey` to imperatively mutate innerHTML, append child elements, or manually bind event listeners. Use Jaspr's declarative components and event bindings instead.

**Incorrect (manual DOM queries or untyped keys):**

```dart
// Fragile, untyped, and risks querying the wrong element across components:
void focusInput() {
  if (kIsWeb) {
    (web.document.getElementById('my-input') as web.HTMLInputElement).focus();
  }
}
```

**Correct (typed GlobalNodeKey linked directly to component):**

```dart
import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';
import 'package:universal_web/web.dart' as web;

@client
class SearchField extends StatefulComponent {
  const SearchField({super.key});

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  // Strongly typed to the HTMLInputElement:
  final inputKey = GlobalNodeKey<web.HTMLInputElement>();

  void handleFocus() {
    if (kIsWeb) {
      inputKey.currentNode?.focus();
    }
  }

  @override
  Component build(BuildContext context) {
    return div([
      input(key: inputKey, type: InputType.text, attributes: {'placeholder': 'Search...'}),
      button(onClick: handleFocus, [.text('Focus Input')]),
    ]);
  }
}
```
