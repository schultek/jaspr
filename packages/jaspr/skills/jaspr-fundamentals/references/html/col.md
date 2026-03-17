# col

Signature of the col component:

```dart
const col({
  /// Specifies the number of consecutive columns the <col> element spans. The value must be a positive integer greater than zero. If not present, its default value is 1.
  int? span,
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
col(span: 1)
```