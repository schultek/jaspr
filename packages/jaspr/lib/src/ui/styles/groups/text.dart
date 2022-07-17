part of style;

class _TextStyles implements Styles {
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

  const _TextStyles({
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
        if (fontStyle != null) 'font-style': fontStyle!.value,
        if (fontSize != null) 'font-size': fontSize!.value,
        if (fontWeight != null) 'font-weight': fontWeight!.value,
        if (align != null) 'text-align': align!.value,
        if (decoration != null) 'text-decoration': decoration!.value,
        if (transform != null) 'text-transform': transform!.value,
        if (indent != null) 'text-indent': indent!.value,
        if (letterSpacing != null) 'letter-spacing': letterSpacing!.value,
        if (wordSpacing != null) 'word-spacing': wordSpacing!.value,
        if (lineHeight != null) 'line-height': lineHeight!.value,
      };
}
