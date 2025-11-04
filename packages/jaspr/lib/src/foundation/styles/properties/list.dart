/// The `list-style-type` CSS property sets the marker (such as a disc, character, or custom counter style) of a list
/// item element.
///
/// Read more: [MDN `list-style-type`](https://developer.mozilla.org/en-US/docs/Web/CSS/list-style-type)
enum ListStyle {
  /// A filled circle (default value).
  disc('disc'),

  /// A hollow circle.
  circle('circle'),

  /// A filled square.
  square('square'),

  /// Decimal numbers, beginning with 1.
  decimal('decimal'),

  /// No item marker is shown.
  none('none'),

  /// Lowercase ASCII letters.
  lowerAlpha('lower-alpha'),

  /// Uppercase ASCII letters.
  upperAlpha('upper-alpha'),

  /// Lowercase classical Greek.
  lowerGreek('lower-greek'),

  /// Uppercase classical Greek.
  upperGreek('upper-greek'),

  /// Lowercase ASCII letters.
  lowerLatin('lower-latin'),

  /// Uppercase ASCII letters.
  upperLatin('upper-latin'),

  /// Lowercase roman numerals.
  lowerRoman('lower-roman'),

  /// Uppercase roman numerals.
  upperRoman('upper-roman'),

  // TODO: Support more list styles like 'armenian', 'georgian', 'hebrew', and add custom string option.

  inherit('inherit'),
  initial('initial');

  final String value;
  const ListStyle(this.value);
}

/// The `list-style-position` CSS property sets the position of the `::marker` relative to a list item.
///
/// Read more: [MDN `list-style-position`](https://developer.mozilla.org/en-US/docs/Web/CSS/list-style-position)
enum ListStylePosition {
  /// The `::marker` is the first element among the list item's contents.
  inside('inside'),

  /// The `::marker` is outside the principal block box. This is the default value for list-style.
  outside('outside');

  final String value;
  const ListStylePosition(this.value);
}
