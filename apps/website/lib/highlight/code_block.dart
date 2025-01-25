import 'package:jaspr/jaspr.dart';

import 'package:highlight/highlight.dart' show Node, Result, highlight;
import 'package:website/highlight/theme.dart';

class CodeBlock extends StatelessComponent {
  const CodeBlock({required this.source, this.lineClasses = const {}, this.language = 'dart', super.key});

  final String source;
  final String language;
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
        code(classes: 'language-$language', [
          for (var i = 0; i < lines.length; i++) ...[
            span(classes: 'line ${lineClasses[i]}', [raw(lines[i])]),
            br()
          ]
        ]),
      ]),
    ]);
  }

  @css
  static final styles = [
    css('.code-block', [
      css('&').flexbox(),
      css('pre', [
        css('&')
            .flexItem(flex: Flex(grow: 1))
            .box(
              width: Unit.zero,
              position: Position.relative(),
              margin: EdgeInsets.zero,
              padding: EdgeInsets.only(top: 0.5.em, bottom: 1.5.em),
              overflow: Overflow.only(x: Overflow.scroll),
            ),
        css('.line', [
          css('&').box(
            display: Display.inlineBlock,
            width: 100.percent,
            padding: EdgeInsets.symmetric(horizontal: 8.px),
          ),
          css('&:hover').background(color: Color.hex('#0001')),
        ]),
        for (final e in lightBlueTheme.entries) css('code span.hljs-${e.key}').combine(e.value),
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
