import 'package:flutter_multi_view/constants/theme.dart';
import 'package:jaspr/jaspr.dart';

class PulsingLoader extends StatelessComponent {
  const PulsingLoader({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: 'loader', []);
  }

  @css
  static final styles = [
    css('.loader').styles(
      margin: Margin.all(Unit.auto),
      boxSizing: BoxSizing.borderBox,
      border: Border(width: 0.px, color: loaderColor),
      radius: BorderRadius.circular(50.percent),
      raw: {'animation': 'loading 1s infinite ease-out'},
    ),
    css.keyframes('loading', {
      '0%': Styles(
        width: 0.px,
        height: 0.px,
        backgroundColor: loaderColor,
      ),
      '29%': Styles(
        backgroundColor: loaderColor,
      ),
      '30%': Styles(
        width: 30.px,
        height: 30.px,
        border: Border(width: 15.px, color: loaderColor),
        opacity: 1,
        backgroundColor: Colors.transparent,
      ),
      '100%': Styles(
        width: 30.px,
        height: 30.px,
        border: Border(width: 0.px, color: loaderColor),
        opacity: 0,
        backgroundColor: Colors.transparent,
      ),
    })
  ];
}

/*
0%
    +size(0)
    background-color: $loader-color

  29%
    background-color: $loader-color

  30%
    +size($loader-size)
    background-color: transparent
    border-width: $loader-size / 2
    opacity: 1

  100%
    +size($loader-size)
    border-width: 0
    opacity: 0
    background-color: transparent
 */
