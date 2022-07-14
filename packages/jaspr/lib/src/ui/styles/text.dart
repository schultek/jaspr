part of style;

class _TextStyle implements Style {
  final Color? color;
  final TextAlign? align;
  final FontFamily? fontFamily;
  final FontStyle? fontStyle;
  final Unit? fontSize;
  final FontWeight? fontWeight;
  final TextDecoration? decoration;
  final TextTransform? transform;
  final Unit? indent;
  final Unit? letterSpacing;
  final Unit? wordSpacing;
  final Unit? lineHeight;

  const _TextStyle({
    this.color,
    this.align,
    this.fontFamily,
    this.fontStyle,
    this.fontSize,
    this.fontWeight,
    this.decoration,
    this.transform,
    this.indent,
    this.letterSpacing,
    this.wordSpacing,
    this.lineHeight,
  });

  @override
  Map<String, String> get styles => {
        if (color != null) 'color': color!.value,
        if (fontFamily != null) 'font-family': fontFamily!.value,
        if (fontStyle != null) 'font-style': fontStyle!.name,
        if (fontSize != null) 'font-size': fontSize!.toString(),
        if (fontWeight != null) 'font-weight': fontWeight!.name,
        if (align != null) 'text-align': align!.name,
        if (decoration != null) 'text-decoration': decoration!.value,
        if (transform != null) 'text-transform': transform!.name,
        if (indent != null) 'text-indent': indent!.toString(),
        if (letterSpacing != null) 'letter-spacing': letterSpacing!.toString(),
        if (wordSpacing != null) 'word-spacing': wordSpacing!.toString(),
        if (lineHeight != null) 'line-height': lineHeight!.toString(),
      };
}
