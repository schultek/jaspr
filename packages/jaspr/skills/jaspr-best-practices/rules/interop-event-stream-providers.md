---
title: Use web.EventStreamProviders for Global Event Streams
impact: LOW-MEDIUM
impactDescription: Provides typed Dart Streams for browser window and document events
tags: interop, web, events, streams
---

## Use web.EventStreamProviders for Global Event Streams

**Impact: LOW-MEDIUM (Provides typed Dart Streams for browser window and document events)**

When listening to global browser events (such as `window.onResize`, `window.onScroll`, `document.onKeyDown`), avoid using raw `addEventListener` callbacks or untyped JS functions.

`package:universal_web` (and `package:web`) provides `EventStreamProviders` which transforms DOM events into typed Dart `Stream`s. This gives you full access to standard Dart `Stream` operators (`where`, `map`, `distinct`), stream transformers or extensions (such as `debounce` from `package:stream_transform`), and safe cancellation via `StreamSubscription`.

**Incorrect (raw string-based addEventListener calls without typed event handling):**

```dart
// Untyped, difficult to compose with Dart streams:
web.window.addEventListener('scroll', ((web.Event event) {
  print('Scrolled');
}).toJS);
```

**Correct (typed EventStreamProvider with Dart StreamSubscription):**

```dart
// Typed, returns a standard Dart Stream:
final subscription = web.EventStreamProviders.scrollEvent
    .forTarget(web.window)
    .listen((web.Event event) {
      print('Scrolled: ${web.window.scrollY}');
    });

// Easily cancelled in dispose():
subscription.cancel();
```
