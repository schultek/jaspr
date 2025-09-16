import 'unit.dart';

abstract class Transition {
  const factory Transition(String property, {required double duration, Curve? curve, double? delay}) = _Transition;
  const factory Transition.combine(List<Transition> transitions) = _CombineTransition;

  String get value;
}

class _Transition implements Transition {
  const _Transition(this.property, {required this.duration, this.curve, this.delay});

  final String property;
  final double duration;
  final Curve? curve;
  final double? delay;

  @override
  String get value => [
    property,
    '${duration.numstr}ms',
    if (curve != null) curve!.value,
    if (delay != null) '${delay!.numstr}ms',
  ].join(' ');
}

class _CombineTransition implements Transition {
  const _CombineTransition(this.transitions);

  final List<Transition> transitions;

  bool _transitionsListable() {
    if (transitions.isEmpty) {
      throw 'Filter.list cannot be empty.';
    }

    for (final transition in transitions) {
      if (transition is! _Transition) {
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
  static const Curve linear = Curve._('linear');
  static const Curve stepStart = Curve._('step-start');
  static const Curve stepEnd = Curve._('step-end');

  const factory Curve.cubicBezier(double p1, double p2, double p3, double p4) = _CubicBezierCurve;

  const factory Curve.steps(int steps, {required StepJump jump}) = _StepsCurve;
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
