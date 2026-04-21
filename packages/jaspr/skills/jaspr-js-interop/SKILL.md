---
name: jaspr-js-interop
description: Effectively integrate with Javascript when building Jaspr web applications. Use this skill when wrapping an existing JS library, accessing browser-native APIs, or bridging code safely across environments.
metadata:
  jaspr_version: 0.23.0
---

## Rules for JS Interop

Dart makes accessing JavaScript simple using modern `js_interop`. Since Jaspr applications can be compiled to JavaScript or WebAssembly, utilizing Dart's explicit `js_interop` mechanism is required when you need to interface with raw JS variables, functions, or libraries.

### 1. Import Strategy

- **Rule 1:** In **server** or **static** mode, you MUST ALWAYS import `package:universal_web/js_interop.dart`. It acts as a safe stub during server-side processing without breaking compilation.
- **Rule 2:** In **server** or **static** mode, you MUST wrap any JS Interop execution in an `if (kIsWeb) { ... }` block to avoid throwing exceptions on the server during pre-rendering.
- **Rule 3:** In **client** mode, you can directly import `dart:js_interop`.
- **Rule 4:** For standard browser APIs (like `window.innerHeight`, `document`, DOM nodes), use `package:universal_web/web.dart` (or `package:web/web.dart` in client mode) instead of manually creating `js_interop` wrappers.

## Usage Examples

**Top Level Functions**

To bind directly to a globally available JS function or object, use `@JS()`:

```dart
@JS()
external void alert(JSString message);

void showAlert() {
  if (kIsWeb) {
    // Make sure to convert Dart String types using .toJS
    alert('Hello from Dart!'.toJS);
  }
}
```

**Wrapping Third-Party JS Libraries**

To interact with specific Javascript Objects from external libraries, map an extension type wrapping `JSObject`. 

```dart
// Suppose there is a JS library available via `window.Analytics`
extension type Analytics._(JSObject _) implements JSObject {
  external void trackPage(JSString pageName);
  external JSNumber getVisitCount();
}

@JS('Analytics')
external Analytics get analytics;

void logCurrentPage() {
  if (kIsWeb) {
    analytics.trackPage('Home'.toJS);
    
    // Convert Javascript primitives back to Dart types using `.toDart`
    int visits = analytics.getVisitCount().toDartInt;
    print('Total visits: $visits');
  }
}
```

**Anonymous JS Objects**

If you need to pass a configuration object (a plain JS object literal `{}`) into a JS function, or receive one from JavaScript, define an `@anonymous` extension type.

```dart
@JS()
@anonymous
extension type ChartConfig._(JSObject _) implements JSObject {
  external factory ChartConfig({
    JSString title,
    JSBoolean showLegend,
    JSArray<JSNumber> data,
  });

  external JSString get title;
  external JSArray<JSNumber> get data;
}

@JS()
external void renderChart(ChartConfig config);

void setupChart() {
  if (kIsWeb) {
    // Creating an anonymous JS object to pass into a JS function
    final config = ChartConfig(
      title: 'Monthly Sales'.toJS,
      showLegend: true.toJS,
      data: [10.toJS, 20.toJS, 30.toJS].toJS,
    );
    
    renderChart(config);

    // Reading properties from a JS object back to Dart types
    String title = config.title.toDart;
    List<double> rawData = config.data.toDart.map((e) => e.toDartDouble).toList();
  }
}
```
