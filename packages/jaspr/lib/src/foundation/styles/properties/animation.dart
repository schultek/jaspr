import 'transition.dart' show Curve;
import 'unit.dart';

class Animation {
  const Animation._(this.value);

  static const none = Animation._('none');

  const factory Animation({
    required String name,
    required Duration duration,
    Curve? curve,
    Duration? delay,
    double? count,
    AnimationDirection? direction,
    AnimationFillMode? fillMode,
    AnimationPlayState? playState,
  }) = _Animation;
  const factory Animation.list(List<Animation> animations) = _AnimationList;

  /// The css value
  final String value;
}

class _Animation implements Animation {
  const _Animation({
    required this.name,
    required this.duration,
    this.curve,
    this.delay,
    this.count,
    this.direction,
    this.fillMode,
    this.playState,
  });

  final String name;
  final Duration duration;
  final Curve? curve;
  final Duration? delay;
  final double? count;
  final AnimationDirection? direction;
  final AnimationFillMode? fillMode;
  final AnimationPlayState? playState;

  @override
  String get value {
    var val = '$name ${duration.inMilliseconds}ms';
    if (curve != null) val += ' ${curve!.value}';
    if (delay != null) val += ' ${delay!.inMilliseconds}ms';
    if (count != null) val += ' ${count!.numstr}';
    if (direction != null) val += ' ${direction!.value}';
    if (fillMode != null) val += ' ${fillMode!.value}';
    if (playState != null) val += ' ${playState!.value}';

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
