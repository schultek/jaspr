# input

Signature of the input component:

```dart
const input<T>({
  InputType? type, // One of `.text`, `.button`, `.checkbox`, `.color`, `.date`, `.dateTimeLocal`, `.email`, `.file`, `.hidden`, `.image`, `.month`, `.number`, `.password`, `.radio`, `.range`, `.reset`, `.search`, `.submit`, `.tel`, `.time`, `.url`, `.week`
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

`T` defines the value type for the input element and must align with the 'type' attribute:
- `bool` for checkbox and radio
- `num` for number and range
- `DateTime` (UTC) for date, time, week, month and datetime-local
- `List<File>` for file
- `Color` for color
- `String` for all other types

Example usage:

```dart
input<String>(type: .text)
```