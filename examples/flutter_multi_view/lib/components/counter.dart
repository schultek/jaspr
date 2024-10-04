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
    yield div(classes: 'counter-group', styles: Styles.raw({'view-transition-name': component.name}), [
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
    css('.counter-group').box(
      margin: EdgeInsets.all(10.px),
      padding: EdgeInsets.all(10.px),
      border: Border.all(BorderSide.dashed(width: 1.px, color: Colors.lightGrey)),
      radius: BorderRadius.circular((cardBorderRadius + 10).px),
    ),
    css('.counter', [
      css('&')
          .box(
            padding: EdgeInsets.symmetric(vertical: 10.px),
            border: Border.all(BorderSide.solid(color: primaryColor, width: 1.px)),
            radius: BorderRadius.circular(cardBorderRadius.px),
            maxWidth: cardWidth.px,
            minHeight: cardHeight.px,
            boxSizing: BoxSizing.borderBox,
          )
          .background(color: surfaceColor)
          .flexbox(alignItems: AlignItems.center, justifyContent: JustifyContent.spaceAround)
          .text(color: Colors.black),
      css('button', [
        css('&')
            .text(fontSize: 1.5.rem)
            .box(width: 2.em, height: 2.em, border: Border.unset, cursor: Cursor.pointer)
            .box(radius: BorderRadius.all(Radius.circular(2.em)))
            .flexbox(justifyContent: JustifyContent.center, alignItems: AlignItems.center)
            .background(color: Colors.transparent),
        css('&:hover').background(color: const Color.hex('#0001')),
      ]),
      css('span').text(fontSize: 14.px, align: TextAlign.center),
      css('b').text(fontSize: 18.px),
    ]),
  ];
}
