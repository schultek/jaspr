import 'dart:isolate';

import 'package:html/parser.dart';

import '../../server.dart';
import '../../styles.dart';

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
            DomComponent(tag: 'meta', attributes: {'charset': 'utf-8'}),
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
              DomComponent(tag: 'script', attributes: {'defer': '', 'src': '${component.scriptName}.dart.js'}),
          ],
        ),
        FindChildNode(
          onNodeFound: (element) {
            _body = element;
          },
          child: DomComponent(
            tag: 'body',
            child: component.body,
          ),
        ),
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

mixin DocumentBinding on BindingBase {
  @override
  void initInstances() {
    super.initInstances();
    _instance = this;
  }

  static DocumentBinding? _instance;
  static DocumentBinding? get instance => _instance!;

  late SendPort _sendPort;
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

  Future<String> renderDocument(String injectState, MarkupDomRenderer renderer) async {
    var state = _document?.state;
    if (state is _ManualDocumentState && state._body != null) {
      (state._body!.data.attributes ??= {})['state-data'] = injectState;
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
