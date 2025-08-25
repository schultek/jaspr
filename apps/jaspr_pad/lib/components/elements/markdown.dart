import 'dart:convert' as convert;

import 'package:jaspr/jaspr.dart' hide Document;
import 'package:markdown/markdown.dart' as md show Text, Element;
import 'package:markdown/markdown.dart' hide Text, Element;

@Import.onWeb('../../adapters/hljs.dart', show: [#highlightAll])
import 'markdown.imports.dart' as hljs;

class InlineBracketsColon extends InlineSyntax {
  InlineBracketsColon() : super(r'\[:\s?((?:.|\n)*?)\s?:\]');

  String htmlEscape(String text) => convert.htmlEscape.convert(text);

  @override
  bool onMatch(InlineParser parser, Match match) {
    final element = md.Element.text('code', htmlEscape(match[1]!));
    parser.addNode(element);
    return true;
  }
}

// TODO: [someCodeReference] should be converted to for example
// https://api.dartlang.org/apidocs/channels/stable/dartdoc-viewer/dart:core.someReference
// for now it gets converted <code>someCodeReference</code>
class InlineBrackets extends InlineSyntax {
  // This matches URL text in the documentation, with a negative filter
  // to detect if it is followed by a URL to prevent e.g.
  // [text] (http://www.example.com) getting turned into
  // <code>text</code> (http://www.example.com)
  InlineBrackets() : super(r'\[\s?((?:.|\n)*?)\s?\](?!\s?\()');

  String htmlEscape(String text) => convert.htmlEscape.convert(text);

  @override
  bool onMatch(InlineParser parser, Match match) {
    final element = md.Element.text('code', '<em>${htmlEscape(match[1]!)}</em>');
    parser.addNode(element);
    return true;
  }
}

class Markdown extends StatefulComponent {
  const Markdown({required this.markdown, this.blockSyntaxes, super.key});

  final String markdown;

  final Iterable<BlockSyntax>? blockSyntaxes;

  @override
  State<Markdown> createState() => _MarkdownState();
}

class _MarkdownState extends State<Markdown> {
  late Document document;
  late List<Node> nodes;

  @override
  void initState() {
    super.initState();
    parseMarkdown();
  }

  @override
  void didUpdateComponent(covariant Markdown oldComponent) {
    super.didUpdateComponent(oldComponent);
    if (oldComponent.markdown != component.markdown) {
      parseMarkdown();
    }
  }

  void parseMarkdown() {
    document = Document(
      blockSyntaxes: component.blockSyntaxes,
      inlineSyntaxes: [InlineBracketsColon(), InlineBrackets()],
      extensionSet: ExtensionSet.gitHubFlavored,
    );
    nodes = document.parseLines(component.markdown.replaceAll('\r\n', '\n').split('\n'));
  }

  @override
  Component build(BuildContext context) {
    if (kIsWeb) {
      context.binding.addPostFrameCallback(() {
        hljs.highlightAll();
      });
    }
    return Fragment(children: [
      ...buildMarkdown(nodes),
    ]);
  }

  Iterable<Component> buildMarkdown(Iterable<Node> nodes) sync* {
    for (var node in nodes) {
      if (node is md.Text) {
        yield span([raw(node.text)]);
      } else if (node is md.Element) {
        yield DomComponent(
          tag: node.tag,
          id: node.generatedId,
          attributes: node.attributes,
          children: node.children != null ? buildMarkdown(node.children!).toList() : null,
        );
      }
    }
  }
}
