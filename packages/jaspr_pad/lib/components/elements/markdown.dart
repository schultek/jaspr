import 'dart:convert' as convert;

import 'package:jaspr/jaspr.dart' hide Element, Text;
import 'package:markdown/markdown.dart';

import '../../adapters/hljs.dart' as hljs;

class InlineBracketsColon extends InlineSyntax {
  InlineBracketsColon() : super(r'\[:\s?((?:.|\n)*?)\s?:\]');

  String htmlEscape(String text) => convert.htmlEscape.convert(text);

  @override
  bool onMatch(InlineParser parser, Match match) {
    final element = Element.text('code', htmlEscape(match[1]!));
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
    final element = Element.text('code', '<em>${htmlEscape(match[1]!)}</em>');
    parser.addNode(element);
    return true;
  }
}

class Markdown extends StatefulComponent {
  const Markdown({required this.markdown, this.blockSyntaxes, Key? key}) : super(key: key);

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
  Iterable<Component> build(BuildContext context) sync* {
    yield MarkdownRenderer(nodes);
  }
}

class MarkdownRenderer extends CustomRenderComponent {
  MarkdownRenderer(this.nodes);

  final List<Node> nodes;

  @override
  void render(DomBuilder b) {
    MarkdownDomVisitor(b).render(nodes);
    if (kIsWeb) {
      hljs.highlightAll();
    }
  }
}

class MarkdownDomVisitor implements NodeVisitor {
  MarkdownDomVisitor(this.builder);

  final DomBuilder builder;

  void render(List<Node> nodes) {
    for (var node in nodes) {
      node.accept(this);
    }
  }

  @override
  void visitText(Text text) {
    builder.open('span');
    builder.innerHtml(text.text);
    builder.close();
  }

  @override
  bool visitElementBefore(Element element) {
    builder.open(
      element.tag,
      attributes: element.attributes,
      id: element.generatedId,
    );
    return true;
  }

  @override
  void visitElementAfter(Element element) {
    builder.close(tag: element.tag);
  }
}
