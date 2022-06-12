abstract class BaseStyle {
  const BaseStyle();

  String getStyle();

  Map<String, String> asMap();
}

class Style implements BaseStyle {
  final String? type;
  final String? value;

  const Style([this.type, this.value])
      : assert(type != null),
        assert(value != null);

  @override
  String getStyle() => '$type: $value;';

  @override
  Map<String, String> asMap() => {type!: value!};
}

class MultipleStyle implements BaseStyle {
  final List<Style>? _styles;

  const MultipleStyle({
    Style? style,
    List<Style>? styles,
  })  : _styles = styles;

  List<Style> getStyles() => _styles ?? [];

  @override
  String getStyle() => getStyles().map((e) => e.getStyle()).join(' ');

  @override
  Map<String, String> asMap() => {for (var style in getStyles()) ...style.asMap()};
}
