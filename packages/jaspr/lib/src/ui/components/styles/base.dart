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
  final Iterable<BaseStyle>? _styles;
  String? _value;

  MultipleStyle({Iterable<BaseStyle>? styles}) : _styles = styles;

  Iterable<BaseStyle> getStyles() => _styles ?? [];

  @override
  String getStyle() => _value ?? getStyles().map((e) => e.getStyle()).join(' ');

  @override
  Map<String, String> asMap() => {for (var style in getStyles()) ...style.asMap()};

  factory MultipleStyle.fromMap(Map<String, String> map) {
    return MultipleStyle(styles: map.entries.map((e) => Style(e.key, e.value)));
  }

  factory MultipleStyle.fromString(String value) {
    return MultipleStyle().._value = value;
  }
}
