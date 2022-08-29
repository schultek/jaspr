import 'dart:isolate';

import 'package:html/parser.dart';

import '../../server.dart';

// only allow a single document
const _documentKey = GlobalKey();

abstract class Document extends StatefulComponent {
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

  const factory Document.app({
    String? title,
    String? base,
    String? charset,
    String? viewport,
    Map<String, String>? meta,
    List<StyleRule>? styles,
    List<Component> head,
    required Component body,
  }) = _AppDocument;

  const factory Document.file({
    String name,
    String attachTo,
    required Component child,
  }) = _FileDocument;

  const factory Document.islands({
    String? title,
    String? base,
    String? charset,
    String? viewport,
    Map<String, String>? meta,
    List<StyleRule>? styles,
    List<Component> head,
    required Component body,
  }) = _IslandsDocument;
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

class _BaseDocument extends _ManualDocument {
  const _BaseDocument({
    super.title,
    super.base,
    super.charset,
    super.viewport,
    super.meta,
    super.styles,
    super.scriptName = 'main',
    super.head,
    required super.body,
  });
}

class _AppDocument extends _ManualDocument {
  const _AppDocument({
    super.title,
    super.base,
    super.charset,
    super.viewport,
    super.meta,
    super.styles,
    super.head,
    required super.body,
  }) : super(scriptName: r'__$auto$__');
}

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

class _ManualDocumentState extends State<_ManualDocument> {
  RenderElement? _body;
  RenderElement? _script;

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
            if (component.scriptName != null)
              FindChildNode(
                onNodeFound: (element) {
                  _script = element;
                },
                child: DomComponent(tag: 'script', attributes: {'defer': '', 'src': '${component.scriptName}.dart.js'}),
              ),
          ],
        ),
        FindChildNode(
          onNodeFound: (element) {
            _body = element;
          },
          child: ComponentObserver(
            child: DomComponent(
              tag: 'body',
              child: component.body,
            ),
          ),
        ),
      ],
    );
  }

  void _setData(String injectState) {
    if (_body != null) {
      (_body!.data.attributes ??= {})['state-data'] = injectState;
    }
  }

  void _setScript(String? name) {
    if (_script != null) {
      if (name == null) {
        _script!.renderer.removeChild(_script!.parentNode, _script!);
      } else {
        (_script!.data.attributes ??= {})['src'] = '$name.g.dart.js';
      }
    }
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
  State<Document> createState() => _FileDocumentState();

  @override
  Element createElement() => _DocumentElement(this);
}

class _FileDocumentState extends State<_FileDocument> {
  @override
  void initState() {
    super.initState();
    DocumentBinding.instance?._loadFile(component.name);
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield component.child;
  }
}

class _IslandsDocument extends _ManualDocument {
  const _IslandsDocument({
    super.title,
    super.base,
    super.charset,
    super.viewport,
    super.meta,
    super.styles,
    super.head,
    required super.body,
  }) : super(scriptName: 'main.islands');
}

class ComponentObserver extends ObserverComponent {
  ComponentObserver({required super.child});

  @override
  ObserverElement createElement() => ComponentObserverElement(this);
}

class ComponentObserverElement extends ObserverElement {
  ComponentObserverElement(super.component);

  @override
  void willRebuildElement(Element element) {}

  @override
  void didRebuildElement(Element element) {
    if (DocumentBinding.instance!._registryData.containsKey(element.component.runtimeType)) {
      DocumentBinding.instance!._registerElement(element);
    }
  }

  @override
  void didUnmountElement(Element element) {}
}

mixin DocumentBinding on BindingBase {
  @override
  void initInstances() {
    super.initInstances();
    _instance = this;
  }

  static DocumentBinding? _instance;
  static DocumentBinding? get instance => _instance!;

  late SendPort _sendPort;
  late ComponentRegistryData _registryData;
  ReceivePort? _receivePort;

  void setSendPort(SendPort sendPort) {
    _sendPort = sendPort;
  }

  _DocumentElement? _document;
  Future<String>? _fileRequest;

  void _loadFile(String name) {
    _receivePort ??= ReceivePort();
    _sendPort.send(LoadFileRequest(name, _receivePort!.sendPort));
    _fileRequest = _receivePort!.first.then((value) => value);
  }

  void setRegistryData(ComponentRegistryData registryData) {
    _registryData = registryData;
  }

  final Set<Element> _registryElements = {};

  void _registerElement(Element element) {
    _registryElements.add(element);
  }

  Future<String> renderDocument(String injectState, MarkupDomRenderer renderer) async {
    var state = _document?.state;
    if (state is _ManualDocumentState) {
      state._setData(injectState);

      if (state.component is _AppDocument) {
        String? componentName;
        if (_registryElements.isEmpty) {
          print("[WARNING] Used Document.app() but no app component was provided.");
        } else {
          if (_registryElements.length > 1) {
            print("[WARNING] Used Document.app() but multiple app components were provided.");
          }
          componentName = _registryData[_registryElements.first.component.runtimeType]!.name;
        }
        state._setScript(componentName);
      }
    }

    var content = renderer.renderHtml();

    if (state is _FileDocumentState && _fileRequest != null) {
      var fileContent = await _fileRequest!;

      var document = parse(fileContent);
      var appElement = document.querySelector(state.component.attachTo)!;
      appElement.innerHtml = content;

      document.body!.attributes['state-data'] = injectState;
      content = document.outerHtml;
    }

    return content;
  }
}

class LoadFileRequest {
  final String name;
  final SendPort sendPort;

  LoadFileRequest(this.name, this.sendPort);
}
