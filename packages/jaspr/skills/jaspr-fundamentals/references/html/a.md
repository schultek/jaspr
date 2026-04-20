# a

Signature of the a component:

```dart
const a(List<Component> children, {
  required String href,
  Target? target, // One of `.self`, `.blank`, `.parent`, `.top`
  String? type,
  String? download,
  ReferrerPolicy? referrerPolicy, // One of `.noReferrer`, `.noReferrerWhenDowngrade`, `.origin`, `.originWhenCrossOrigin`, `.sameOrigin`, `.strictOrigin`, `.strictOriginWhenCrossOrigin`, `.unsafeUrl`
  VoidCallback? onClick,
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
a(href: '...', [
  // ...
])
```