library enums;

enum StyleType {
  color ('color'),
  backgroundColor('background-color'),
  ;
  final String value;
  const StyleType(this.value);
}

enum Repeat {
  none("no-repeat"),
  x("repeat-x"),
  y("repeat-y"),
  fill("repeat");

  final String value;
  const Repeat(this.value);
}

enum Position {
  topLeft("left top"), top("top"), topRight("right top"),
  left("left"), center("center"), right("right"),
  bottomLeft("left bottom"), bottom("bottom"), bottomRight("right bottom");

  final String value;
  const Position(this.value);
}

enum Clip {
  border("border-box"),
  padding("padding-box"),
  content("content-box");

  final String value;
  const Clip(this.value);
}
