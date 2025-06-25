import 'package:html/parser.dart' as html;
// ignore: implementation_imports
import 'package:html/src/token.dart' as html;
// ignore: implementation_imports
import 'package:html/src/tokenizer.dart' as html;
import 'package:markdown/markdown.dart' as md;

import '../page.dart';
import 'html_parser.dart';
import 'page_parser.dart';

md.Document _defaultDocumentBuilder(Page _) {
  return md.Document(
    blockSyntaxes: [CustomHtmlSyntax()],
    extensionSet: md.ExtensionSet.gitHubWeb,
  );
}

typedef DocumentBuilder = md.Document Function(Page page);

/// A parser for Markdown content.
///
/// This parser uses the `markdown` package to parse Markdown content.
class MarkdownParser implements PageParser {
  /// Creates a Markdown parser.
  const MarkdownParser({
    /// The function used to build the Markdown document.
    ///
    /// This can be used to customize the Markdown parser's behavior, e.g. by adding custom syntaxes.
    /// The default builder adds support for component blocks and uses the [md.ExtensionSet.gitHubWeb] extension set.
    this.documentBuilder = _defaultDocumentBuilder,
  });

  final DocumentBuilder documentBuilder;

  @override
  Pattern get pattern => RegExp(r'.*\.mdx?$');

  @override
  List<Node> parsePage(Page page) {
    final markdownDocument = documentBuilder(page);
    final markdownNodes = markdownDocument.parse(page.content);

    return _buildNodes(markdownNodes);
  }

  List<Node> _buildNodes(Iterable<md.Node> markdownNodes) {
    final nodes = <Node>[];
    for (final node in markdownNodes) {
      if (node is md.Text) {
        nodes.addAll(HtmlParser.buildNodes(html.parseFragment(node.text).nodes));
      } else if (node is md.Element) {
        final children = _buildNodes(node.children ?? []);
        nodes.add(ElementNode(
          node.tag,
          {if (node.generatedId != null) 'id': node.generatedId!, ...node.attributes},
          children,
        ));
      }
    }
    return nodes;
  }
}

class CustomHtmlSyntax extends md.BlockSyntax {
  const CustomHtmlSyntax() : super();

  static final _htmlPattern = md.HtmlBlockSyntax().pattern;

  // Extend html pattern to also match incomplete opening tags.
  @override
  RegExp get pattern => RegExp('${_htmlPattern.pattern}|<[a-z][a-z0-9]*\\s', caseSensitive: false);

  @override
  md.Node? parse(md.BlockParser parser) {
    List<html.Token> tokens = [];
    int nesting = 0;
    String incompleteTag = '';

    outer:
    do {
      final content = incompleteTag + parser.current.content;
      incompleteTag = '';
      final tokenizer = html.HtmlTokenizer(
        content,
        lowercaseElementName: false,
      );
      parser.advance();
      try {
        while (tokenizer.moveNext()) {
          final token = tokenizer.current;
          if (token.kind == html.TokenKind.parseError) {
            if (["unexpected-EOF-after-attribute-value", "expected-attribute-name-but-got-eof"]
                .contains((token as html.ParseErrorToken).data)) {
              incompleteTag = content;
              continue outer; // Incomplete tag, continue to next line
            } else {
              throw AssertionError('Unexpected parse error: ${token.data}');
            }
          }
          tokens.add(token);
          if (token.kind == html.TokenKind.startTag && !(token as html.StartTagToken).selfClosing) {
            nesting++;
          } else if (token.kind == html.TokenKind.endTag) {
            nesting--;
          }
        }
      } catch (e) {
        throw AssertionError('Failed to parse HTML block: ${parser.current.content}. Error: $e');
      }
      if (nesting == 0) {
        break;
      }
      tokens.add(html.SpaceCharactersToken('\n'));
    } while (!parser.isDone);

    final root = md.Element('div', []);
    List<md.Element> stack = [root];
    List<md.Node> currentChildren = root.children!;
    StringBuffer currentText = StringBuffer();

    for (final token in tokens) {
      if (token.kind == html.TokenKind.characters || token.kind == html.TokenKind.spaceCharacters) {
        currentText.write((token as html.StringToken).data);
        continue;
      }

      if (currentText.isNotEmpty) {
        var text = currentText.toString();
        if (text.trim().isEmpty) {
          text = ' ';
        }
        // If the text starts and ends with a newline, it is parsed as markdown.
        if (text.startsWith(RegExp('\\s*\n')) && RegExp('\n\\s*\$').hasMatch(text)) {
          final match = RegExp(r'^(\s*)\S', multiLine: true).firstMatch(text);
          final indent = match?.group(1)!.length ?? 0;
          final lines = text
              .split('\n')
              .map((c) => c.replaceFirst(RegExp('^\\s{0,$indent}'), ''))
              .map((t) => md.Line(t))
              .toList();
          final children = md.BlockParser(lines, parser.document).parseLines(parentSyntax: this);
          currentChildren.addAll(children);
        } else {
          currentChildren.add(md.Text(text));
        }
        currentText.clear();
      }

      if (token.kind == html.TokenKind.startTag) {
        final tag = (token as html.StartTagToken).name ?? '';
        final attributes = token.data.map((k, v) => MapEntry(k.toString(), v));
        final element = md.Element(tag, [])..attributes.addAll(attributes);
        currentChildren.add(element);
        if (!token.selfClosing) {
          stack.add(element);
          currentChildren = element.children!;
        }
      } else if (token.kind == html.TokenKind.endTag) {
        if (stack.last.tag != (token as html.EndTagToken).name) {
          // If the end tag does not match the last opened tag, we ignore it.
          continue;
        }
        stack.removeLast();
        currentChildren = stack.last.children!;
      } else if (token.kind == html.TokenKind.comment || token.kind == html.TokenKind.doctype) {
        // Ignore comments and doctype tokens.
        continue;
      }
    }

    if (root.children!.length == 1) {
      return root.children!.first;
    }

    return root;
  }
}
