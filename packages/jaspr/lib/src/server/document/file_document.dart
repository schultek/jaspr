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
  Iterable<Component> build() {
    (binding as ServerAppBinding).addRenderAdapter(_FileDocumentAdapter(this));
    _fileFuture ??= (binding as ServerAppBinding).loadFile((component as _FileDocument).name);
    return super.build();
  }
}

class _FileDocumentAdapter extends ElementBoundaryAdapter {
  _FileDocumentAdapter(super.element);

  late String file;

  @override
  FutureOr<void> prepare() async {
    file = await (element as _FileDocumentElement)._fileFuture!;
    return super.prepare();
  }

  @override
  void processBoundary(ChildListRange range) {
    var curr = range.start.prev!;
    range.remove();
    var document = parse(file);
    var target = document.querySelector((element.component as _FileDocument).attachTo)!;

    MarkupRenderObject? createTree(dom.Node node) {
      var n = element.parentRenderObjectElement!.renderObject.createChildRenderObject() as MarkupRenderObject;

      if (node is dom.Text) {
        if (node.text.trim().isEmpty) {
          return null;
        }
        n.updateText(node.text.trim(), true);
      } else if (node is dom.Comment) {
        n.updateText('<!--${node.data}-->', true);
      } else if (node is dom.Element) {
        n.updateElement(node.localName!, null, null, null, node.attributes.cast(), null);
      } else if (node is dom.DocumentType) {
        n.updateText(node.toString(), true);
      } else {
        throw UnsupportedError('Unsupported node type ${node.nodeType}');
      }

      if (node == target) {
        n.children.insertRangeAfter(range);
      } else {
        for (var c in node.nodes) {
          var o = createTree(c);
          if (o != null) {
            n.children.insertBefore(o);
          }
        }
      }

      return n;
    }

    for (var n in document.nodes) {
      var o = createTree(n);
      if (o != null) {
        var next = ChildNodeData(o);
        curr.insertNext(next);
        curr = next;
      }
    }
  }
}
