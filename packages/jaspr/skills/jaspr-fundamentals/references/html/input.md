# input

Signature of the input component:

```dart
const input({
  InputType? type, // One of `.button`, `.checkbox`, `.color`, `.date`, `.dateTimeLocal`, `.email`, `.file`, `.hidden`, `.image`, `.month`, `.number`, `.password`, `.radio`, `.range`, `.reset`, `.search`, `.submit`, `.tel`, `.text`, `.time`, `.url`, `.week`
  String? name,
  String? value,
  bool disabled = false,
  bool? checked,
  bool? indeterminate,
  ValueChanged<T>? onInput,
  ValueChanged<T>? onChange,
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
input(type: .button)
```