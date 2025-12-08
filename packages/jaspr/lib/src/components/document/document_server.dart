import 'dart:async';

import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';

import '/dom.dart';
import '/server.dart';
import '/src/server/adapters/document_adapter.dart';

abstract class Document implements Component {
  /// Sets up a basic document structure at the root of your app and renders the main `<html>`, `<head>` and `<body>` tags.
  ///
  /// The `title` parameter is rendered as the `<title>` element.
  /// The `lang` parameter is set as the `lang` attribute on the `<html>` element.
  /// The `base` parameter is rendered as the `<base href=...>` element and defaults to `'/'`.
  /// The `charset`, `viewport` and `meta` values are rendered as `<meta>` elements in `<head>`.
  /// The `styles` parameter is rendered to css in a `<style>` element inside `<head>`.
  /// The `head` components are also rendered inside `<head>`.
  ///
  /// The `body` component is rendered inside the `<body>` element.
  const factory Document({
    String? title,
    String? lang,
    String? base,
    String? charset,
    String? viewport,
    Map<String, String> meta,
    List<StyleRule> styles,
    List<Component> head,
    required Component body,
  }) = BaseDocument;

  /// Loads an external `.template.html` file from the filesystem and attaches the provided
  /// child component to that template.
  ///
  /// The `name` (default 'index') defines which template file to load: `web/<name>.template.html`.
  /// The `attachTo`(default 'body') defines where to attach the child component in the loaded template.
  const factory Document.template({String name, String attachTo, required Component child}) = TemplateDocument;

  /// Attaches a set of attributes to the `<html>` element.
  ///
  /// This can be used at any point in the component tree and is supported both on the
  /// server during pre-rendering and on the client.
  ///
  /// Can be used multiple times in an application where deeper or latter mounted
  /// components will override duplicate attributes from other `.html()` components.
  const factory Document.html({Map<String, String>? attributes, Key? key}) = AttachDocument.html;

  /// Renders metadata and other elements inside the `<head>` of the document.
  ///
  /// Any children are pulled out of the normal rendering tree of the application and rendered instead
  /// inside a special section of the `<head>` element of the document. This is supported both on the
  /// server during pre-rendering and on the client.
  ///
  /// Can be used multiple times in an application where deeper or latter mounted
  /// components will override duplicate elements from other `.head()` components.
  ///
  /// ```dart
  /// Parent(children: [
  ///   Document.head(
  ///     title: "My Title",
  ///     meta: {"description": "My Page Description"}
  ///   ),
  ///   Child(children: [
  ///     Document.head(
  ///       title: "Nested Title"
  ///     ),
  ///   ]),
  /// ]),
  /// ```
  ///
  /// The above configuration of components will result in these elements inside `<head>`:
  ///
  /// ```html
  /// <head>
  ///   <title>Nested Title</title>
  ///   <meta name="description" content="My Page Description">
  /// </head>
  /// ```
  ///
  /// Note that 'deeper or latter' here does not result in a true DFS ordering. Components that are mounted
  /// deeper but prior will override latter but shallower components.
  ///
  /// Elements rendered by nested `.head()` are overridden using the following system:
  /// - elements with an `id` override other elements with the same `id`
  /// - `<title>` and `<base>` elements override other `<title>` or `<base>` elements respectively
  /// - `<meta>` elements override other `<meta>` elements with the same `name`
  const factory Document.head({String? title, Map<String, String>? meta, List<Component>? children, Key? key}) =
      HeadDocument;

  /// Attaches a set of attributes to the `<body>` element.
  ///
  /// This can be used at any point in the component tree and is supported both on the
  /// server during pre-rendering and on the client.
  ///
  /// Can be used multiple times in an application where deeper or latter mounted
  /// components will override duplicate attributes from other `.body()` components.
  const factory Document.body({Map<String, String>? attributes, Key? key}) = AttachDocument.body;
}

// Only allow a single Document.
const _documentKey = _DocumentKey();

class _DocumentKey extends GlobalKey {
  const _DocumentKey() : super.constructor();
}

class BaseDocument extends StatelessComponent implements Document {
  const BaseDocument({
    this.title,
    this.lang,
    this.base = '/',
    this.charset = 'utf-8',
    this.viewport = 'width=device-width, initial-scale=1.0',
    this.meta = const {},
    this.styles = const [],
    this.head = const [],
    required this.body,
  }) : super(key: _documentKey);

  final String? title;
  final String? lang;
  final String? base;
  final String? charset;
  final String? viewport;
  final Map<String, String> meta;
  final List<StyleRule> styles;
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
  Component build(BuildContext context) {
    return Component.element(
      tag: 'html',
      attributes: {'lang': ?lang},
      children: [
        Component.element(
          tag: 'head',
          children: [
            if (base != null) Component.element(tag: 'base', attributes: {'href': _normalizedBase!}),
            if (charset != null) Component.element(tag: 'meta', attributes: {'charset': charset!}),
            HeadDocument(title: title, meta: {'viewport': ?viewport, ...meta}),
            if (styles.isNotEmpty) //
              Style(styles: styles),
            ...head,
          ],
        ),
        Component.element(tag: 'body', children: [body]),
      ],
    );
  }
}

class TemplateDocument extends StatelessComponent implements Document {
  const TemplateDocument({this.name = 'index', this.attachTo = 'body', required this.child}) : super(key: _documentKey);

  final String name;
  final String attachTo;
  final Component child;

  @override
  Component build(BuildContext context) {
    return child;
  }

  @override
  Element createElement() => _TemplateDocumentElement(this);
}

class _TemplateDocumentElement extends StatelessElement {
  _TemplateDocumentElement(TemplateDocument super.component);

  Future<String?>? _templateFuture;

  @override
  Component build() {
    (binding as ServerAppBinding).addRenderAdapter(TemplateDocumentAdapter(this));
    _templateFuture ??= (binding as ServerAppBinding).loadFile('${(component as TemplateDocument).name}.template.html');
    return super.build();
  }
}

class TemplateDocumentAdapter extends ElementBoundaryAdapter {
  TemplateDocumentAdapter(super.element);

  late String template;

  @override
  FutureOr<void> prepare() async {
    final template = await (element as _TemplateDocumentElement)._templateFuture!;
    if (template == null) {
      throw TemplateNotFoundError((element.component as TemplateDocument).name);
    }
    this.template = template;
    return super.prepare();
  }

  @override
  void applyBoundary(ChildListRange range) {
    var curr = range.start.prev!;
    range.remove();
    final document = parse(template);
    final target = document.querySelector((element.component as TemplateDocument).attachTo)!;

    final MarkupRenderObject parent = element.parentRenderObjectElement!.renderObject as MarkupRenderObject;

    MarkupRenderObject? createTree(dom.Node node) {
      MarkupRenderObject n;

      if (node is dom.Text) {
        if (node.text.trim().isEmpty) {
          return null;
        }
        n = parent.createChildRenderText(node.text.trim(), true);
      } else if (node is dom.Comment) {
        n = parent.createChildRenderText('<!--${node.data}-->', true);
      } else if (node is dom.Element) {
        n = parent.createChildRenderElement(node.localName!)..update(null, null, null, node.attributes.cast(), null);
      } else if (node is dom.DocumentType) {
        n = parent.createChildRenderText(node.toString(), true);
      } else {
        throw UnsupportedError('Unsupported node type ${node.nodeType}');
      }

      if (node == target) {
        n.children.insertNodeAfter(range);
      } else {
        for (final c in node.nodes) {
          final o = createTree(c);
          if (o != null) {
            n.children.insertBefore(o);
          }
        }
      }

      return n;
    }

    for (final n in document.nodes) {
      final o = createTree(n);
      if (o != null) {
        final next = ChildNodeData(o);
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

class HeadDocument extends StatelessComponent implements Document {
  const HeadDocument({this.title, this.meta, this.children, super.key});

  final String? title;
  final Map<String, String>? meta;
  final List<Component>? children;

  @override
  Component build(BuildContext context) {
    return AttachDocument(
      target: 'head',
      attributes: null,
      children: [
        if (title != null) Component.element(tag: 'title', children: [Component.text(title!)]),
        if (meta != null)
          for (final e in meta!.entries)
            Component.element(tag: 'meta', attributes: {'name': e.key, 'content': e.value}),
        ...?children,
      ],
    );
  }
}

class AttachDocument extends StatelessComponent implements Document {
  const AttachDocument.html({this.attributes, super.key}) : target = 'html', children = null;
  const AttachDocument.body({this.attributes, super.key}) : target = 'body', children = null;
  const AttachDocument({required this.target, this.attributes, this.children});

  final String target;
  final Map<String, String>? attributes;
  final List<Component>? children;

  @override
  Component build(BuildContext context) {
    AttachAdapter.register(context, this);
    return Component.fragment(children ?? []);
  }
}

final Expando<AttachAdapter> _attach = Expando();

class AttachAdapter extends RenderAdapter with DocumentStructureMixin {
  static void register(BuildContext context, AttachDocument item) {
    if (context.binding is! ServerAppBinding) {
      // Return early in component tests.
      return;
    }

    final binding = (context.binding as ServerAppBinding);
    final adapter = _attach[binding] ??= AttachAdapter();
    binding.addRenderAdapter(adapter);

    final entry = adapter.entries[item.target] ??= (attributes: {}, children: []);
    if (item.attributes != null) {
      entry.attributes.addAll(item.attributes!);
    }
    if (item.children != null) {
      binding.addRenderAdapter(_AttachChildrenAdapter(adapter, item.target, context as Element));
    }
  }

  Map<String, ({Map<String, String> attributes, List<(ChildListRange, int)> children})> entries = {};

  @override
  void apply(MarkupRenderObject root) {
    final (html, head, body) = createDocumentStructure(root);

    String? keyFor(MarkupRenderObject n) {
      return switch (n) {
        MarkupRenderElement(id: final String id) when id.isNotEmpty => id,
        MarkupRenderElement(tag: 'title' || 'base') => '__${n.tag}',
        MarkupRenderElement(tag: 'meta', attributes: {'name': final String name}) => '__meta:$name',
        _ => null,
      };
    }

    for (final MapEntry(:key, :value) in entries.entries) {
      final target = switch (key) {
        'html' => html,
        'head' => head,
        'body' => body,
        _ => throw StateError('Unknown target $key'),
      };

      if (value.attributes.isNotEmpty) {
        (target.attributes ??= {}).addAll(value.attributes);
      }

      if (value.children.isNotEmpty) {
        target.children.insertBefore(target.createChildRenderText(r'<!--$-->', true));

        final List<MarkupRenderObject> nodes = [];
        final Map<String, (int, int)> indices = {};

        void visitRenderObject(MarkupRenderObject o, int depth) {
          if (o is MarkupRenderFragment) {
            for (final child in o.children) {
              visitRenderObject(child, depth);
            }
            return;
          }

          final key = keyFor(o);
          if (key == null) {
            nodes.add(o);
            return;
          }
          final index = indices[key];
          if (index == null) {
            nodes.add(o);
            indices[key] = (nodes.length - 1, depth);
          }
          if (index != null && depth >= index.$2) {
            nodes[index.$1] = o;
          }
        }

        for (final e in value.children) {
          e.$1.remove();
          for (final n in e.$1) {
            visitRenderObject(n, e.$2);
          }
        }

        for (final n in nodes) {
          target.children.insertBefore(n);
        }

        target.children.insertBefore(target.createChildRenderText(r'<!--/-->', true));
      }
    }
  }
}

class _AttachChildrenAdapter extends ElementBoundaryAdapter {
  _AttachChildrenAdapter(this.adapter, this.target, super.element);

  final AttachAdapter adapter;
  final String target;

  @override
  void prepareBoundary(ChildListRange range) {
    adapter.entries[target]!.children.add((range, element.depth));
  }
}
