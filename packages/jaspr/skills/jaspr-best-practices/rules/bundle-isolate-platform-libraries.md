---
title: Strictly Isolate Platform Libraries Between Server and Client
impact: CRITICAL
impactDescription: Eliminates build failures and runtime crashes caused by incompatible platform imports
tags: bundle, imports, isolation, server, client
---

## Strictly Isolate Platform Libraries Between Server and Client

**Impact: CRITICAL (Eliminates build failures and runtime crashes caused by incompatible platform imports)**

In `server` and `static` modes, Jaspr code runs in two different environments:
1. **Server environment (Dart VM):** Compiles natively and has access to `dart:io`, databases, and files, but CANNOT import `dart:js_interop` or `package:web`.
2. **Client environment (Browser JS/Wasm):** Compiles to JS/Wasm and has access to browser APIs, but CANNOT import `dart:io` or `dart:ffi`.

To prevent compilation failures:
- Keep `dart:io` imports strictly inside `.server.dart` entrypoints and server-only files.
- Keep `dart:js_interop` and `package:web` strictly inside `.client.dart` entrypoints and browser-only files.
- For shared code, use `package:universal_web` and conditionally check `if (kIsWeb)`.

**Incorrect (importing dart:io in code reachable by client or dart:js_interop reachable by server):**

```dart
// lib/components/my_component.dart - shared file!
import 'dart:io'; // Breaks client compilation when compiled to JS/Wasm!
import 'package:web/web.dart'; // Breaks server compilation on Dart VM!

class MyComponent extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return div([.text('Hello')]);
  }
}
```

**Correct (entrypoints properly split and shared code safe):**

```dart
// lib/main.server.dart (Server only)
import 'dart:io'; // Safe here!
import 'package:jaspr/server.dart';

// lib/main.client.dart (Client only)
import 'package:jaspr/client.dart';

// lib/components/shared_component.dart (Shared code)
import 'package:universal_web/web.dart' as web; // Safe stub on VM!
import 'package:jaspr/jaspr.dart';

class SharedComponent extends StatelessComponent {
  void handleClick() {
    if (kIsWeb) {
      web.window.alert('Safe browser alert!');
    }
  }

  @override
  Component build(BuildContext context) => button(onClick: handleClick, [.text('Click')]);
}
```
