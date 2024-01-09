part of 'document.dart';

class _BaseDocument extends Document {
  const _BaseDocument({
    this.title,
    this.base,
    this.charset = 'utf-8',
    this.viewport = 'width=device-width, initial-scale=1.0',
    this.meta,
    this.styles,

    /// List of StyleSheet Components
    this.styleSheets = const [],
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

  /// List of CSS Links use StyleSheet Component
  final List<StyleSheet> styleSheets;
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
  final Map<Element, ComponentEntry> _registryElements = {};

  void registerElement(Element element) {
    if (element.component is ComponentEntryMixin) {
      var entry = (element.component as ComponentEntryMixin).entry;
      _registryElements[element] = entry;
    }
  }

  Map<String, dynamic> _getExtendedConfig() {
    return {
      'comp': [
        for (var e in _registryElements.entries)
          {
            'id': getIdFor(e.key),
            'name': e.value.name,
            if (e.value.params != null)
              'params': kDebugMode
                  ? e.value.params
                  : stateCodec.encode(e.value.params),
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

  RenderElement? _script;
  RenderElement? _data;

  String? get _normalizedBase {
    var base = component.base;
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
            if (component.charset != null)
              DomComponent(
                  tag: 'meta', attributes: {'charset': component.charset!}),
            if (component.base != null) //
              DomComponent(tag: 'base', attributes: {'href': _normalizedBase!}),
            if (component.viewport != null)
              DomComponent(tag: 'meta', attributes: {
                'name': 'viewport',
                'content': component.viewport!
              }),
            if (component.meta != null)
              for (var e in component.meta!.entries)
                DomComponent(
                    tag: 'meta',
                    attributes: {'name': e.key, 'content': e.value}),
            if (component.title != null) //
              DomComponent(tag: 'title', child: Text(component.title!)),
            if (component.styles != null) //
              Style(styles: component.styles!),
            ...component.styleSheets,
            ...component.head,
            FindChildNode(
              onNodeRendered: (element) {
                _data = element;
              },
              child:
                  DomComponent(tag: 'script', child: Text('', rawHtml: true)),
            ),
            FindChildNode(
              onNodeRendered: (element) {
                _script = element;
              },
              child: DomComponent(tag: 'script', attributes: {'defer': ''}),
            ),
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
      if (syncState.isNotEmpty)
        'sync': kDebugMode ? syncState : stateCodec.encode(syncState),
      ..._getExtendedConfig(),
    };
    _setData(
        'window.jaspr = ${JsonEncoder.withIndent(kDebugMode ? '  ' : null).convert(jasprConfig)};');
  }

  void _setScript(String? name) {
    if (_script != null) {
      if (name == null) {
        _script!.renderer.removeChild(_script!.parentNode!, _script!);
      } else {
        (_script!.data.attributes ??= {})['src'] = '$name.dart.js';
      }
    }
  }

  void _setData(String? source) {
    if (_data != null) {
      if (source == null) {
        _data!.renderer.removeChild(_data!.parentNode!, _data!);
      } else {
        _data!.data.children.first.data.text = source;
      }
    }
  }

  String getIdFor(Element element) {
    var container = element.parentNode;
    if (container == null) {
      return 'body';
    }

    String selector;

    if (container.data.tag == 'body') {
      selector = 'body';
    } else if (container.data.id != null) {
      selector = '#${container.data.id}';
    } else {
      var id = _randomId();
      container.data.id = id;
      selector = '#$id';
    }

    Element? prevElem = element.prevAncestorSibling;
    while (prevElem != null && prevElem.lastNode == null) {
      prevElem = prevElem.prevAncestorSibling;
    }

    var firstChild = prevElem?.lastNode;
    var lastChild = element.lastNode;

    var firstIndex = (firstChild != null
            ? container.data.children.indexOf(firstChild)
            : -1) +
        1;
    var lastIndex =
        (lastChild != null ? container.data.children.indexOf(lastChild) : -1) +
            1;

    if (firstIndex > lastIndex) {
      lastIndex = firstIndex;
    }

    return '$selector($firstIndex:$lastIndex)';
  }
}
