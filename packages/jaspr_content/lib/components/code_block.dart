import 'package:jaspr/server.dart';
import 'package:syntax_highlight_lite/syntax_highlight_lite.dart' hide Color;

import '../jaspr_content.dart';
import '_internal/code_block_copy_button.dart';

/// A code block component that renders syntax-highlighted code.
class CodeBlock implements CustomComponent {
  CodeBlock({
    this.defaultLanguage = 'dart',
    this.defaultTheme,
    this.themes = const {},
  });

  static Component from({
    required String source,
    Highlighter? highlighter,
    Key? key,
  }) {
    return _CodeBlock(
      source: source,
      highlighter: highlighter,
      key: key,
    );
  }

  /// The default language for the code block.
  final String defaultLanguage;

  /// The default theme for the code block.
  final HighlighterTheme? defaultTheme;

  /// The available themes for the code block.
  final Map<String, HighlighterTheme> themes;

  bool _initialized = false;

  @override
  Component? create(Node node, NodesBuilder builder) {
    if (node
        case ElementNode(tag: 'Code' || 'CodeBlock', :final children, :final attributes) ||
            ElementNode(tag: 'pre', children: [ElementNode(tag: 'code', :final children, :final attributes)])) {
      var language = attributes['language'];
      if (language == null && (attributes['class']?.startsWith('language-') ?? false)) {
        language = attributes['class']!.substring('language-'.length);
      }

      if (!_initialized) {
        Highlighter.initialize(['dart']);
        _initialized = true;
      }

      return AsyncBuilder(builder: (context) async* {
        final highlighter = Highlighter(
          language: language ?? defaultLanguage,
          theme: await HighlighterTheme.loadDarkTheme(),
        );

        yield _CodeBlock(
          source: children?.map((c) => c.innerText).join(' ') ?? '',
          highlighter: highlighter,
        );
      });
    }
    return null;
  }


  @css
  static List<StyleRule> get styles => [
        css('.code-block', [
          css('&').styles(position: Position.relative()),
          css('button').styles(
            position: Position.absolute(top: 1.rem, right: 1.rem),
            opacity: 0,
            color: Colors.white,
            width: 1.25.rem,
            height: 1.25.rem,
            zIndex: ZIndex(10),
          ),
          css('&:hover button').styles(opacity: 0.75),
        ]),
      ];
}

/// A code block component with syntax highlighting.
class _CodeBlock extends StatelessComponent {
  const _CodeBlock({
    required this.source,
    this.highlighter,
    super.key,
  });

  /// The source code of the code block.
  final String source;

  /// The syntax highlighter instance.
  final Highlighter? highlighter;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    final codeblock = pre([
      code([
        if (highlighter != null) buildSpan(highlighter!.highlight(source)) else text(source),
      ])
    ]);

    yield div(classes: 'code-block', [
      CodeBlockCopyButton(),
      codeblock,
    ]);
  }

  Component buildSpan(TextSpan textSpan) {
    Styles? styles;

    if (textSpan.style case final style?) {
      styles = Styles(
        color: Color.value(style.foreground.argb & 0x00FFFFFF),
        fontWeight: style.bold ? FontWeight.bold : null,
        fontStyle: style.italic ? FontStyle.italic : null,
        textDecoration: style.underline ? TextDecoration(line: TextDecorationLine.underline) : null,
      );
    }

    if (styles == null && textSpan.children.isEmpty) {
      return text(textSpan.text ?? '');
    }

    return span(styles: styles, [
      if (textSpan.text != null) text(textSpan.text!),
      for (final t in textSpan.children) buildSpan(t),
    ]);
  }

}
