import 'package:jaspr/jaspr.dart';

import '../styles.dart';

class Counter extends StatefulComponent {
  const Counter({super.key});

  @override
  State<Counter> createState() => _CounterState();

  static get styles => [
        css('.counter', [
          css('&').flexbox().box(
                padding: EdgeInsets.symmetric(vertical: 10.px),
                border: Border.symmetric(vertical: BorderSide.solid(color: primaryColor, width: 1.px)),
              ),
          css('button', [
            css('&')
                .text(fontSize: 3.rem)
                .box(width: 2.em, border: Border.unset)
                .box(radius: BorderRadius.all(Radius.circular(10.px)))
                .flexbox(justifyContent: JustifyContent.center, alignItems: AlignItems.center)
                .background(color: Colors.transparent),
            css('&:hover').text(color: Colors.white).background(color: primaryColor),
          ]),
          css('span') //
              .box(padding: EdgeInsets.symmetric(horizontal: 2.rem))
              .text(color: primaryColor, fontSize: 4.rem),
        ]),
      ];
}

class _CounterState extends State<Counter> {
  int count = 0;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: 'counter', [
      button(
        onClick: () {
          setState(() {
            count--;
          });
        },
        [text('-')],
      ),
      span([text('$count')]),
      button(
        onClick: () {
          setState(() {
            count++;
          });
        },
        [text('+')],
      ),
    ]);
  }
}
