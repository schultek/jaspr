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
  _DocumentElement(Document component) : super(component);

  @override
  Document get component => super.component as Document;

  @override
  void mount(Element? parent, Element? prevSibling) {
    super.mount(parent, prevSibling);
    (binding as DocumentBinding)._document = this;
  }
}

class _BaseDocumentState extends State<_BaseDocument> {
  final Map<Element, ClientTarget> _registryElements = {};

  void registerElement(Element element) {
    var entry = (context.binding as ServerAppBinding).options.targets[element.component.runtimeType];
    if (entry != null) {
      _registryElements[element] = entry;
    }
  }

  Map<String, dynamic> _getExtendedConfig() {
    return {
      'comp': [
        for (var e in _registryElements.entries)
          {
            'id': getIdFor(e.key),
            ...e.value.encode(e.key.component),
          }
      ]
    };
  }

  String? get scriptName {
    var comps = _registryElements.entries.toList();

    if (comps.isEmpty) {
      return component.scriptName;
    }

    if (comps.length == 1) {
      return '${comps.first.value.name}.client';
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
      ..._getExtendedConfig(),
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

  String getIdFor(Element element) {
    var container = element.parentRenderObjectElement?.renderObject as MarkupRenderObject?;
    if (container == null) {
      return 'body';
    }

    String selector;

    if (container.tag == 'body') {
      selector = 'body';
    } else if (container.id != null) {
      selector = '#${container.id}';
    } else {
      var id = _randomId();
      container.id = id;
      selector = '#$id';
    }

    Element? prevElem = element.prevAncestorSibling;
    while (prevElem != null && prevElem.lastRenderObjectElement == null) {
      prevElem = prevElem.prevAncestorSibling;
    }

    var firstChild = prevElem?.lastRenderObjectElement?.renderObject as MarkupRenderObject?;
    var lastChild = element.lastRenderObjectElement?.renderObject as MarkupRenderObject?;

    var firstIndex = (firstChild != null ? container.children.indexOf(firstChild) : -1) + 1;
    var lastIndex = (lastChild != null ? container.children.indexOf(lastChild) : -1) + 1;

    if (firstIndex > lastIndex) {
      lastIndex = firstIndex;
    }

    return '$selector($firstIndex:$lastIndex)';
  }
}
