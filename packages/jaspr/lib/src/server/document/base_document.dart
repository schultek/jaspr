part of 'document.dart';

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

  @override
  State<Document> createState() => _BaseDocumentState();

  @override
  Element createElement() => _DocumentElement(this);
}

class _DocumentElement extends StatefulElement {
  _DocumentElement(Document super.component);

  @override
  Document get component => super.component as Document;

  @override
  void mount(Element? parent, Element? prevSibling) {
    super.mount(parent, prevSibling);
    (binding as DocumentBinding)._document = this;
  }
}

class _BaseDocumentState extends State<_BaseDocument> {
  final List<Element> _clientElements = [];

  void registerElement(Element element) {
    if (!(context.binding as ServerAppBinding).options.targets.containsKey(element.component.runtimeType)) {
      return;
    }

    print("CHECK ${element.component}");

    var isClientBoundary = true;
    element.visitAncestorElements((e) {
      return isClientBoundary = !_clientElements.contains(e);
    });

    if (!isClientBoundary) {
      return;
    }

    _clientElements.add(element);
  }

  List<RenderAdapter> get adapters => _clientElements.map((e) {
        var entry = (context.binding as ServerAppBinding).options.targets[_clientElements.first.component.runtimeType]!;
        return AnchorRenderAdapter(entry.name, entry.dataFor(e.component), e);
      }).toList();

  String? get scriptName {
    if (_clientElements.isEmpty) {
      return component.scriptName;
    }

    if (_clientElements.length == 1) {
      var entry = (context.binding as ServerAppBinding).options.targets[_clientElements.first.component.runtimeType]!;
      return '${entry.name}.client';
    }

    return 'main.clients';
  }

  String? get _normalizedBase {
    var base = component.base;
    if (base == null) return null;
    if (!base.startsWith('/')) base = '/$base';
    if (!base.endsWith('/')) base = '$base/';
    return base;
  }

  final _dataKey = GlobalKey();
  final _scriptKey = GlobalKey();

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'html',
      children: [
        DomComponent(
          tag: 'head',
          children: [
            if (component.charset != null) DomComponent(tag: 'meta', attributes: {'charset': component.charset!}),
            if (component.base != null) //
              DomComponent(tag: 'base', attributes: {'href': _normalizedBase!}),
            if (component.viewport != null)
              DomComponent(tag: 'meta', attributes: {'name': 'viewport', 'content': component.viewport!}),
            if (component.meta != null)
              for (var e in component.meta!.entries)
                DomComponent(tag: 'meta', attributes: {'name': e.key, 'content': e.value}),
            if (component.title != null) //
              DomComponent(tag: 'title', child: Text(component.title!)),
            if (component.styles != null) //
              Style(styles: component.styles!),
            ...component.head,
            DomComponent(key: _dataKey, tag: 'script', child: Text('', rawHtml: true)),
            DomComponent(key: _scriptKey, tag: 'script', attributes: {'defer': ''}),
          ],
        ),
        ComponentObserver(
          registerElement: registerElement,
          child: DomComponent(
            tag: 'body',
            child: component.body,
          ),
        ),
      ],
    );
  }

  @mustCallSuper
  void _prepareRender(Map<String, dynamic> syncState) {
    _setScript(scriptName);
    var jasprConfig = {
      if (syncState.isNotEmpty) 'sync': kDebugMode ? syncState : stateCodec.encode(syncState),
    };
    _setData('window.jaspr = ${JsonEncoder.withIndent(kDebugMode ? '  ' : null).convert(jasprConfig)};');
  }

  void _setScript(String? name) {
    var renderObject = (_scriptKey.currentContext as RenderObjectElement).renderObject as MarkupRenderObject;
    if (name == null) {
      renderObject.remove();
    } else {
      (renderObject.attributes ??= {})['src'] = '$name.dart.js';
    }
  }

  void _setData(String? source) {
    var renderObject = (_dataKey.currentContext as RenderObjectElement).renderObject as MarkupRenderObject;
    if (source == null) {
      renderObject.remove();
    } else {
      renderObject.children.first.text = source;
    }
  }
}
