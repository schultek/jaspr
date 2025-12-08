import 'angle.dart';
import 'unit.dart';

/// Represents the CSS `transform` property.
///
/// CSS transforms let you rotate, scale, skew, or translate an element. It modifies the
/// coordinate space of the CSS visual formatting model.
///
/// Use the various factory constructors to create different types of transforms. You can
/// apply multiple transforms to an element by combining them using [Transform.combine].
///
/// Read more: [MDN `transform`](https://developer.mozilla.org/en-US/docs/Web/CSS/transform)
class Transform {
  const Transform._(this.value);

  /// The css value
  final String value;

  /// No transform is applied.
  static const Transform none = Transform._('none');

  /// Combine multiple transforms into one.
  const factory Transform.combine(List<Transform> transforms) = _CombineTransform;

  /// Rotates an element around a fixed point on the 2D plane.
  const factory Transform.rotate(Angle angle) = _RotateTransform;

  /// Rotates an element around the individual axes in 3D space.
  const factory Transform.rotateAxis({Angle? x, Angle? y, Angle? z}) = _RotateAxisTransform;

  /// Translates an element on the 2D plane.
  const factory Transform.translate({Unit? x, Unit? y}) = _TranslateTransform;

  /// Scales an element up or down on the 2D plane.
  const factory Transform.scale(double value) = _ScaleTransform;

  /// Skews an element on the 2D plane.
  const factory Transform.skew({Angle? x, Angle? y}) = _SkewTransform;

  /// Describes a homogeneous 2D transformation matrix.
  const factory Transform.matrix(double a, double b, double c, double d, double tx, double ty) = _MatrixTransform;

  /// Sets the distance between the user and the z=0 plane.
  const factory Transform.perspective(Unit value) = _PerspectiveTransform;

  static const Transform inherit = Transform._('inherit');
  static const Transform initial = Transform._('initial');
  static const Transform revert = Transform._('revert');
  static const Transform revertLayer = Transform._('revert-layer');
  static const Transform unset = Transform._('unset');
}

class _CombineTransform implements _ListableTransform {
  const _CombineTransform(this.transforms);

  final List<Transform> transforms;

  bool _transformsListable() {
    if (transforms.isEmpty) {
      throw '[Transform.combine] cannot be empty.';
    }

    for (final transform in transforms) {
      if (transform is! _ListableTransform) {
        throw 'Cannot use ${transform.value} as a filter list item, only standalone use supported.';
      }
    }

    return true;
  }

  @override
  String get value {
    assert(_transformsListable());
    return transforms.map((t) => t.value).join(' ');
  }
}

abstract class _ListableTransform implements Transform {}

class _RotateTransform implements _ListableTransform {
  const _RotateTransform(this.angle);

  final Angle angle;

  @override
  String get value => 'rotate(${angle.value})';
}

class _RotateAxisTransform implements _ListableTransform {
  const _RotateAxisTransform({this.x, this.y, this.z})
    : assert(x != null || y != null || z != null, 'At least one of the angles x, y or z has to be not null');

  final Angle? x;
  final Angle? y;
  final Angle? z;

  @override
  String get value => [
    if (x != null) 'rotateX(${x!.value})',
    if (y != null) 'rotateY(${y!.value})',
    if (z != null) 'rotateZ(${z!.value})',
  ].join(' ');
}

class _TranslateTransform implements _ListableTransform {
  const _TranslateTransform({this.x, this.y});

  final Unit? x;
  final Unit? y;

  @override
  String get value {
    if (x != null && y != null) {
      return 'translate(${x!.value}, ${y!.value})';
    } else if (x != null) {
      return 'translateX(${x!.value})';
    } else if (y != null) {
      return 'translateY(${y!.value})';
    }
    return '';
  }
}

class _ScaleTransform implements _ListableTransform {
  const _ScaleTransform(this.scale);

  final double scale;

  @override
  String get value => 'scale(${scale.numstr})';
}

class _SkewTransform implements _ListableTransform {
  const _SkewTransform({this.x, this.y});

  final Angle? x;
  final Angle? y;

  @override
  String get value {
    if (x != null && y != null) {
      return 'skew(${x!.value}, ${y!.value})';
    } else if (x != null) {
      return 'skewX(${x!.value})';
    } else if (y != null) {
      return 'skewY(${y!.value})';
    }
    return '';
  }
}

class _MatrixTransform implements _ListableTransform {
  const _MatrixTransform(this.a, this.b, this.c, this.d, this.tx, this.ty);

  final double a;
  final double b;
  final double c;
  final double d;
  final double tx;
  final double ty;

  @override
  String get value =>
      'matrix(${a.numstr}, ${b.numstr}, ${c.numstr}, '
      '${d.numstr}, ${tx.numstr}, ${ty.numstr})';
}

class _PerspectiveTransform implements _ListableTransform {
  const _PerspectiveTransform(this.perspective);

  final Unit perspective;

  @override
  String get value => 'perspective(${perspective.value})';
}
