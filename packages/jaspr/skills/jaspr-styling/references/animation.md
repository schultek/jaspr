# Jaspr Transitions & Animations

When animating elements using `Styles`, Jaspr provides strong typings for CSS Transitions and Animations.

## Transitions
To smooth property changes on an element, you MUST use the `Transition` class:
- `transition: Transition('all', duration: 300.ms)`
- `transition: Transition('opacity', duration: 500.ms, curve: .easeInOut)`
- `transition: Transition('transform', duration: 2.seconds, delay: 200.ms, curve: .linear)`
- ```dart
  transition: Transition.combine([
    Transition('opacity', duration: 300.ms),
    Transition('transform', duration: 300.ms, curve: .easeOut),
  ])
  ```

## Animations
To bind CSS keyframe animations to an element, use the `Animation` class:
- `animation: Animation('my-slide-in', duration: 1000.ms, curve: .easeInOut)`
- `animation: Animation('bounce', duration: 2.seconds, count: 4)`
- ```dart
  animation: Animation.list([
    Animation('fade-in', duration: 1000.ms),
    Animation('slide-up', duration: 1000.ms, curve: .easeOut),
  ])
  ```

You can customize the following parameters:
- `String name`: `'my-animation'`
- `Duration duration`: `1000.ms`, `3.seconds`
- `Curve? curve`: `.ease`, `.easeIn`, `.easeInOut`, `.easeOut`, `.linear` or `.cubicBezier(1.0, 0.5, 0.8, 1.2)`
- `Duration? delay`: `500.ms`, `2.seconds`
- `int? count`: `2`
- `AnimationDirection? direction`: `.normal` or `.reverse`, `.alternate`, `.alternate-reverse`
- `AnimationFillMode? fillMode`: `.none` or `.forwards`, `.backwards`, `.both`
- `AnimationPlayState? playState`: `.running` or `.paused`

### Keyframes

The actual `@keyframes` definitions can be created using the `css.keyframes` function inside your `@css` list.

Provide the name of the keyframe and a `Map<String, Styles>` representing the waypoints (e.g. `'0%'`, `'100%'`, `'from'`, `'to'`):

```dart
@css
static List<StyleRule> get styles => [
  css.keyframes('my-slide-in', {
    '0%': Styles(transform: .translate(x: (-100).percent)),
    '100%': Styles(transform: .translate(x: 0.percent)),
  }),
  css('.alert', [
    css('&').styles(
      animation: Animation('my-slide-in', duration: 1000.ms, curve: .easeOut),
    )
  ])
];
```
