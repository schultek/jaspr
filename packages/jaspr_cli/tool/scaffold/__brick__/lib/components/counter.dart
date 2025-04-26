import 'package:jaspr/jaspr.dart';
{{#server}}
import '../constants/theme.dart';{{/server}}{{#flutter}}
import 'embedded_counter.dart';{{/flutter}}

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
    ]);{{#flutter}}

    yield EmbeddedCounter(
      count: count,
      onChange: (value) {
        setState(() => count = value);
      },
    );{{/flutter}}
  }{{#server}}

  @css
  static final styles = [
    css('.counter', [
      css('&').styles(
        display: Display.flex,
        padding: Padding.symmetric(vertical: 10.px),
        border: Border.symmetric(vertical: BorderSide.solid(color: primaryColor, width: 2.px)),
        alignItems: AlignItems.center,
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
          fontSize: 2.rem,
          backgroundColor: Colors.transparent,
        ),
        css('&:hover').styles(
          backgroundColor: const Color('#0001'),
        ),
      ]),
      css('span').styles(
        minWidth: 2.5.em,
        padding: Padding.symmetric(horizontal: 2.rem),
        boxSizing: BoxSizing.borderBox, 
        color: primaryColor, 
        textAlign: TextAlign.center,
        fontSize: 4.rem,
      ),
    ]),
  ];{{/server}}
}
