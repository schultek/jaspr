import 'enums.dart';

class EdgeInsets {
  final Space? left;
  final Space? top;
  final Space? right;
  final Space? bottom;
  final Space? horizontal;
  final Space? vertical;

  EdgeInsets({this.left, this.top, this.right, this.bottom, this.horizontal, this.vertical});

  const EdgeInsets.fromLTRB(this.left, this.top, this.right, this.bottom)
      : horizontal = null,
        vertical = null;

  const EdgeInsets.all(Space value)
      : left = null,
        top = null,
        right = null,
        bottom = null,
        horizontal = value,
        vertical = value;

  const EdgeInsets.only({this.left, this.top, this.right, this.bottom})
      : horizontal = null,
        vertical = null;

  const EdgeInsets.symmetric({
    this.vertical,
    this.horizontal,
  })  : left = null,
        top = null,
        right = null,
        bottom = null;

  static const EdgeInsets zero = EdgeInsets.only();

  Iterable<String> getClasses(String type) {
    if (horizontal == null && vertical == null) {
      return [
        if (left != null) '${type}s-${left!.value}',
        if (top != null) '${type}t-${top!.value}',
        if (right != null) '${type}e-${right!.value}',
        if (bottom != null) '${type}b-${bottom!.value}',
      ];
    } else {
      return [
        if (horizontal != null) '${type}x-${horizontal!.value}',
        if (vertical != null) '${type}y-${vertical!.value}',
      ];
    }
  }

  EdgeInsets copyWith({
    Space? left,
    Space? top,
    Space? right,
    Space? bottom,
    Space? horizontal,
    Space? vertical,
  }) {
    return EdgeInsets(
      left: left ?? this.left,
      top: top ?? this.top,
      right: right ?? this.right,
      bottom: bottom ?? this.bottom,
      horizontal: horizontal ?? this.horizontal,
      vertical: vertical ?? this.vertical,
    );
  }
}
