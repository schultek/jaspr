part of 'document.dart';

class _FileDocument extends Document {
  const _FileDocument({
    this.name = 'index.html',
    this.attachTo = 'body',
    required this.child,
  }) : super._();

  final String name;
  final String attachTo;
  final Component child;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield child;
  }

  @override
  Element createElement() => _FileDocumentElement(this);
}

class _FileDocumentElement extends StatelessElement {
  _FileDocumentElement(_FileDocument super.component);

  Future<String>? _fileFuture;

  @override
  void mount(Element? parent, Element? prevSibling) {
    super.mount(parent, prevSibling);
    (binding as ServerAppBinding).addRenderAdapter(_FileDocumentAdapter(this));
    _fileFuture ??= (binding as ServerAppBinding).loadFile((component as _FileDocument).name);
  }
}

class _FileDocumentAdapter extends ElementBoundaryAdapter {
  _FileDocumentAdapter(super.element);

  @override
  Future<void> processBoundary(MarkupRenderObject parent, int start, int end) async {
    var children = parent.children.sublist(start, end);
    parent.children.removeRange(start, end);
    var file = await (element as _FileDocumentElement)._fileFuture!;

    var document = parse(file);
    var target = document.querySelector((element.component as _FileDocument).attachTo)!;

    MarkupRenderObject createTree(dom.Node node) {
      var n = element.parentRenderObjectElement!.renderObject.createChildRenderObject() as MarkupRenderObject;

      if (node is dom.Text) {
        n.updateText(node.text);
      } else if (node is dom.Comment) {
        n.updateText('<!--${node.data}-->', true);
      } else if (node is dom.Element) {
        n.updateElement(node.localName!, node.id, node.className, null, node.attributes.cast(), null);
      } else if (node is dom.DocumentType) {
        n.updateText(node.toString(), true);
      } else {
        throw UnsupportedError('Unsupported node type ${node.nodeType}');
      }

      if (node == target) {
        n.children = children;
      } else {
        n.children = node.nodes.map(createTree).toList();
      }
      return n;
    }

    parent.children.insertAll(start, document.nodes.map(createTree));
  }
}
