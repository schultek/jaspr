part of 'document.dart';

class _TemplateDocument extends Document {
  const _TemplateDocument({
    this.name = 'index',
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
  Element createElement() => _TemplateDocumentElement(this);
}

class _TemplateDocumentElement extends StatelessElement {
  _TemplateDocumentElement(_TemplateDocument super.component);

  Future<String?>? _templateFuture;

  @override
  Iterable<Component> build() {
    (binding as ServerAppBinding).addRenderAdapter(_TemplateDocumentAdapter(this));
    _templateFuture ??=
        (binding as ServerAppBinding).loadFile('${(component as _TemplateDocument).name}.template.html');
    return super.build();
  }
}

class _TemplateDocumentAdapter extends ElementBoundaryAdapter {
  _TemplateDocumentAdapter(super.element);

  late String template;

  @override
  FutureOr<void> prepare() async {
    var template = await (element as _TemplateDocumentElement)._templateFuture!;
    if (template == null) {
      throw TemplateNotFoundError((element.component as _TemplateDocument).name);
    }
    this.template = template;
    return super.prepare();
  }

  @override
  void processBoundary(ChildListRange range) {
    var curr = range.start.prev!;
    range.remove();
    var document = parse(template);
    var target = document.querySelector((element.component as _TemplateDocument).attachTo)!;

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

class TemplateNotFoundError extends Error {
  TemplateNotFoundError(this.name);

  final String name;

  @override
  String toString() {
    return 'TemplateNotFoundError: The template "$name.template.html" was not found.';
  }
}
