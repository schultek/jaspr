# textarea

Signature of the textarea component:

```dart
const textarea(List<Component> children, {
  AutoComplete? autoComplete, // One of `.off`, `.on`
  bool autofocus = false,
  int? cols,
  bool disabled = false,
  int? minLength,
  String? name,
  String? placeholder,
  bool readonly = false,
  bool required = false,
  int? rows,
  SpellCheck? spellCheck, // One of `.isTrue`, `.isDefault`, `.isFalse`
  TextWrap? wrap, // One of `.hard`, `.soft`
  ValueChanged<String>? onInput,
  ValueChanged<String>? onChange,
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
textarea(autoComplete: .off, [
  // ...
])
```