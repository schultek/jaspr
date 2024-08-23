import 'package:jaspr/jaspr.dart';

import '../styles.dart';
import 'flutter_counter.dart';

class Counter extends StatefulComponent {
  const Counter({super.key});

  @override
  State<Counter> createState() => CounterState();
}

class CounterState extends State<Counter> {
  int count = 0;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: 'counter', [
      button(
        onClick: () {
          setState(() => count--);
        },
        [text('-')],
      ),
      span([text('$count')]),
      button(
        onClick: () {
          setState(() => count++);
        },
        [text('+')],
      ),
    ]);

    yield FlutterCounter(
      count: count,
      onChange: (value) {
        setState(() => count = value);
      },
    );
  }

  @css
  static final styles = [
    css('.counter', [
      css('&').flexbox(alignItems: AlignItems.center).box(
            padding: EdgeInsets.symmetric(vertical: 10.px),
            border: Border.symmetric(vertical: BorderSide.solid(color: primaryColor, width: 1.px)),
          ),
      css('button', [
        css('&')
            .text(fontSize: 2.rem)
            .box(width: 2.em, height: 2.em, border: Border.unset, cursor: Cursor.pointer)
            .box(radius: BorderRadius.all(Radius.circular(2.em)))
            .flexbox(justifyContent: JustifyContent.center, alignItems: AlignItems.center)
            .background(color: Colors.transparent),
        css('&:hover').background(color: const Color.hex('#0001')),
      ]),
      css('span') //
          .box(padding: EdgeInsets.symmetric(horizontal: 2.rem), boxSizing: BoxSizing.borderBox, minWidth: 2.5.em)
          .text(color: primaryColor, fontSize: 4.rem, align: TextAlign.center),
    ]),
  ];
}
