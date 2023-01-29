part of document;

abstract class _ManualDocument extends Document {
  const _ManualDocument({
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
  State<Document> createState() => _ManualDocumentState();

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
    DocumentBinding.instance?._document = this;
  }
}

class _ManualDocumentState extends State<_ManualDocument> {
  RenderElement? _script;
  RenderElement? _dataScript;

  String? get _normalizedBase {
    var base = component.base;
    if (base == null) return null;
    if (!base.startsWith('/')) base = '/$base';
    if (!base.endsWith('/')) base = '$base/';
    return base;
  }

  void onElementRegistered(Element element, ComponentEntry entry) {}

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
            FindChildNode(
              onNodeRendered: (element) {
                _dataScript = element;
              },
              child: DomComponent(tag: 'script', child: Text('', rawHtml: true)),
            ),
            if (component.scriptName != null)
              FindChildNode(
                onNodeRendered: (element) {
                  _script = element;
                },
                child: DomComponent(tag: 'script', attributes: {'defer': '', 'src': '${component.scriptName}.dart.js'}),
              ),
          ],
        ),
        ComponentObserver(
          onElementRegistered: onElementRegistered,
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
    var jasprConfig = {
      if (syncState.isNotEmpty) 'sync': kDebugMode ? syncState : stateCodec.encode(syncState),
      ..._getExtendedConfig(),
    };
    _setState('window.jaspr = ${JsonEncoder.withIndent(kDebugMode ? '  ' : null).convert(jasprConfig)};');
  }

  @protected
  Map<String, dynamic> _getExtendedConfig() => {};

  void _setScript(String? name) {
    if (_script != null) {
      if (name == null) {
        _script!.renderer.removeChild(_script!.parentNode!, _script!);
      } else {
        (_script!.data.attributes ??= {})['src'] = '$name.dart.js';
      }
    }
  }

  void _setState(String? source) {
    if (_dataScript != null) {
      if (source == null) {
        _dataScript!.renderer.removeChild(_dataScript!.parentNode!, _dataScript!);
      } else {
        _dataScript!.data.children.first.data.text = source;
      }
    }
  }
}

class ComponentObserver extends ObserverComponent {
  ComponentObserver({required this.onElementRegistered, required super.child});

  final void Function(Element, ComponentEntry) onElementRegistered;

  @override
  ObserverElement createElement() => ComponentObserverElement(this);
}

class ComponentObserverElement extends ObserverElement {
  ComponentObserverElement(super.component);

  @override
  ComponentObserver get component => super.component as ComponentObserver;

  @override
  void willRebuildElement(Element element) {}

  @override
  void didRebuildElement(Element element) {
    var entry = DocumentBinding.instance!._registerElement(element);
    if (entry != null) {
      component.onElementRegistered(element, entry);
    }
  }

  @override
  void didUnmountElement(Element element) {}
}
