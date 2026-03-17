# input

Signature of the input component:

```dart
const input({
  /// Defines how an <input> works. If this attribute is not specified, the default type adopted is text.
  InputType? type, // One of `.button`, `.checkbox`, `.color`, `.date`, `.dateTimeLocal`, `.email`, `.file`, `.hidden`, `.image`, `.month`, `.number`, `.password`, `.radio`, `.range`, `.reset`, `.search`, `.submit`, `.tel`, `.text`, `.time`, `.url`, `.week`
  /// Name of the form control. Submitted with the form as part of a name/value pair.
  String? name,
  /// The value of the control.
  String? value,
  /// Indicates that the user should not be able to interact with the input. Disabled inputs are typically rendered with a dimmer color or using some other form of indication that the field is not available for use.
  bool disabled = false,
  /// Specifies whether the form control is checked or not. Applies only to checkbox and radio inputs.
  bool? checked,
  /// Specifies whether the checkbox control is indeterminate or not. Applies only to checkbox inputs.
  bool? indeterminate,
  /// Callback for the 'input' event. The type of [value] depends on [type].
  ValueChanged<T>? onInput,
  /// Callback for the 'change' event. The type of [value] depends on [type].
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