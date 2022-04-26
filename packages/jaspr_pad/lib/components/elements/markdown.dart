import 'package:jaspr/jaspr.dart' hide Element, Text;
import 'package:markdown/markdown.dart';

class Markdown extends StatefulComponent {
  const Markdown({required this.markdown, this.blockSyntaxes, this.inlineSyntaxes, Key? key}) : super(key: key);

  final String markdown;

  final Iterable<BlockSyntax>? blockSyntaxes;
  final Iterable<InlineSyntax>? inlineSyntaxes;

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
      inlineSyntaxes: component.inlineSyntaxes,
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
