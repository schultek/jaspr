---
title: Guard Browser API Calls with kIsWeb When Using universal_web
impact: HIGH
impactDescription: Prevents UnsupportedError exceptions during server-side pre-rendering
tags: bundle, web, universal_web, ssr
---

## Guard Browser API Calls with kIsWeb When Using universal_web

**Impact: HIGH (Prevents UnsupportedError exceptions during server-side pre-rendering)**

`package:universal_web` provides cross-platform stubs for `package:web` and `dart:js_interop` so your shared components can compile cleanly on both the Dart VM (server) and the browser.

However, invoking browser APIs on the server (such as reading `web.window.innerWidth` or manipulating `web.document`) will throw an `UnsupportedError` at runtime during SSR. You must wrap any browser API invocations in `if (kIsWeb)`.

**Incorrect (accessing web APIs without kIsWeb guard during SSR):**

```dart
import 'package:universal_web/web.dart' as web;

class ViewportIndicator extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    // CRASHES during server-side pre-rendering!
    final width = web.window.innerWidth; 
    return div([.text('Width: $width')]);
  }
}
```

**Correct (guarded inside lifecycle methods or event callbacks with kIsWeb):**

```dart
import 'package:universal_web/web.dart' as web;

@client
class ViewportIndicator extends StatefulComponent {
  const ViewportIndicator({super.key});

  @override
  State<ViewportIndicator> createState() => _ViewportIndicatorState();
}

class _ViewportIndicatorState extends State<ViewportIndicator> {
  int? width;

  @override
  void initState() {
    super.initState();
    // Guarded: only runs in browser environment
    if (kIsWeb) {
      width = web.window.innerWidth;
    }
  }

  @override
  Component build(BuildContext context) {
    return div([.text('Width: ${width ?? "calculating..."}')]);
  }
}
```
