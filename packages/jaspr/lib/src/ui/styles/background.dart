import 'package:jaspr/ui.dart';

class BackgroundStyle extends MultipleStyle {
  final Color? color;
  final String? imageUrl;
  final Repeat? repeat;
  final Position? position;
  final bool? fixed;
  final Clip? clip;

  BackgroundStyle({
    this.color,
    this.imageUrl,
    this.repeat,
    this.position,
    this.fixed,
    this.clip,
  }) : super();


  @override
  List<Style> getStyles() => [
      if (color != null) Style('background-color', color!.value),
      if (imageUrl != null) Style('background-image', 'url("${imageUrl!}")'),
      if (repeat != null) Style('background-repeat', repeat!.value),
      if (position != null) Style('background-position', position!.position.getStyle()),
      if (fixed == true) Style('background-attachment', "fixed"),
      if (clip != null) Style('background-clip', clip!.value),
  ];
}
