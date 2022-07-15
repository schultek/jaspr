enum TextAlign {
  start('start'),
  end('end'),
  left('left'),
  right('right'),
  center('center'),
  justify('justify'),
  justifyAll('justify-all'),
  matchParent('match-parent'),

  inherit('inherit'),
  initial('initial'),
  revert('revert'),
  revertLayer('revert-layer'),
  unset('unset');

  final String value;
  const TextAlign(this.value);
}

// TODO allow custom values, multiple values
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
  fantasy("fantasy");

  final String value;
  const FontFamily(this.value);
}

// TODO support global values, oblique with angle
enum FontStyle { normal, italic, oblique }

// TODO support all keywords and global values
enum TextTransform { uppercase, capitalize, lowercase }

// TODO support rest of global values
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
  inherit("inherit");

  final String value;
  const FontWeight(this.value);
}

// TODO implement full shorthand spec
enum TextDecoration {
  none("none"),
  underline("underline"),
  overline("overline"),
  lineThrough("line-through");

  final String value;
  const TextDecoration(this.value);
}
