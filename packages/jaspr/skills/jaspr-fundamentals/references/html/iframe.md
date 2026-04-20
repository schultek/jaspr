# iframe

Signature of the iframe component:

```dart
const iframe(List<Component> children, {
  required String src,
  String? allow,
  String? csp,
  MediaLoading? loading, // One of `.eager`, `.lazy`
  String? name,
  String? sandbox,
  ReferrerPolicy? referrerPolicy, // One of `.noReferrer`, `.noReferrerWhenDowngrade`, `.origin`, `.originWhenCrossOrigin`, `.sameOrigin`, `.strictOrigin`, `.strictOriginWhenCrossOrigin`, `.unsafeUrl`
  int? width,
  int? height,
  String? id,
  String? classes,
  Styles? styles,
  Map<String, String>? attributes,
  Map<String, EventCallback>? events,
  Key? key,
})
```

Example usage:

```dart
iframe(src: '...', [
  // ...
])
```