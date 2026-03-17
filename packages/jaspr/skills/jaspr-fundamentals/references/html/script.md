# script

Signature of the script component:

```dart
const script({
  String? src,
  bool async = false,
  bool defer = false,
  String? content,
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
script(src: '...')
```