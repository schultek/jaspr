# object

Signature of the object component:

```dart
const object(List<Component> children, {
  String? data,
  String? name,
  String? type,
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
object(data: '...', [
  // ...
])
```