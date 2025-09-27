class Transition {
  const Transition._(this.value);

  static const inherit = Transition._('inherit');
  static const initial = Transition._('initial');
  static const revert = Transition._('revert');
  static const revertLayer = Transition._('revert-layer');
  static const unset = Transition._('unset');

  const factory Transition(String property, {required Duration duration, Curve? curve, Duration? delay}) = _Transition;
  const factory Transition.combine(List<Transition> transitions) = _CombineTransition;

  final String value;
}

abstract class _ListableTransition implements Transition {}

class _Transition implements _ListableTransition {
  const _Transition(this.property, {required this.duration, this.curve, this.delay});

  final String property;
  final Duration duration;
  final Curve? curve;
  final Duration? delay;

  @override
  String get value => [
    property,
    '${duration.inMilliseconds}ms',
    if (curve != null) curve!.value,
    if (delay != null) '${delay!.inMilliseconds}ms',
  ].join(' ');
}

class _CombineTransition implements _ListableTransition {
  const _CombineTransition(this.transitions);

  final List<Transition> transitions;

  bool _transitionsListable() {
    if (transitions.isEmpty) {
      throw 'Transition.combine cannot be empty.';
    }

    for (final transition in transitions) {
      if (transition is! _ListableTransition) {
        throw 'Cannot use ${transition.value} as a transition list item, only standalone use supported.';
      }
    }

    return true;
  }

  @override
  String get value {
    assert(_transitionsListable());
    return transitions.map((t) => t.value).join(', ');
  }
}

class Curve {
  const Curve._(this.value);

  final String value;

  static const Curve ease = Curve._('ease');
  static const Curve easeIn = Curve._('ease-in');
  static const Curve easeOut = Curve._('ease-out');
  static const Curve easeInOut = Curve._('ease-in-out');
  static const Curve linear_ = Curve._('linear');
  static const Curve stepStart = Curve._('step-start');
  static const Curve stepEnd = Curve._('step-end');

  const factory Curve.linear(List<Linear> vals) = _LinearCurve;
  const factory Curve.cubicBezier(double p1, double p2, double p3, double p4) = _CubicBezierCurve;
  const factory Curve.steps(int steps, {required StepJump jump}) = _StepsCurve;
}

class _LinearCurve implements Curve {
  const _LinearCurve(this.vals);

  final List<Linear> vals;

  @override
  String get value => vals.join(', ');
}

/// Tuple used with [Curve.linear]. The optional arguments are percentages between 0-100.
///
/// e.g.,
/// ```dart
/// Linear(0.2); // Becomes "0.2"
/// Linear(0.2, 10); // Becomes "0.2 10%"
/// Linear(0.2, 10, 5.5); // Becomes "0.2 10% 5.5%"
/// ```
class Linear {
  const Linear(this.n, [this.p1, this.p2]);

  final double n;
  final double? p1, p2;

  String get value => "$n${p1 != null ? ' $p1%' : ''}${p2 != null ? ' $p2%' : ''}";
}

class _CubicBezierCurve implements Curve {
  const _CubicBezierCurve(this.p1, this.p2, this.p3, this.p4);

  final double p1;
  final double p2;
  final double p3;
  final double p4;

  @override
  String get value => 'cubic-bezier($p1, $p2, $p3, $p4)';
}

class _StepsCurve implements Curve {
  const _StepsCurve(this.steps, {required this.jump});

  final int steps;
  final StepJump jump;

  @override
  String get value => 'steps($steps, ${jump.value})';
}

enum StepJump {
  start('jump-start'),
  end('jump-end'),
  none('jump-none'),
  both('jump-both');

  /// The css value
  final String value;
  const StepJump(this.value);
}
