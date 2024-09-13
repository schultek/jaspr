import 'package:jaspr/jaspr.dart';

import '../constants/theme.dart';

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
      span(
        styles: Styles().text(
          fontSize: AppTheme.counterTextFontSize.unit,
          fontFamily: AppTheme.counterTextFontFamily.fontFamily,
        ),
        [text('$count')],
      ),
      button(
        onClick: () {
          setState(() => count++);
        },
        [text('+')],
      ),
    ]);
  }

  @css
  static final styles = [
    css('.counter', [
      css('&').flexbox(alignItems: AlignItems.center).box(
            padding: EdgeInsets.symmetric(vertical: 10.px),
            border: Border.symmetric(vertical: BorderSide.solid(color: Colors.black, width: 1.px)),
          ),
      css('button', [
        css('&')
            .text(fontSize: 2.rem, color: AppTheme.counterButtonTextColor.color)
            .box(
              width: 2.em,
              height: 2.em,
              radius: BorderRadius.all(Radius.circular(2.em)),
              border: Border.all(
                BorderSide(
                  width: 4.px,
                  color: AppTheme.counterButtonBorderColor.color,
                ),
              ),
              cursor: Cursor.pointer,
            )
            .flexbox(justifyContent: JustifyContent.center, alignItems: AlignItems.center)
            .background(color: AppTheme.counterButtonColor.color),
        css('&:hover').background(color: const Color.hex('#0001')),
      ]),
      css('span')
          .box(padding: EdgeInsets.symmetric(horizontal: 2.rem), boxSizing: BoxSizing.borderBox, minWidth: 2.5.em)
          .text(color: Colors.black, fontSize: 4.rem, align: TextAlign.center),
    ]),
  ];
}
