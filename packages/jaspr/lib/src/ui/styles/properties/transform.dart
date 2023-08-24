import 'angle.dart';
import 'unit.dart';

class Transform {
  const Transform._(this.value);

  final String value;

  static const Transform none = Transform._('none');

  const factory Transform.combine(List<Transform> transforms) = _CombineTransform;

  const factory Transform.rotate(Angle angle) = _RotateTransform;
  const factory Transform.rotateAxis({Angle? x, Angle? y, Angle? z}) = _RotateAxisTransform;

  const factory Transform.translate({Unit? x, Unit? y}) = _TranslateTransform;

  const factory Transform.scale(double value) = _ScaleTransform;

  const factory Transform.skew({Angle? x, Angle? y}) = _SkewTransform;

  const factory Transform.matrix(double a, double b, double c, double d, double tx, double ty) = _MatrixTransform;

  const factory Transform.perspective(Unit value) = _PerspectiveTransform;

  static const Transform inherit = Transform._('inherit');
  static const Transform initial = Transform._('initial');
  static const Transform revert = Transform._('revert');
  static const Transform revertLayer = Transform._('revert-layer');
  static const Transform unset = Transform._('unset');
}

class _CombineTransform implements Transform {
  const _CombineTransform(this.transforms);

  final List<Transform> transforms;

  @override
  String get value => transforms.map((t) => t.value).join(' ');
}

class _RotateTransform implements Transform {
  const _RotateTransform(this.angle);

  final Angle angle;

  @override
  String get value => 'rotate(${angle.value})';
}

class _RotateAxisTransform implements Transform {
  const _RotateAxisTransform({this.x, this.y, this.z});

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

class _TranslateTransform implements Transform {
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

class _ScaleTransform implements Transform {
  const _ScaleTransform(this.scale);

  final double scale;

  @override
  String get value => 'scale(${scale.numstr})';
}

class _SkewTransform implements Transform {
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

class _MatrixTransform implements Transform {
  const _MatrixTransform(this.a, this.b, this.c, this.d, this.tx, this.ty);

  final double a;
  final double b;
  final double c;
  final double d;
  final double tx;
  final double ty;

  @override
  String get value => 'matrix(${a.numstr}, ${b.numstr}, ${c.numstr}, '
      '${d.numstr}, ${tx.numstr}, ${ty.numstr})';
}

class _PerspectiveTransform implements Transform {
  const _PerspectiveTransform(this.perspective);

  final Unit perspective;

  @override
  String get value => 'perspective(${perspective.value})';
}
