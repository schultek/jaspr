# ol

Signature of the ol component:

```dart
const ol(List<Component> children, {
  bool reversed = false,
  int? start,
  NumberingType? type, // One of `.lowercaseLetters`, `.uppercaseLetters`, `.lowercaseRomanNumerals`, `.uppercaseRomanNumerals`, `.numbers`
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
ol(reversed: true, [
  // ...
])
```