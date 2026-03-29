import 'dart:developer';

import 'package:meta/meta.dart';

import '../foundation/change_notifier.dart';
import '../foundation/diagnostics.dart';
import '../framework/framework.dart';

class DevToolsService {
  DevToolsService._();
  static final instance = DevToolsService._();

  final Expando<Element> domRegistry = Expando<Element>();

  final ValueNotifier<Element?> selectedElement = ValueNotifier<Element?>(null);

  bool get debugVerboseLoggingActive => _debugVerboseLoggingActive;
  bool _debugVerboseLoggingActive = false;

  @protected
  set debugVerboseLoggingActive(bool value) {
    _debugVerboseLoggingActive = value;
  }

  final Map<String, WeakReference<Element>> _idToElement = {};
  final Expando<String> _elementToId = Expando<String>();
  int _nextId = 0;

  String toId(Element element) {
    var id = _elementToId[element];
    if (id == null) {
      id = '\$${_nextId++}';
      _elementToId[element] = id;
      _idToElement[id] = WeakReference(element);
    }
    return id;
  }

  void initServiceExtensions() {
    registerExtension('ext.jaspr.inspector.setSelection', (method, parameters) async {
      final id = parameters['id'];
      if (id is String && _idToElement.containsKey(id)) {
        final element = _idToElement[id]?.target;
        if (element != null) {
          selectedElement.value = element;
          return ServiceExtensionResponse.result('{"success":true}');
        }
      }
      return ServiceExtensionResponse.error(ServiceExtensionResponse.invalidParams, 'Invalid or unknown element ID');
    });
  }

  void selectElement(Element element) {
    selectedElement.value = element;
    postEvent('ext.jaspr.inspector.selectionChanged', {
      'id': toId(element),
      'elementType': element.runtimeType.toString(),
    });
  }

  void sendServerTree(String? id, String url, Element rootElement, Map<Element, Diagnosticable> extensions) {
    postEvent('ext.jaspr.serverTree', {
      'id': id,
      'url': url,
      'tree': _elementToNode(rootElement, extensions).toJsonMap(),
    });
  }

  void sendClientTree(String? id, String url, String attachTarget, Element rootElement) {
    postEvent('ext.jaspr.clientTree', {
      'id': id,
      'url': url,
      'attachTarget': attachTarget,
      'tree': _elementToNode(rootElement).toJsonMap(),
    });
  }

  DiagnosticsNode _elementToNode(Element element, [Map<Element, Diagnosticable>? extensions]) {
    final children = <DiagnosticsNode>[];
    element.debugVisitChildren((element) {
      children.add(_elementToNode(element, extensions));
    });

    return DiagnosticsNode(
      name: element.runtimeType.toString(),
      properties: [
        DiagnosticsProperty(name: 'id', value: toId(element)),
        ...element.debugFillProperties(),
        if (extensions?[element] case final extension?) ...extension.debugFillProperties(),
      ],
      children: children,
    );
  }
}
