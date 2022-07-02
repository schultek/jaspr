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

enum FontFamily {
  arial("Arial"),
  helvetica("Helvetica"),
  gillSans("'Gill Sans'"),
  lucida("Lucida"),
  helveticaNarrow("'Helvetica Narrow'"),
  sansSerif("sans-serif"),
  times("Times"),
  timesNewRoman("'Times New Roman'"),
  palatino("Palatino"),
  bookman("Bookman"),
  newCenturySchoolbook("'New Century Schoolbook'"),
  serif("serif"),
  andaleMono("'Andale Mono'"),
  courierNew("'Courier New'"),
  courier("Courier"),
  lucidatypewriter("Lucidatypewriter"),
  fixed("Fixed"),
  monospace("monospace"),
  comicSans("'Comic Sans'"),
  zapfChancery("'Zapf Chancery'"),
  coronetscript("Coronetscript"),
  florence("Florence"),
  parkavenue("Parkavenue"),
  cursive("cursive"),
  impact("Impact"),
  arnoldboecklin("Arnoldboecklin"),
  oldtown("Oldtown"),
  blippo("Blippo"),
  brushstroke("Brushstroke"),
  fantasy("fantasy"),
  ;

  final String value;
  const FontFamily(this.value);
}

enum Alignment { left, center, right, justify }

enum FontStyle { normal, italic, oblique }

enum TextTransformation { uppercase, capitalize, lowercase }

enum FontWeight {
  normal("normal"),
  bold("bold"),
  bolder("bolder"),
  lighter("lighter"),
  w100("100"),
  w200("200"),
  w300("300"),
  w400("400"),
  w500("500"),
  w600("600"),
  w700("700"),
  w800("800"),
  w900("900"),
  inherit("inherit"),
  ;

  final String value;
  const FontWeight(this.value);
}

enum TextDecoration {
  none("none"),
  underline("underline"),
  overline("overline"),
  lineThrough("line-through"),
  ;

  final String value;
  const TextDecoration(this.value);
}
