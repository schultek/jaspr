---
title: Use Dart Extension Types Implementing JSObject for Zero-Cost JS Interop
impact: MEDIUM
impactDescription: Eliminates wrapper object allocation overhead and provides compile-time type safety
tags: interop, js, extension-types, performance
---

## Use Dart Extension Types Implementing JSObject for Zero-Cost JS Interop

**Impact: MEDIUM (Eliminates wrapper object allocation overhead and provides compile-time type safety)**

Modern Dart JS interop uses extension types on `JSObject`. Unlike legacy wrapper classes that wrap JS objects in a separate Dart heap allocation, extension types are zero-cost compile-time abstractions erased at runtime.

When binding to third-party JavaScript libraries or JS object literals:
- Define an `extension type Name._(JSObject _) implements JSObject`.
- Use `@anonymous` on extension types intended to represent JavaScript object options/configs.
- Use `.toJS` and `.toDart` extension properties for explicit type conversions.

**Incorrect (legacy untyped interop or manually constructed maps passed to JS):**

```dart
// Untyped, unsafe, and incurs conversion overhead:
void initMap(Map<String, dynamic> config) {
  // Passing raw Dart Map to JS requires costly deep-conversions
}
```

**Correct (zero-cost typed anonymous extension type):**

```dart
import 'dart:js_interop';

@JS()
@anonymous
extension type MapConfig._(JSObject _) implements JSObject {
  external factory MapConfig({
    JSNumber zoom,
    JSString style,
  });

  external JSNumber get zoom;
  external JSString get style;
}

@JS('createMap')
external void createMap(JSString containerId, MapConfig config);

void setupMap() {
  createMap(
    'map-root'.toJS,
    MapConfig(zoom: 12.toJS, style: 'dark'.toJS),
  );
}
```
