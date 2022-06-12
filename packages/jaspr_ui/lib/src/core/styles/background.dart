import 'package:jaspr_ui/core.dart';

class BackgroundStyle implements Style {
  final Color? color;

  const BackgroundStyle({this.color});

  InlineStyle get inlineStyle {
    return InlineStyle(styles: [
      if (color != null) DomStyle('background-color', color!.value),
    ]);
  }

  @override
  String getStyle() => inlineStyle.getStyles();

  @override
  Map<String, String> asMap() {
    return {'background-color': color!.value};
  }
}
