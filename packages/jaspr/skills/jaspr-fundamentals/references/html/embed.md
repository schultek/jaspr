# embed

Signature of the embed component:

```dart
const embed({
  /// The URL of the resource being embedded.
  required String src,
  /// The MIME type to use to select the plug-in to instantiate.
  String? type,
  /// The displayed width of the resource, in CSS pixels.
  int? width,
  /// The displayed height of the resource, in CSS pixels.
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
embed(src: '...')
```