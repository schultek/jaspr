import 'package:jaspr/dom.dart';
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
  Component build(BuildContext context) {
    return div([
      div(classes: 'counter', [
        button(
          onClick: () {
            setState(() => count--);
          },
          [.text('-')],
        ),
        span([.text('$count')]),
        button(
          onClick: () {
            setState(() => count++);
          },
          [.text('+')],
        ),
      ]),{{#flutter}}
      EmbeddedCounter(
        count: count,
        onChange: (value) {
          setState(() => count = value);
        },
      ),{{/flutter}}
    ]);
  }{{#server}}

  @css
  static List<StyleRule> get styles => [
    css('.counter', [
      css('&').styles(
        display: .flex,
        padding: .symmetric(vertical: 10.px),
        border: .symmetric(vertical: .solid(color: primaryColor, width: 2.px)),
        alignItems: .center,
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
          fontSize: 2.rem,
          backgroundColor: Colors.transparent,
        ),
        css('&:hover').styles(
          backgroundColor: const Color('#0001'),
        ),
      ]),
      css('span').styles(
        minWidth: 2.5.em,
        padding: .symmetric(horizontal: 2.rem),
        boxSizing: .borderBox, 
        color: primaryColor, 
        textAlign: .center,
        fontSize: 4.rem,
      ),
    ]),
  ];{{/server}}
}
