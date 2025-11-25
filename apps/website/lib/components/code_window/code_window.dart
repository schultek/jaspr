import 'package:jaspr/dom.dart';

import '../../constants/theme.dart';
import '../icon.dart';
import 'code_block.dart';

class CodeWindow extends StatelessComponent {
  CodeWindow({
    required this.name,
    this.inactiveName,
    required this.source,
    this.selectable = false,
    this.framed = true,
    this.lineClasses = const {},
    this.language = 'dart',
    this.scroll = true,
    super.key,
  });

  final String name;
  final String? inactiveName;
  final String source;
  final bool selectable;
  final bool framed;
  final String language;
  final bool scroll;
  final Map<int, String> lineClasses;

  @override
  Component build(BuildContext context) {
    return div(classes: 'code-window ${framed ? 'framed' : ''}', [
      div(classes: 'code-window-header', [
        div(classes: 'code-window-tab', [
          if (name.endsWith('.dart')) Icon('dart'),
          if (name.endsWith('.yaml')) Icon('file-json-2', size: 1.em),
          span(classes: 'code-window-title mono', [.text(name)]),
        ]),
        if (inactiveName != null)
          div(classes: 'code-window-tab inactive', [
            if (inactiveName!.endsWith('.dart')) Icon('dart'),
            if (inactiveName!.endsWith('.yaml')) Icon('file-json-2', size: 1.em),
            span(classes: 'code-window-title mono', [.text(inactiveName!)]),
          ]),
      ]),
      div(classes: 'code-window-body', [
        CodeBlock(source: source, selectable: selectable, lineClasses: lineClasses, language: language, scroll: scroll),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.code-window', [
      css('&').styles(radius: .circular(13.px)),
      css('&.framed', [
        css('&').styles(
          border: .all(color: borderColor, width: 6.px),
          overflow: .hidden,
          shadow: .new(offsetX: 2.px, offsetY: 2.px, blur: 18.px, color: shadowColor1),
          backgroundColor: borderColor,
        ),
      ]),
      css('&:not(.framed)', [
        css('.code-window-body').styles(
          shadow: .new(offsetX: 2.px, offsetY: 2.px, blur: 10.px, color: shadowColor3),
        ),
      ]),
      css('.code-window-header', [
        css('&').styles(
          display: .flex,
          padding: .only(left: 2.6.em, top: 2.px),
          gap: .column(0.2.rem),
        ),
        css('.code-window-tab', [
          css('&').styles(
            display: .flex,
            padding: .only(left: .8.em, right: 1.2.em, top: .5.em, bottom: .5.em),
            radius: .only(topLeft: .circular(6.px), topRight: .circular(6.px)),
            shadow: .new(offsetX: 0.px, offsetY: (-2).px, blur: 3.px, color: shadowColor1),
            alignItems: .center,
            gap: .column(0.4.rem),
            color: textBlack,
            backgroundColor: surfaceLowest,
          ),
          css('&.inactive').styles(
            width: 0.px,
            opacity: 0.5,
            flex: .grow(1),
            raw: {'max-width': 'fit-content'},
          ),
        ]),
        css('.code-window-title').styles(
          fontSize: 0.9.rem,
          fontWeight: .w400,
        ),
      ]),
      css('.code-window-body', [
        css('&').styles(
          radius: .circular(8.px),
          overflow: .hidden,
          shadow: .new(offsetX: .zero, offsetY: .zero, blur: 4.px, color: shadowColor1),
          backgroundColor: background,
        ),
      ]),
    ]),
  ];
}
