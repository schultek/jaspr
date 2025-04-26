import 'package:jaspr/jaspr.dart';

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
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: 'counter-group', styles: Styles(raw: {'view-transition-name': component.name}), [
      div(classes: 'counter', [
        button(
          onClick: () {
            setState(() => count--);
          },
          [text('–')],
        ),
        span([
          text('Jaspr Counter'),
          br(),
          b([text('$count')]),
        ]),
        button(
          onClick: () {
            setState(() => count++);
          },
          [text('+')],
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
  static final styles = [
    css('.counter-group').styles(
      padding: Padding.all(10.px),
      margin: Margin.all(10.px),
      border: Border(style: BorderStyle.dashed, width: 1.px, color: Colors.lightGrey),
      radius: BorderRadius.circular((cardBorderRadius + 10).px),
    ),
    css('.counter', [
      css('&').styles(
        display: Display.flex,
        minHeight: cardHeight.px,
        maxWidth: cardWidth.px,
        padding: Padding.symmetric(vertical: 10.px),
        boxSizing: BoxSizing.borderBox,
        border: Border(color: primaryColor, width: 1.px),
        radius: BorderRadius.circular(cardBorderRadius.px),
        justifyContent: JustifyContent.spaceAround,
        alignItems: AlignItems.center,
        color: Colors.black,
        backgroundColor: surfaceColor,
      ),
      css('button', [
        css('&').styles(
          display: Display.flex,
          width: 2.em,
          height: 2.em,
          border: Border.unset,
          radius: BorderRadius.all(Radius.circular(2.em)),
          cursor: Cursor.pointer,
          justifyContent: JustifyContent.center,
          alignItems: AlignItems.center,
          fontSize: 1.5.rem,
          backgroundColor: Colors.transparent,
        ),
        css('&:hover').styles(
          backgroundColor: const Color('#0001'),
        ),
      ]),
      css('span').styles(
        textAlign: TextAlign.center,
        fontSize: 14.px,
      ),
      css('b').styles(fontSize: 18.px),
    ]),
  ];
}
