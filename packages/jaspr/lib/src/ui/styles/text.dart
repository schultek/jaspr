import 'package:jaspr/ui.dart';

class TextStyle extends MultipleStyle {
  final Color? color;
  final Alignment? align;
  final FontFamily? fontFamily;
  final FontStyle? fontStyle;
  final Unit? fontSize;
  final FontWeight? fontWeight;
  final TextDecoration? decoration;
  final TextTransformation? transformation;
  final Unit? indentation;
  final Unit? letterSpacing;
  final Unit? wordSpacing;
  final Unit? lineHeight;

  TextStyle({
    this.color,
    this.align,
    this.fontFamily,
    this.fontStyle,
    this.fontSize,
    this.fontWeight,
    this.decoration,
    this.transformation,
    this.indentation,
    this.letterSpacing,
    this.wordSpacing,
    this.lineHeight,
  }) : super();


  @override
  List<Style> getStyles() => [
      if (color != null) Style('color', color!.value),
      if (fontFamily != null) Style('font-family', fontFamily!.value),
      if (fontStyle != null) Style('font-style', fontStyle!.name),
      if (fontSize != null) Style('font-size', fontSize!.toString()),
      if (fontWeight != null) Style('font-weight', fontWeight!.name),
      if (align != null) Style('text-align', align!.name),
      if (decoration != null) Style('text-decoration', decoration!.value),
      if (transformation != null) Style('text-transform', transformation!.name),
      if (indentation != null) Style('text-indent', indentation!.toString()),
      if (letterSpacing != null) Style('letter-spacing', letterSpacing!.toString()),
      if (wordSpacing != null) Style('word-spacing', wordSpacing!.toString()),
      if (lineHeight != null) Style('line-height', lineHeight!.toString()),
  ];
}
