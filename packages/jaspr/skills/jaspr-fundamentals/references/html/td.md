# td

Signature of the td component:

```dart
const td(List<Component> children, {
  int? colspan,
  String? headers,
  int? rowspan,
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
td(colspan: 1, [
  // ...
])
```