import 'package:jaspr/ui.dart';

class BackgroundStyle extends MultipleStyle {
  final Color? color;

  BackgroundStyle({this.color}) : super();

  @override
  List<Style> getStyles() => [
    if (color != null) Style('background-color', color!.value),
  ];
}
