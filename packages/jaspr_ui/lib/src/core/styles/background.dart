import 'package:jaspr_ui/core.dart';

class BackgroundStyle extends MultipleStyle {
  final Color? color;

  const BackgroundStyle({this.color}) : super();

  @override
  List<Style> getStyles() => [
    if (color != null) Style('background-color', color!.value),
  ];
}
