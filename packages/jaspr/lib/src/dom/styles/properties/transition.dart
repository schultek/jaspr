import 'unit.dart' show NumberString;

/// Represents the CSS `transition` property.
///
/// Transitions enable you to define the transition between two states of an element. Different
/// states may be defined using pseudo-classes like `:hover` or `:active` or dynamically set.
///
/// Read more: [MDN `transition`](https://developer.mozilla.org/en-US/docs/Web/CSS/transition)
class Transition {
  const Transition._(this.value);

  static const inherit = Transition._('inherit');
  static const initial = Transition._('initial');
  static const revert = Transition._('revert');
  static const revertLayer = Transition._('revert-layer');
  static const unset = Transition._('unset');

  /// Create a transition for a specific CSS property.
  const factory Transition(String property, {required Duration duration, Curve? curve, Duration? delay}) = _Transition;

  /// Combine multiple transitions into one.
  const factory Transition.combine(List<Transition> transitions) = _CombineTransition;

  /// The css value
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

/// Describes the timing function of a transition.
///
/// This defines an acceleration curve so that the speed of the transition can vary over its duration.
///
/// Read more: [MDN `transition-timing-function`](https://developer.mozilla.org/en-US/docs/Web/CSS/transition-timing-function)
class Curve {
  const Curve._(this.value);

  /// The css value
  final String value;

  /// Equal to `cubic-bezier(0.25, 0.1, 0.25, 1.0)`, the default value, increases in velocity towards the
  /// middle of the transition, slowing back down at the end.
  static const Curve ease = Curve._('ease');

  /// Equal to `cubic-bezier(0.42, 0, 1.0, 1.0)`, starts off slowly, with the transition speed increasing
  /// until complete.
  static const Curve easeIn = Curve._('ease-in');

  /// Equal to `cubic-bezier(0, 0, 0.58, 1.0)`, starts transitioning quickly, slowing down as the transition
  /// continues.
  static const Curve easeOut = Curve._('ease-out');

  /// Equal to `cubic-bezier(0.42, 0, 0.58, 1.0)`, starts transitioning slowly, speeds up, and then slows down
  /// again.
  static const Curve easeInOut = Curve._('ease-in-out');

  /// Equal to `cubic-bezier(0.0, 0.0, 1.0, 1.0)`, transitions at an even speed.
  static const Curve linear = Curve._('linear');

  /// Equal to `steps(1, jump-start)`.
  static const Curve stepStart = Curve._('step-start');

  /// Equal to `steps(1, jump-end)`.
  static const Curve stepEnd = Curve._('step-end');

  const factory Curve.linearFn(List<Linear> vals) = _LinearFnCurve;

  /// An custom cubic-Bezier curve, where the p1 and p3 values must be in the range of 0 to 1.
  const factory Curve.cubicBezier(double p1, double p2, double p3, double p4) = _CubicBezierCurve;

  /// Displays the transition along [steps] stops along the transition, displaying each stop for equal lengths
  /// of time. How the transition behaves at the start and end is defined by [jump].
  const factory Curve.steps(int steps, {required StepJump jump}) = _StepsCurve;
}

class _LinearFnCurve implements Curve {
  const _LinearFnCurve(this.vals);

  final List<Linear> vals;

  bool _validateLinears() {
    if (vals.isEmpty) {
      throw 'Curve.linear cannot be empty';
    }
    return true;
  }

  @override
  String get value {
    assert(_validateLinears());
    return "linear(${vals.map((e) => e.value).join(', ')})";
  }
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

  String get value => "${n.numstr}${p1 != null ? ' ${p1!.numstr}%' : ''}${p2 != null ? ' ${p2!.numstr}%' : ''}";
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

/// Describes how the transition behaves at the start and end when using [Curve.steps].
enum StepJump {
  /// Denotes a left-continuous function, so that the first jump happens when the transition begins.
  start('jump-start'),

  /// Denotes a right-continuous function, so that the last jump happens when the animation ends.
  end('jump-end'),

  /// There is no jump on either end. Instead, holding at both the 0% mark and the 100% mark, each for 1/n of the duration.
  none('jump-none'),

  /// Includes pauses at both the 0% and 100% marks, effectively adding a step during the transition time.
  both('jump-both');

  /// The css value
  final String value;
  const StepJump(this.value);
}
