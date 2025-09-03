import 'package:highlight/highlight.dart' show Node, Result, highlight;
import 'package:jaspr/jaspr.dart';
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
  Component build(BuildContext context) {
    final indent = this.source.indexOf(this.source.trimLeft());
    var source = this.source;

    if (indent > 0) {
      final lines = source.split('\n');
      final indentStr = ' ' * indent;

      source = lines.map((l) => l.startsWith(indentStr) ? l.substring(indent) : l).join('\n');
    }

    final result = highlight.parse(source.trim(), language: language);
    final lines = result.toLines();

    return div(classes: 'code-block', [
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
  static List<StyleRule> get styles => [
        css('.code-block', [
          css('&').styles(display: Display.flex),
          css('pre', [
            css('&').styles(
              position: Position.relative(),
              width: Unit.zero,
              padding: Padding.only(left: 3.em),
              margin: Margin.zero,
              flex: Flex(grow: 1),
            ),
            css('&::before').styles(
              content: '',
              display: Display.block,
              position: Position.absolute(left: Unit.zero),
              width: 3.em,
              height: 100.percent,
              backgroundColor: surfaceLow,
            ),
            css('code', [
              css('&')
                  .styles(
                    display: Display.inlineBlock,
                    width: 100.percent,
                    padding: Padding.only(top: 0.5.em, bottom: 0.5.em, right: 0.5.em),
                    boxSizing: BoxSizing.borderBox,
                    overflow: Overflow.only(x: Overflow.hidden),
                    textAlign: TextAlign.start,
                    backgroundColor: surfaceLowest,
                  )
                  .combine(jasprTheme['root']!),
              css('&.scroll').styles(
                overflow: Overflow.only(x: Overflow.scroll),
              ),
            ]),
            css('.lines', [
              css('&').styles(
                display: Display.inlineBlock,
                minWidth: 100.percent,
              ),
              css('.line', [
                css('&').styles(
                  display: Display.inlineBlock,
                  width: 100.percent,
                  padding: Padding.only(left: .5.em),
                ),
                css('.line-number').styles(
                  display: Display.inlineBlock,
                  position: Position.absolute(left: Unit.zero),
                  width: 3.em,
                  padding: Padding.only(right: 0.6.em),
                  boxSizing: BoxSizing.borderBox,
                  opacity: 0.5,
                  color: textBlack,
                  textAlign: TextAlign.right,
                ),
              ]),
              css('&.selectable .line:hover', [
                css('&').styles(
                  backgroundColor: hoverOverlayColor,
                ),
                css('.line-number').styles(
                  opacity: 1,
                  backgroundColor: hoverOverlayColor,
                ),
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
