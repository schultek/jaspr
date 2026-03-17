# object

Signature of the object component:

```dart
const object(List<Component> children, {
  /// The address of the resource as a valid URL. At least one of data and type must be defined.
  String? data,
  /// The name of valid browsing context (HTML5).
  String? name,
  /// The content type of the resource specified by data. At least one of data and type must be defined.
  String? type,
  /// The width of the displayed resource in CSS pixels.
  int? width,
  /// The height of the displayed resource in CSS pixels.
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
object(data: '...', [
  // ...
])
```