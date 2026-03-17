# select

Signature of the select component:

```dart
const select(List<Component> children, {
  String? name,
  String? value,
  bool multiple = false,
  bool required = false,
  bool disabled = false,
  bool autofocus = false,
  String? autocomplete,
  int? size,
  ValueChanged<List<String>>? onInput,
  ValueChanged<List<String>>? onChange,
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
select(name: '...', [
  // ...
])
```