# img

Signature of the img component:

```dart
const img({
  String? alt,
  CrossOrigin? crossOrigin, // One of `.anonymous`, `.useCredentials`
  int? width,
  int? height,
  MediaLoading? loading, // One of `.eager`, `.lazy`
  required String src,
  ReferrerPolicy? referrerPolicy, // One of `.noReferrer`, `.noReferrerWhenDowngrade`, `.origin`, `.originWhenCrossOrigin`, `.sameOrigin`, `.strictOrigin`, `.strictOriginWhenCrossOrigin`, `.unsafeUrl`
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
img(src: '...')
```