library enums;

enum StyleType {
  color('color'),
  backgroundColor('background-color'),
  ;

  final String value;
  const StyleType(this.value);
}

enum LinkSelector {
  unvisited("a:link"),
  visited("a:visited"),
  hover("a:hover"),
  active("a:active"),
  ;

  final String value;
  const LinkSelector(this.value);
}

enum BorderStyle { none, solid, hidden, dashed, dotted, double, inset, outset, groove, ridge }

enum Overflow { visible, hidden, scroll, auto }

enum Visibility { visible, hidden, collapse, inherit }

enum Display {
  none("none"),
  block("block"),
  inline("inline"),
  inlineBlock("inline-block"),
  ;

  final String value;
  const Display(this.value);
}
