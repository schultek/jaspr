---
title: Use @Import.onWeb and Deferred Imports to Isolate and Lazy-Load Flutter Widgets
impact: CRITICAL
impactDescription: Prevents Dart VM compilation crashes during SSR and delays heavy Flutter bundle downloads until needed
tags: flutter, embed, ssr, deferred, imports, jaspr_flutter_embed
---

## Use @Import.onWeb and Deferred Imports to Isolate and Lazy-Load Flutter Widgets

**Impact: CRITICAL (Prevents Dart VM compilation crashes during SSR and delays heavy Flutter bundle downloads until needed)**

Flutter web widgets import the Flutter framework and web rendering engines, which cannot run on the Dart VM during server pre-rendering. Furthermore, Flutter applications introduce significant JavaScript/Wasm code that shouldn't block the initial Jaspr page load.

When embedding a Flutter app using `jaspr_flutter_embed`:
1. Isolate the Flutter widget import using `@Import.onWeb('path/to/flutter_app.dart', show: [#MyFlutterApp])`.
2. Import the generated `<filename>.imports.dart` using a **deferred import**: `import '<filename>.imports.dart' deferred as widget;`.
3. Use `FlutterEmbedView.deferred` with `loadLibrary: widget.loadLibrary()` and `builder: () => widget.MyFlutterApp(...)`.

This ensures the surrounding Jaspr page renders full HTML on the server without crashing, and delays loading the Flutter JS bundle until the component is mounted in the browser.

**Incorrect (direct unisolated import of Flutter widget in Jaspr server code):**

```dart
// lib/components/embed_section.dart
import 'my_flutter_app.dart'; // CRASHES during `jaspr build` or `jaspr serve` on the server!

class EmbedSection extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return FlutterEmbedView(
      widget: MyFlutterApp(),
    );
  }
}
```

**Correct (isolated web import with deferred loading via FlutterEmbedView.deferred):**

```dart
// lib/components/embed_section.dart
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_flutter_embed/jaspr_flutter_embed.dart';

// 1. Isolate Flutter widget for web only:
@Import.onWeb('my_flutter_app.dart', show: [#MyFlutterApp])
// 2. Import as deferred to lazy-load the Flutter bundle:
import 'embed_section.imports.dart' deferred as widget;

// 3. Mark with @client so it hydrates in the browser and initializes Flutter:
@client
class EmbedSection extends StatelessComponent {
  const EmbedSection({super.key});

  @override
  Component build(BuildContext context) {
    // 4. Use FlutterEmbedView.deferred:
    return FlutterEmbedView.deferred(
      constraints: const ViewConstraints(minWidth: 300, minHeight: 400),
      loader: div([.text('Loading Flutter experience...')]),
      loadLibrary: widget.loadLibrary(),
      builder: () => widget.MyFlutterApp(),
    );
  }
}
```
