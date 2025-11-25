import 'package:jaspr/dom.dart';

import '../constants/theme.dart';

class PulsingLoader extends StatelessComponent {
  const PulsingLoader({super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'loader', []);
  }

  @css
  static List<StyleRule> get styles => [
    css('.loader').styles(
      margin: .all(.auto),
      boxSizing: .borderBox,
      border: .all(width: 0.px, color: loaderColor),
      radius: .circular(50.percent),
      raw: {'animation': 'loading 1s infinite ease-out'},
    ),
    css.keyframes('loading', {
      '0%': Styles(width: 0.px, height: 0.px, backgroundColor: loaderColor),
      '29%': Styles(backgroundColor: loaderColor),
      '30%': Styles(
        width: 30.px,
        height: 30.px,
        border: .all(width: 15.px, color: loaderColor),
        opacity: 1,
        backgroundColor: Colors.transparent,
      ),
      '100%': Styles(
        width: 30.px,
        height: 30.px,
        border: .all(width: 0.px, color: loaderColor),
        opacity: 0,
        backgroundColor: Colors.transparent,
      ),
    }),
  ];
}
