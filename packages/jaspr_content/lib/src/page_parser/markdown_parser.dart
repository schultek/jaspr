import 'package:html/parser.dart' as html;
import 'package:markdown/markdown.dart' as md;

import '../page.dart';
import 'html_parser.dart';
import 'page_parser.dart';

md.Document _defaultDocumentBuilder(Page _) {
  return md.Document(
    blockSyntaxes: [ComponentBlockSyntax()],
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

class ComponentBlockSyntax extends md.BlockSyntax {
  const ComponentBlockSyntax();

  @override
  RegExp get pattern => RegExp(r'^\s*<([A-Z][a-zA-Z]*)\s*([^>]*?)((/?)>(?:(.*)</([A-Z][a-zA-Z]*)>)?)?\s*$');

  RegExp get closingPattern => RegExp(r'^([^>]*?)(/?)>(?:(.*)</([A-Z][a-zA-Z]*)>)?$');
  RegExp get endPattern => RegExp(r'^\s*</([A-Z][a-zA-Z]*)>\s*$');

  @override
  List<md.Line> parseChildLines(md.BlockParser parser, [String endTag = '']) {
    final childLines = <md.Line>[];

    var nesting = 1;

    while (!parser.isDone) {
      if (nesting == 0) break;

      final line = parser.current;
      childLines.add(line);
      parser.advance();

      var match = endPattern.firstMatch(line.content);
      if (match != null && match.group(1) == endTag) {
        nesting--;
        continue;
      }

      match = pattern.firstMatch(line.content);
      if (match != null && match.group(1) == endTag) {
        nesting++;
        continue;
      }
    }

    if (nesting != 0) {
      throw AssertionError('Component block did not end: $endTag.');
    }

    childLines.removeLast();
    return childLines;
  }

  @override
  md.Node parse(md.BlockParser parser) {
    var match = pattern.firstMatch(parser.current.content);

    if (match == null) throw AssertionError('Block syntax should match pattern.');

    parser.advance();

    final tag = match.group(1)!;

    var value = match.group(2)!.trim();

    final isClosing = match.group(3) != null;

    late bool isSelfClosing;
    late String? content;
    late String? endTag;

    if (isClosing) {
      isSelfClosing = match.group(4) == '/';
      content = match.group(5);
      endTag = match.group(6);
    } else {
      while (!parser.isDone) {
        final line = parser.current.content;
        final lineMatch = closingPattern.firstMatch(line);

        parser.advance();

        if (lineMatch != null) {
          value += lineMatch.group(1) ?? '';
          isSelfClosing = lineMatch.group(2) == '/';
          content = lineMatch.group(3);
          endTag = lineMatch.group(4);
          break;
        } else {
          value += line;
        }
      }
    }

    var attributes = <MapEntry<String, String>>[];

    if (value.trim().isNotEmpty) {
      final attributeRegex = RegExp(r'\s*([a-zA-Z][a-zA-Z0-9_-]*)(="((?:[^"]|\\")*)")?');
      final matches = attributeRegex.allMatches(value.trim());

      attributes = matches.map((m) {
        final key = m.group(1)!;
        final value = m.group(3);
        return MapEntry(key, value ?? '');
      }).toList();
    }

    if (endTag != null) {
      assert(endTag == tag, 'Invalid component block.');
      var children = md.InlineParser(content ?? '', parser.document).parse();
      return md.Element(tag, children)..attributes.addEntries(attributes);
    }

    if (isSelfClosing) {
      assert(endTag == null, 'Invalid self-closing component block.');
      return md.Element(tag, null)..attributes.addEntries(attributes);
    }

    final childLines = parseChildLines(parser, tag);

    // Recursively parse the contents of the component.
    final children = md.BlockParser(childLines, parser.document).parseLines(parentSyntax: this);

    return md.Element(tag, children)..attributes.addEntries(attributes);
  }
}
