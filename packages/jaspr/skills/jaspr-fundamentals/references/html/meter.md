# meter

Signature of the meter component:

```dart
const meter(List<Component> children, {
  double? value,
  double? min,
  double? max,
  double? low,
  double? high,
  double? optimum,
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
meter(value: 1.0, [
  // ...
])
```