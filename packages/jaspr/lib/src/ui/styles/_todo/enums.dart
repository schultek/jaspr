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

enum Overflow { visible, hidden, scroll, auto }

enum Visibility { visible, hidden, collapse, inherit }
