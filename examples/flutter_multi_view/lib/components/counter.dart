import 'package:jaspr/dom.dart';

import '../constants/theme.dart';
import 'embedded_counter.dart';

class Counter extends StatefulComponent {
  const Counter({required this.name, super.key});

  final String name;

  @override
  State<Counter> createState() => CounterState();
}

class CounterState extends State<Counter> {
  int count = 0;

  @override
  Component build(BuildContext context) {
    return div(classes: 'counter-group', styles: Styles(raw: {'view-transition-name': component.name}), [
      div(classes: 'counter', [
        button(
          onClick: () {
            setState(() => count--);
          },
          [.text('–')],
        ),
        span([
          .text('Jaspr Counter'),
          br(),
          b([.text('$count')]),
        ]),
        button(
          onClick: () {
            setState(() => count++);
          },
          [.text('+')],
        ),
      ]),
      EmbeddedCounter(
        count: count,
        onChange: (value) {
          setState(() => count = value);
        },
      ),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.counter-group').styles(
      padding: .all(10.px),
      margin: .all(10.px),
      border: .all(style: .dashed, width: 1.px, color: Colors.lightGrey),
      radius: .circular((cardBorderRadius + 10).px),
    ),
    css('.counter', [
      css('&').styles(
        display: .flex,
        minHeight: cardHeight.px,
        maxWidth: cardWidth.px,
        padding: .symmetric(vertical: 10.px),
        boxSizing: .borderBox,
        border: .all(color: primaryColor, width: 1.px),
        radius: .circular(cardBorderRadius.px),
        justifyContent: .spaceAround,
        alignItems: .center,
        color: Colors.black,
        backgroundColor: surfaceColor,
      ),
      css('button', [
        css('&').styles(
          display: .flex,
          width: 2.em,
          height: 2.em,
          border: .unset,
          radius: .all(.circular(2.em)),
          cursor: .pointer,
          justifyContent: .center,
          alignItems: .center,
          fontSize: 1.5.rem,
          backgroundColor: Colors.transparent,
        ),
        css('&:hover').styles(backgroundColor: const Color('#0001')),
      ]),
      css('span').styles(textAlign: .center, fontSize: 14.px),
      css('b').styles(fontSize: 18.px),
    ]),
  ];
}
