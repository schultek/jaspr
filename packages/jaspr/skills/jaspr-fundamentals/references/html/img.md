# img

Signature of the img component:

```dart
const img({
  /// Defines an alternative text description of the image
  String? alt,
  /// Indicates if the fetching of the image must be done using a CORS request.
  CrossOrigin? crossOrigin, // One of `.anonymous`, `.useCredentials`
  /// The intrinsic width of the image in pixels.
  int? width,
  /// The intrinsic height of the image, in pixels.
  int? height,
  /// Indicates how the browser should load the image.
  MediaLoading? loading, // One of `.eager`, `.lazy`
  /// The image URL.
  required String src,
  /// Indicates which referrer to send when fetching the resource.
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