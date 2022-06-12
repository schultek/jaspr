abstract class Style {
  const Style();

  String getStyle();

  Map<String, String> asMap();
}

class DomStyle implements Style {
  final String? type;
  final String? value;

  const DomStyle([this.type, this.value])
      : assert(type != null),
        assert(value != null);

  @override
  String getStyle() => '$type: $value;';

  @override
  Map<String, String> asMap() => {type!: value!};
}
