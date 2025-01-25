import 'package:jaspr/jaspr.dart';

import '../highlight/code_block.dart';

class CodeWindow extends StatelessComponent {
  CodeWindow({
    required this.name,
    required this.source,
    this.lineClasses = const {},
    this.language = 'dart',
    super.key,
  });

  final String name;
  final String source;
  final String language;
  final Map<int, String> lineClasses;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: 'code-window', [
      div(classes: 'code-window-header', [
        span(classes: 'code-window-title', [text(name)]),
      ]),
      div(classes: 'code-window-body', [
        CodeBlock(source: source, lineClasses: lineClasses, language: language),
      ]),
    ]);
  }

  @css
  static final List<StyleRule> styles = [
    css('.code-window', [
      css('&')
          .box(
            border: Border.all(BorderSide(color: Color.hex('#CCC'), width: 1.px)),
            radius: BorderRadius.circular(18.px),
            overflow: Overflow.hidden,
          )
          .background(color: Color.hex('#F5F5F5')),
      css('.code-window-header', [
        css('&')
            .box(
              padding: EdgeInsets.symmetric(horizontal: 12.px, vertical: 8.px),
              border: Border.only(bottom: BorderSide.solid(color: Color.hex('#CCC'))),
            )
            .background(color: Colors.white),
        css('.code-window-title').text(fontFamily: FontFamilies.monospace, fontWeight: FontWeight.bold),
      ]),
    ]),
  ];
}
