class ListMarkerType {
  const ListMarkerType._(this.value);

  final String value;

  factory ListMarkerType.keyword(String keyword) => ListMarkerType._(keyword);
  factory ListMarkerType.value(String value) => ListMarkerType._('"$value"');

  static const ListMarkerType none = ListMarkerType._('none');
  static const ListMarkerType disc = ListMarkerType._('disc');
  static const ListMarkerType circle = ListMarkerType._('circle');
  static const ListMarkerType square = ListMarkerType._('square');
  static const ListMarkerType decimal = ListMarkerType._('decimal');
  static const ListMarkerType roman = ListMarkerType._('upper-roman');
  static const ListMarkerType upperAlpha = ListMarkerType._('upper-alpha');
  static const ListMarkerType lowerAlpha = ListMarkerType._('lower-alpha');

  Map<String, String> get styles => {'list-style-type': value};
}

class ListMarkerPosition {
  const ListMarkerPosition._(this.value);

  final String value;

  static const ListMarkerPosition inside = ListMarkerPosition._('inside');
  static const ListMarkerPosition outside = ListMarkerPosition._('outside');

  Map<String, String> get styles => {'list-style-position': value};
}

class ListMarkerImage {
  const ListMarkerImage._(this.value);

  final String value;

  factory ListMarkerImage.url(String url) => ListMarkerImage._('url("$url")');

  static const ListMarkerImage none = ListMarkerImage._('none');

  Map<String, String> get styles => {'list-style-image': value};
}
