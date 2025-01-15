import 'package:jaspr/jaspr.dart';

import 'package:highlight/highlight.dart' show highlight;
import 'package:website/highlight/theme.dart';

class CodeBlock extends StatelessComponent {
  const CodeBlock({required this.source, this.language = 'dart', super.key});

  final String source;
  final String language;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    final result = highlight.parse(source, language: language);
    final html = result.toHtml();

    yield pre([
      code(classes: 'language-$language', [raw(html)]),
    ]);
  }

  @css
  static final styles = [
    for (final e in githubTheme.entries)
      css('code span.hljs-${e.key}').combine(e.value),
  ];
}
