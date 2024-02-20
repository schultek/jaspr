library document;

import 'dart:async';

import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';

import '../../server.dart';
import 'child_nodes.dart';
import 'markup_render_object.dart';

export '../components/style.dart' hide Style;

// only allow a single document
const _documentKey = GlobalKey();

abstract class Document extends StatelessComponent {
  const Document._() : super(key: _documentKey);

  const factory Document({
    String? title,
    String? base,
    String? charset,
    String? viewport,
    Map<String, String>? meta,
    List<StyleRule>? styles,
    String? scriptName,
    List<Component> head,
    required Component body,
  }) = _BaseDocument;

  const factory Document.file({
    String name,
    String attachTo,
    required Component child,
  }) = _FileDocument;
}

class _BaseDocument extends Document {
  const _BaseDocument({
    this.title,
    this.base,
    this.charset = 'utf-8',
    this.viewport = 'width=device-width, initial-scale=1.0',
    this.meta,
    this.styles,
    this.scriptName,
    this.head = const [],
    required this.body,
  }) : super._();

  final String? title;
  final String? base;
  final String? charset;
  final String? viewport;
  final Map<String, String>? meta;
  final List<StyleRule>? styles;
  final String? scriptName;
  final List<Component> head;
  final Component body;

  String? get _normalizedBase {
    var base = this.base;
    if (base == null) return null;
    if (!base.startsWith('/')) base = '/$base';
    if (!base.endsWith('/')) base = '$base/';
    return base;
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'html',
      children: [
        DomComponent(
          tag: 'head',
          children: [
            if (charset != null) DomComponent(tag: 'meta', attributes: {'charset': charset!}),
            if (base != null) //
              DomComponent(tag: 'base', attributes: {'href': _normalizedBase!}),
            if (viewport != null) DomComponent(tag: 'meta', attributes: {'name': 'viewport', 'content': viewport!}),
            if (meta != null)
              for (var e in meta!.entries) DomComponent(tag: 'meta', attributes: {'name': e.key, 'content': e.value}),
            if (title != null) //
              DomComponent(tag: 'title', child: Text(title!)),
            if (styles != null) //
              Style(styles: styles!),
            ...head,
            if (scriptName != null) //
              script([], src: '$scriptName.dart.js', defer: true),
          ],
        ),
        DomComponent(tag: 'body', child: body),
      ],
    );
  }
}

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
  void applyBoundary(ChildListRange range) {
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
        n.children.insertNodeAfter(range);
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
