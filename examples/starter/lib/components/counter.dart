import 'package:jaspr/jaspr.dart';

import '../styles.dart';

class Counter extends StatefulComponent {
  const Counter({super.key});

  @override
  State<Counter> createState() => _CounterState();

  static final styles = [
    StyleRule(
      selector: Selector('.counter'),
      styles: Styles.combine([
        Styles.flexbox(),
        Styles.box(
          border: Border.symmetric(vertical: BorderSide(style: BorderStyle.solid, color: Colors.black, width: 1.px)),
        ),
      ]),
    ),
    StyleRule(
      selector: Selector('.counter button'),
      styles: Styles.combine([
        Styles.text(fontSize: 3.rem),
        Styles.box(width: 2.em, border: Border.unset),
        Styles.flexbox(justifyContent: JustifyContent.center, alignItems: AlignItems.center),
        Styles.background(color: Colors.transparent),
      ]),
    ),
    StyleRule(
      selector: Selector('.counter button:hover'),
      styles: Styles.background(color: primaryColor),
    ),
    StyleRule(
      selector: Selector('.counter span'),
      styles: Styles.combine([
        Styles.box(padding: EdgeInsets.symmetric(horizontal: 2.rem)),
        Styles.text(color: primaryColor, fontSize: 4.rem, fontWeight: FontWeight.w600),
      ]),
    ),
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
