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
    css('.loader')
        .box(
      margin: EdgeInsets.all(Unit.auto),
      boxSizing: BoxSizing.borderBox,
      border: Border.all(BorderSide.solid(width: 0.px, color: loaderColor)),
      radius: BorderRadius.circular(50.percent),
    )
        .raw({'animation': 'loading 1s infinite ease-out'}),
    css.keyframes('loading', {
      '0%': Styles.background(color: loaderColor).box(width: 0.px, height: 0.px),
      '29%': Styles.background(color: loaderColor),
      '30%': Styles.box(
              width: 30.px, height: 30.px, border: Border.all(BorderSide(width: 15.px, color: loaderColor)), opacity: 1)
          .background(color: Colors.transparent),
      '100%': Styles.box(
              width: 30.px, height: 30.px, border: Border.all(BorderSide(width: 0.px, color: loaderColor)), opacity: 0)
          .background(color: Colors.transparent),
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
