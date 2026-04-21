# Jaspr Typography & Text

When configuring text appearance using `Styles()`/`.styles()`, Jaspr provides robust typography properties.

*(Note: For color properties, refer to `color.md`)*

## Fonts
- `FontFamily? fontFamily`: `.list([FontFamily('Arial'), FontFamilies.sansSerif])`
- `FontSize? fontSize`: `14.px` or `2.em`
- `FontWeight? fontWeight`: `.bold` or `.w500`
- `FontStyle? fontStyle`: `.italic` or `.normal`

## Text Alignment & Decoration
- `TextAlign? textAlign`: `.center`, `.left`, `.right` or `.justify`
- `TextDecoration? textDecoration`: `.none` or `TextDecoration(line: .underline, style: .dashed, color: Colors.black)`
- `TextTransform? textTransform`: `.uppercase`, `.lowercase`, `.capitalize` or `.none`

## Text Spacing & Properties
- `Unit? letterSpacing`: `1.px`
- `Unit? wordSpacing`: `2.px`
- `Unit? lineHeight`: `1.5.em` or `24.px`
- `Unit? textIndent`: `10.px`
- `WhiteSpace? whiteSpace`: `.normal`, `.nowrap`, `.pre`, `.preWrap`, `preLine` or `.breakSpaces`
- `TextOverflow? textOverflow`: `.ellipsis` or `.clip`
- `TextShadow? textShadow`: `TextShadow(offsetX: 2.px, offsetY: 2.px, blur: 4.px, color: Colors.black)`
- `Quotes? quotes`: `.none`, `.auto` or `Quotes(('"', '"'))`

## Example
```dart
css('h1').styles(
  fontFamily: .list([FontFamily('Roboto'), FontFamilies.sansSerif]),
  fontSize: 2.rem,
  fontWeight: .w700,
  textTransform: .uppercase,
  letterSpacing: 2.px,
  textAlign: .center,
)
```
