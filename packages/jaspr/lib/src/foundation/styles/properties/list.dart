enum ListStyle {
  circle('circle'),
  disc('disc'),
  square('square'),
  decimal('decimal'),
  none('none'),

  lowerAlpha('lower-alpha'),
  upperAlpha('upper-alpha'),
  lowerGreek('lower-greek'),
  upperGreek('upper-greek'),
  lowerLatin('lower-latin'),
  upperLatin('upper-latin'),
  lowerRoman('lower-roman'),
  upperRoman('upper-roman'),

  inherit('inherit'),
  initial('initial');

  final String value;
  const ListStyle(this.value);
}

enum ListStylePosition {
  inside('inside'),
  outside('outside');

  final String value;
  const ListStylePosition(this.value);
}
