import 'package:jaspr/jaspr.dart';

import 'package:highlight/highlight.dart' show Node, Result, highlight;
import 'package:website/components/code_window/theme.dart';
import 'package:website/constants/theme.dart';

class CodeBlock extends StatelessComponent {
  const CodeBlock({
    required this.source,
    this.selectable = false,
    this.language = 'dart',
    this.scroll = true,
    this.lineClasses = const {},
    super.key,
  });

  final String source;
  final bool selectable;
  final String language;
  final bool scroll;
  final Map<int, String> lineClasses;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    final indent = this.source.indexOf(this.source.trimLeft());
    var source = this.source;

    if (indent > 0) {
      final lines = source.split('\n');
      final indentStr = ' ' * indent;

      source = lines.map((l) => l.startsWith(indentStr) ? l.substring(indent) : l).join('\n');
    }

    final result = highlight.parse(source.trim(), language: language);
    final lines = result.toLines();

    yield div(classes: 'code-block', [
      pre([
        code(classes: 'language-$language ${scroll ? 'scroll' : ''}', [
          span(classes: 'lines ${selectable ? 'selectable' : ''}', [
            for (var i = 0; i < lines.length; i++) ...[
              span(classes: 'line ${lineClasses[i] ?? ''}', [
                span(classes: 'line-number', [text('${i + 1}')]),
                span([raw(lines[i])]),
                raw('&nbsp;'),
              ]),
              br()
            ]
          ]),
        ]),
      ]),
    ]);
  }

  @css
  static final styles = [
    css('.code-block', [
      css('&').flexbox(),
      css('pre', [
        css('&').flexItem(flex: Flex(grow: 1)).box(
              width: Unit.zero,
              position: Position.relative(),
              margin: EdgeInsets.zero,
              padding: EdgeInsets.only(left: 3.em),
            ),
        css('&::before')
            .raw({'content': '""'})
            .box(
              display: Display.block,
              height: 100.percent,
              width: 3.em,
              position: Position.absolute(left: Unit.zero),
            )
            .background(color: surfaceLow),
        css('code', [
          css('&')
            .box(
              display: Display.inlineBlock,
              width: 100.percent,
              overflow: Overflow.only(x: Overflow.hidden),
              padding: EdgeInsets.only(top: 0.5.em, bottom: 0.5.em, right: 0.5.em),
              boxSizing: BoxSizing.borderBox,
            )
            .background(color: surfaceLowest)
            .text(align: TextAlign.start)
            .combine(jasprTheme['root']!),
            css('&.scroll').box(overflow: Overflow.only(x: Overflow.scroll)),
        ]),
        css('.lines', [
          css('&').box(display: Display.inlineBlock, minWidth: 100.percent),
          css('.line', [
            css('&').box(
              display: Display.inlineBlock,
              width: 100.percent,
              padding: EdgeInsets.only(left: .5.em),
            ),
            css('.line-number')
                .box(
                  position: Position.absolute(left: Unit.zero),
                  display: Display.inlineBlock,
                  boxSizing: BoxSizing.borderBox,
                  width: 3.em,
                  padding: EdgeInsets.only(right: 0.6.em),
                  opacity: 0.5,
                )
                .text(align: TextAlign.right, color: textBlack),
          ]),
          css('&.selectable .line:hover', [
            css('&').background(color: hoverOverlayColor),
            css('.line-number').background(color: hoverOverlayColor).box(opacity: 1),
          ]),
        ]),
        for (final e in jasprTheme.entries) css('code span.hljs-${e.key}').combine(e.value),
      ]),
    ]),
  ];
}

extension on Result {
  List<String> toLines() {
    var line = <Node>[];
    var lines = [line];

    for (final node in nodes!) {
      if (node.value != null && node.value!.contains('\n')) {
        assert(node.children == null);

        var v = node.value!.split('\n');

        line.add(Node(className: node.className, value: v.first));

        for (var l in v.skip(1)) {
          line = [Node(className: node.className, value: l)];
          lines.add(line);
        }
      } else {
        line.add(node);
      }
    }

    return lines.map((n) => Result(nodes: n).toHtml()).toList();
  }
}
