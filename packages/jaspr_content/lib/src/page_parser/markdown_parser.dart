import 'package:jaspr/server.dart' hide ComponentBuilder;
import 'package:markdown/markdown.dart' as md;

import '../page.dart';

import 'page_parser.dart';

md.Document _defaultDocumentBuilder(Page _) {
  return md.Document(
    blockSyntaxes: [ComponentBlockSyntax()],
    extensionSet: md.ExtensionSet.gitHubWeb,
  );
}

typedef DocumentBuilder = md.Document Function(Page page);

class MarkdownParser implements PageParser {
  MarkdownParser({
    this.documentBuilder = _defaultDocumentBuilder,
  });

  final DocumentBuilder documentBuilder;

  @override
  Set<String> get suffix => {'.md', '.mdx'};

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
        nodes.add(TextNode(node.text));
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
  RegExp get pattern => RegExp(r'^\s*<([A-Z][a-zA-Z]*)\s*([^>]*?)(/?)>(?:(.*)</([A-Z][a-zA-Z]*)>)?\s*$');

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

    final tag = match.group(1)!;
    final value = match.group(2)!.trim();
    final attributes = value.isNotEmpty
        ? value.split(RegExp(r'\s+')).map((e) {
            final parts = e.split('=');
            return MapEntry(parts[0], parts.length > 1 ? parts[1].substring(1, parts[1].length - 1) : '');
          })
        : <MapEntry<String, String>>[];
    final isSelfClosing = match.group(3) == '/';
    final content = match.group(4);
    final endTag = match.group(5);

    parser.advance();

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
