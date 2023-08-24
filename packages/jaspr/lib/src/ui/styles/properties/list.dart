enum ListStyleType {
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
  const ListStyleType(this.value);
}
