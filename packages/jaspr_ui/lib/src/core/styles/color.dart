import 'package:jaspr_ui/core.dart';

class ColorStyle implements Style {
  final Color color;

  ColorStyle(this.color);

  @override
  getStyle() => 'color: ${color.value};';

  @override
  Map<String, String> asMap() {
    throw UnimplementedError();
  }
}
