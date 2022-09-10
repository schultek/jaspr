library document;

import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:html/parser.dart';

import '../../../server.dart';

part 'document_binding.dart';
part 'manual_document.dart';

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

class _BaseDocument extends _ManualDocument {
  const _BaseDocument({
    super.title,
    super.base,
    super.charset,
    super.viewport,
    super.meta,
    super.styles,
    super.scriptName,
    super.head,
    required super.body,
  });
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
  }) : super(scriptName: '');

  @override
  State<Document> createState() => _AppDocumentState();
}

class _AppDocumentState extends _ManualDocumentState with _ComponentEntryStateMixin<String> {
  @override
  void onElementRegistered(Element element, ComponentEntry entry) {
    if (!entry.isApp) return;
    var id = getIdFor(element);
    _appData = {
      'id': id,
      ...entry.loadParams(element.component),
    };
  }

  Map<String, dynamic> _appData = {};

  @override
  Map<String, dynamic> _getExtendedConfig() {
    return {'app': _appData};
  }

  @override
  String? get scriptName {
    var apps = DocumentBinding.instance!._registryElements.entries.where((c) => c.value.isApp).toList();

    if (apps.isEmpty) {
      print("[WARNING] Used Document.app() but no app component was provided.");
      return null;
    }
    if (apps.length > 1) {
      print("[WARNING] Used Document.app() but multiple app components were provided.");
    }

    return apps.first.value.name + '.g';
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
  }) : super(scriptName: '');

  @override
  State<Document> createState() => _IslandsDocumentState();
}

class _IslandsDocumentState extends _ManualDocumentState with _ComponentEntryStateMixin<Map<String, String>> {
  @override
  void onElementRegistered(Element element, ComponentEntry entry) {
    if (!entry.isIsland) return;
    var id = getIdFor(element);
    _islands.add({
      'id': id,
      'name': entry.name,
      ...entry.loadParams(element.component),
    });
  }

  @override
  Map<String, dynamic> _getExtendedConfig() {
    return {'islands': _islands};
  }

  final List<Map<String, dynamic>> _islands = [];

  @override
  String? get scriptName {
    var islands = DocumentBinding.instance!._registryElements.entries.where((e) => e.value.isIsland).toList();

    if (islands.isEmpty) {
      print("[WARNING] Used Document.islands() but no island components were provided.");
      return null;
    }

    return DocumentBinding.instance!._registryData!.target + '.islands';
  }
}

mixin _ComponentEntryStateMixin<T> on _ManualDocumentState {
  String? get scriptName;

  @override
  void _prepareRender(Map<String, dynamic> syncState) {
    _setScript(scriptName);
    super._prepareRender(syncState);
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

    var firstIndex = (firstChild != null ? container.data.children.indexOf(firstChild) : -1) + 1;
    var lastIndex = (lastChild != null ? container.data.children.indexOf(lastChild) : -1) + 1;

    if (firstIndex > lastIndex) {
      lastIndex = firstIndex;
    }

    return '$selector($firstIndex:$lastIndex)';
  }
}

final _chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
String _randomId() {
  var r = Random();
  return List.generate(8, (i) => _chars[r.nextInt(_chars.length)]).join();
}
