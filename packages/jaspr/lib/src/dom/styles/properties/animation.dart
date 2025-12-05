/// @docImport '../rules.dart';
library;

import 'transition.dart' show Curve;
import 'unit.dart';

/// The `animation` CSS property applies an animation between styles.
///
/// CSS animations make it possible to animate transitions from one CSS style configuration to another. Animations
/// consist of two components: a style describing the CSS [Animation] and a set of [StyleRule.keyframes] that indicate
/// the start and end states of the animation's style, as well as possible intermediate waypoints.
///
/// Read more: [MDN Using CSS animations](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_animations/Using_CSS_animations)
class Animation {
  const Animation._(this.value);

  /// No animation.
  static const none = Animation._('none');

  /// Creates an animation with the given name, duration, and optional properties.
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

  /// Combines multiple animations into a single property.
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
    var val = '${duration.inMilliseconds}ms';
    if (curve != null) val += ' ${curve!.value}';
    if (delay != null) val += ' ${delay!.inMilliseconds}ms';
    if (count != null) val += ' ${count!.numstr}';
    if (direction != null) val += ' ${direction!.value}';
    if (fillMode != null) val += ' ${fillMode!.value}';
    if (playState != null) val += ' ${playState!.value}';
    val += ' $name';

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

/// The `animation-direction` CSS property sets whether an animation should play forward, backward, or alternate back
/// and forth between playing the sequence forward and backward.
///
/// Read more: [MDN `animation-direction`](https://developer.mozilla.org/en-US/docs/Web/CSS/animation-direction)
enum AnimationDirection {
  /// The animation plays forwards each cycle. In other words, each time the animation cycles, the animation will reset
  /// to the beginning state and start over again. This is the default value.
  normal('normal'),

  /// The animation plays backwards each cycle. In other words, each time the animation cycles, the animation will reset
  /// to the end state and start over again. Animation steps are performed backwards, and easing functions are also reversed.
  reverse('reverse'),

  /// The animation reverses direction each cycle, with the first iteration being played forwards. The count to determine
  /// if a cycle is even or odd starts at one.
  alternate('alternate'),

  /// The animation reverses direction each cycle, with the first iteration being played backwards. The count to determine
  /// if a cycle is even or odd starts at one.
  alternateReverse('alternate-reverse');

  const AnimationDirection(this.value);
  final String value;
}

/// The `animation-fill-mode` CSS property sets how a CSS animation applies styles to its target before and after its execution.
///
/// Read more: [MDN `animation-fill-mode`](https://developer.mozilla.org/en-US/docs/Web/CSS/animation-fill-mode)
enum AnimationFillMode {
  /// The animation will not apply any styles to the target when it's not executing. The element will instead be displayed
  /// using any other CSS rules applied to it. This is the default value.
  none('none'),

  /// The target will retain the computed values set by the last keyframe encountered during execution.
  forwards('forwards'),

  /// The animation will apply the values defined in the first relevant keyframe as soon as it is applied to the target,
  /// and retain this during the animation-delay period.
  backwards('backwards'),

  /// The animation will follow the rules for both [forwards] and [backwards], thus extending the animation properties in
  /// both directions.
  both('both');

  const AnimationFillMode(this.value);
  final String value;
}

/// The `animation-play-state` CSS property sets whether an animation is running or paused.
///
/// Read more: [MDN `animation-play-state`](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/animation-play-state)
enum AnimationPlayState {
  /// The animation is currently playing.
  running('running'),

  /// The animation is currently paused.
  paused('paused');

  const AnimationPlayState(this.value);
  final String value;
}
