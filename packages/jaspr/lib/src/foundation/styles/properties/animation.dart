import 'transition.dart' show Curve;
import 'unit.dart';

class Animation {
  const Animation._(this.value);

  static const none = Animation._('none');

  const factory Animation({
    required double duration,
    Curve? easeFunc,
    double? delay,
    double? iterCount,
    AnimationDirection? direction,
    AnimationFillMode? fillMode,
    AnimationPlayState? playState,
    String? keyframe,
  }) = _Animation;
  const factory Animation.list(List<Animation> animations) = _AnimationList;

  /// The css value
  final String value;
}

class _Animation implements Animation {
  const _Animation({
    required this.duration,
    this.easeFunc,
    this.delay,
    this.iterCount,
    this.direction,
    this.fillMode,
    this.playState,
    this.keyframe,
  });

  /// Duration in milliseconds.
  final double duration;
  final Curve? easeFunc;

  /// Delay in milliseconds.
  final double? delay;
  final double? iterCount;
  final AnimationDirection? direction;
  final AnimationFillMode? fillMode;
  final AnimationPlayState? playState;
  final String? keyframe;

  @override
  String get value {
    var val = '${duration.numstr}ms';
    if (easeFunc != null) val += ' ${easeFunc!.value}';
    if (delay != null) val += ' ${delay!.numstr}ms';
    if (iterCount != null) val += ' ${iterCount!.numstr}';
    if (direction != null) val += ' ${direction!.value}';
    if (fillMode != null) val += ' ${fillMode!.value}';
    if (playState != null) val += ' ${playState!.value}';
    if (keyframe != null) val += ' $keyframe';

    return val;
  }
}

class _AnimationList implements Animation {
  const _AnimationList(this.animations);

  final List<Animation> animations;

  bool _validateAnimations() {
    if (animations.isEmpty) {
      throw 'Cannot have empty Animation.list. For no animation, use Animation.none instead';
    }
    return true;
  }

  @override
  String get value {
    assert(_validateAnimations());
    return animations.map((e) => e.value).join(', ');
  }
}

enum AnimationDirection {
  normal('normal'),
  reverse('reverse'),
  alternate('alternate'),
  alternateReverse('alternate-reverse');

  const AnimationDirection(this.value);
  final String value;
}

enum AnimationFillMode {
  none('none'),
  forwards('forwards'),
  backwards('backwards'),
  both('both');

  const AnimationFillMode(this.value);
  final String value;
}

enum AnimationPlayState {
  running('running'),
  paused('paused');

  const AnimationPlayState(this.value);
  final String value;
}
