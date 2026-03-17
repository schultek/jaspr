# ol

Signature of the ol component:

```dart
const ol(List<Component> children, {
  /// This Boolean attribute specifies that the list's items are in reverse order. Items will be numbered from high to low.
  bool reversed = false,
  /// An integer to start counting from for the list items. Always an Arabic numeral (1, 2, 3, etc.), even when the numbering type is letters or Roman numerals. For example, to start numbering elements from the letter "d" or the Roman numeral "iv," use start="4".
  int? start,
  /// Sets the numbering type.
  /// The specified type is used for the entire list unless a different type attribute is used on an enclosed <li> element.
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