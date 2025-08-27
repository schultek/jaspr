import 'package:html/parser.dart' as html;
// ignore: implementation_imports
import 'package:html/src/token.dart' as html;
// ignore: implementation_imports
import 'package:html/src/tokenizer.dart' as html;
import 'package:jaspr/jaspr.dart';
import 'package:markdown/markdown.dart' as md;

import '../page.dart';
import 'html_parser.dart';
import 'page_parser.dart';

md.Document _defaultDocumentBuilder(Page _) {
  return md.Document(
    blockSyntaxes: MarkdownParser.defaultBlockSyntaxes,
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

  static const List<md.BlockSyntax> defaultBlockSyntaxes = [
    JasprHtmlBlockSyntax(),
  ];

  @override
  Pattern get pattern => RegExp(r'.*\.mdx?$');

  @override
  List<Node> parsePage(Page page) {
    final markdownDocument = documentBuilder(page);
    final markdownNodes = markdownDocument.parse(page.content);

    return buildNodes(markdownNodes);
  }

  /// Converts the given [markdownNodes] to a list of [Node]s.
  ///
  /// This also handles html blocks inside the parsed markdown content.
  static List<Node> buildNodes(Iterable<md.Node> markdownNodes) {
    final root = ElementNode('_', {}, []);
    List<ElementNode> stack = [root];
    List<Node> currentNodes = root.children!;

    for (final node in markdownNodes) {
      if (node is HtmlText) {
        final tokenizer = html.HtmlTokenizer(
          node.text,
          lowercaseElementName: false,
        );

        while (tokenizer.moveNext()) {
          final token = tokenizer.current;

          if (token.kind == html.TokenKind.parseError) {
            final error = (token as html.ParseErrorToken).data;
            if (error == 'expected-tag-name-but-got-question-mark') {
              // This error happens with processing instructions like <?some-instruction ... ?>
              // We can safely ignore it, since the next token will be a comment containing the instruction.
              continue;
            } else {
              throw AssertionError('Unexpected parse error: ${token.data}');
            }
          }

          if (token.kind == html.TokenKind.startTag) {
            final tag = (token as html.StartTagToken).name ?? '';
            final attributes = token.data.map((k, v) => MapEntry(k.toString(), v));
            final element = ElementNode(tag, attributes, []);
            currentNodes.add(element);
            final selfClosing = token.selfClosing || const DomValidator().isSelfClosing(token.name ?? '');
            if (!selfClosing) {
              stack.add(element);
              currentNodes = element.children!;
            }
          } else if (token.kind == html.TokenKind.endTag) {
            if (stack.last.tag != (token as html.EndTagToken).name) {
              // If the end tag does not match the last opened tag, we ignore it.
              continue;
            }
            stack.removeLast();
            currentNodes = stack.last.children!;
          } else if (token.kind == html.TokenKind.characters || token.kind == html.TokenKind.spaceCharacters) {
            currentNodes.add(TextNode((token as html.StringToken).data));
          } else if (token.kind == html.TokenKind.comment) {
            var data = (token as html.CommentToken).data;
            if (data.startsWith('?') && data.endsWith('?')) {
              data = data.substring(1, data.length - 1);
            }
            currentNodes.add(TextNode('<!--$data-->', raw: true));
          } else if (token.kind == html.TokenKind.doctype) {
            // Ignore doctype tokens.
            continue;
          }
        }
      } else if (node is md.Text) {
        currentNodes.addAll(HtmlParser.buildNodes(html.parseFragment(node.text).nodes));
      } else if (node is md.Element) {
        final children = buildNodes(node.children ?? []);
        currentNodes.add(ElementNode(
          node.tag,
          {if (node.generatedId != null) 'id': node.generatedId!, ...node.attributes},
          children,
        ));
      }
    }

    return root.children!;
  }
}

class JasprHtmlBlockSyntax extends md.HtmlBlockSyntax {
  const JasprHtmlBlockSyntax() : super();

  @override
  md.Node parse(md.BlockParser parser) {
    final childLines = parseChildLines(parser);

    var text = childLines.map((e) => e.content).join('\n').trimRight();
    return HtmlText(text);
  }
}

class HtmlText extends md.Text {
  HtmlText(super.text);
}
