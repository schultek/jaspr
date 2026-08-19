import 'dart:convert';
import 'dart:developer';
import 'dart:math';

import 'package:listen/listen.dart';
import 'package:meta/meta.dart';
import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart' as web;

import '../client/slotted_child_view.dart';
import '../foundation/constants.dart';
import '../foundation/diagnostics.dart';
import '../framework/framework.dart';
import 'models/tree_element.dart';

@JS('Reflect.has')
external bool _jsReflectHas(ExternalDartReference<Object> target, JSString property);

@JS('Reflect.set')
external bool _jsReflectSet(ExternalDartReference<Object> target, JSString property, JSAny? value);

@JS('Reflect.get')
external JSAny? _jsReflectGet(ExternalDartReference<Object> target, JSString property);

@JS('Reflect.ownKeys')
external JSArray _jsReflectOwnKeys(ExternalDartReference<Object> target);

@JS('Object.defineProperty')
external JSObject _defineProperty(ExternalDartReference<Object> target, JSString property, _PropertyDescriptor descriptor);

@JS()
@anonymous
extension type _PropertyDescriptor._(JSObject _) implements JSObject {
  external factory _PropertyDescriptor({JSAny? value, bool writable, bool configurable, bool enumerable});
}

class DevToolsService {
  static final instance = DevToolsService._();

  DevToolsService._() {
    if (kIsWeb) {
      initServiceExtensions();
    }
  }

  final Map<String, Object?> debugData = () {
    if (!kIsWeb) return <String, Object?>{};

    final data = web.document.querySelector('meta[name="jaspr-debug-data"]')?.getAttribute('content');
    return jsonDecode(data ?? '{}') as Map<String, Object?>;
  }();

  final ValueNotifier<TreeElement?> selectedElement = ValueNotifier<TreeElement?>(null);

  bool get debugVerboseLoggingActive => _debugVerboseLoggingActive;
  bool _debugVerboseLoggingActive = false;

  @protected
  set debugVerboseLoggingActive(bool value) {
    _debugVerboseLoggingActive = value;
  }

  void attachDebugDataToDocument() {
    if (!kIsWeb) return;

    if (debugData case {'serverTree': final Map<String, Object?> serverTreeMap}) {
      final serverTree = DiagnosticsNode.fromJsonMap(serverTreeMap);

      DiagnosticsNode? findDocumentRoot(DiagnosticsNode node) {
        if (node.name == 'DomElement' && node.properties?.getTagForDomElement() == 'html') return node;
        if (node.children case final children?) {
          for (final child in children) {
            final found = findDocumentRoot(child);
            if (found != null) return found;
          }
        }
        return null;
      }

      final documentRoot = findDocumentRoot(serverTree);
      if (documentRoot != null) {
        final rootElement = RemoteElement.fromDiagnosticsNode(documentRoot);
        matchTreeChildren(rootElement, web.document.documentElement!);
      }
    }
  }

  void matchTreeChildren(RemoteElement treeParent, web.Element domParent) {
    if (domParent.children.length <= 0) return;

    web.Element? currentDomNode = domParent.children.item(0)!;
    final toVisit = [...treeParent.children.reversed];

    while (currentDomNode != null && toVisit.isNotEmpty) {
      final currentTreeNode = toVisit.removeLast();
      final tag = currentTreeNode.name == 'DomElement' ? currentTreeNode.properties.getTagForDomElement() : null;

      if (tag != null && tag == currentDomNode.tagName.toLowerCase()) {
        RemoteElement.nodeRegistry[currentDomNode] = currentTreeNode;
        currentTreeNode.node = currentDomNode;
        matchTreeChildren(currentTreeNode, currentDomNode);
        currentDomNode = currentDomNode.nextElementSibling;
      } else {
        if (tag == null) {
          toVisit.addAll(currentTreeNode.children.reversed);
        }
      }
    }
  }

  void registerRenderObject(RenderObjectElement element) {
    final renderObject = element.renderObject;
    if (renderObject is ChildSlotRenderObject) return;
    final node = renderObject.node;
    if (node != null) {
      LocalElement.nodeRegistry[node] = element;
    }
  }

  void initServiceExtensions() {
    registerExtension('ext.jaspr.inspector.setSelection', (method, parameters) async {
      final id = parameters['id'];
      if (id is String) {
        if (LocalElement.forId(id) case final element?) {
          selectedElement.value = element;
          return ServiceExtensionResponse.result('{"success":true}');
        }
        if (RemoteElement.forId(id) case final element?) {
          selectedElement.value = element;
          return ServiceExtensionResponse.result('{"success":true}');
        }
      }

      return ServiceExtensionResponse.error(ServiceExtensionResponse.invalidParams, 'Invalid or unknown element ID');
    });

    registerExtension('ext.jaspr.inspector.updateProperty', (method, parameters) async {
      final id = parameters['id'];
      final targetScope = parameters['target'];
      final property = parameters['property'];
      final value = parameters['value'];

      if (id is String && property is String) {
        if (updateElementProperty(id, targetScope is String ? targetScope : null, property, value)) {
          return ServiceExtensionResponse.result('{"success":true}');
        }
      }

      return ServiceExtensionResponse.error(ServiceExtensionResponse.invalidParams, 'Failed to update property');
    });
  }

  bool updateElementProperty(String id, String? targetScope, String propertyName, dynamic value) {
    web.console.log('[DevTools] updateElementProperty: id=$id, scope=$targetScope, prop=$propertyName, val=$value'.toJS);
    if (LocalElement.forId(id) case final localElement?) {
      final element = localElement.element;
      web.console.log('[DevTools] Found element: ${element.runtimeType} (isStateful: ${element is StatefulElement})'.toJS);
      bool updated = false;

      if (targetScope == 'state') {
        if (element is StatefulElement) {
          final state = element.state;
          web.console.log('[DevTools] Targeting state: ${state.runtimeType}'.toJS);
          if (_setObjectProperty(state, propertyName, value)) {
            element.markNeedsBuild();
            updated = true;
          }
        } else {
          web.console.warn('[DevTools] targetScope is "state" but element is not StatefulElement'.toJS);
        }
      } else if (targetScope == 'component') {
        final component = element.component;
        web.console.log('[DevTools] Targeting component: ${component.runtimeType}'.toJS);
        if (_setObjectProperty(component, propertyName, value)) {
          element.markNeedsBuild();
          updated = true;
        }
      } else {
        web.console.warn('[DevTools] Unknown or missing targetScope: $targetScope'.toJS);
      }

      if (updated) {
        web.console.log('[DevTools] Property update succeeded! Rebuilding element.'.toJS);
        postEvent('ext.jaspr.inspector.selectionChanged', {
          'id': id,
        });
        return true;
      } else {
        web.console.error('[DevTools] Property update failed for prop "$propertyName"'.toJS);
      }
    } else {
      web.console.error('[DevTools] LocalElement not found for id "$id"'.toJS);
    }
    return false;
  }

  bool _setObjectProperty(Object target, String propertyName, dynamic value) {
    if (!kIsWeb) return false;

    try {
      // Parse string inputs to native typed values if needed
      dynamic parsedValue = value;
      if (value is String) {
        if (value == 'true') {
          parsedValue = true;
        } else if (value == 'false') {
          parsedValue = false;
        } else if (int.tryParse(value) case final intVal?) {
          parsedValue = intVal;
        } else if (double.tryParse(value) case final doubleVal?) {
          parsedValue = doubleVal;
        }
      }

      final JSAny? jsVal = switch (parsedValue) {
        final String s => s.toJS,
        final num n => n.toJS,
        final bool b => b.toJS,
        null => null,
        _ => parsedValue.toString().toJS,
      };

      web.console.log('[DevTools] Target JS object:'.toJS);
      web.console.log(target.toJSBox);

      final targetRef = target.toExternalReference;
      final candidateNames = [
        propertyName,
        '_$propertyName',
        '$propertyName\$',
        '_\$$propertyName\$',
      ];

      for (final name in candidateNames) {
        final jsKey = name.toJS;
        final hasProp = _jsReflectHas(targetRef, jsKey);
        web.console.log('[DevTools] Checking candidate "$name": hasProp=$hasProp'.toJS);
        if (hasProp) {
          if (_jsReflectSet(targetRef, jsKey, jsVal)) {
            web.console.log('[DevTools] Reflect.set succeeded for candidate "$name"'.toJS);
            return true;
          }
          // If Reflect.set fails (e.g. getter-only on prototype), define own writable property on instance
          try {
            _defineProperty(
              targetRef,
              jsKey,
              _PropertyDescriptor(
                value: jsVal,
                writable: true,
                configurable: true,
                enumerable: true,
              ),
            );
            web.console.log('[DevTools] defineProperty succeeded for candidate "$name"'.toJS);
            return true;
          } catch (e) {
            web.console.error(e.toString().toJS);
          }
        }
      }
      return false;
    } catch (e) {
      web.console.error(e.toString().toJS);
      return false;
    }
  }

  void selectElement(TreeElement element, String url) {
    selectedElement.value = element;
    postEvent('ext.jaspr.inspector.selectionChanged', {
      'id': element.id,
      'url': url,
    });
  }

  ({String renderId, DiagnosticsNode serverTree}) sendServerTree(
    String url,
    Element rootElement,
    Map<Element, Diagnosticable> extensions,
  ) {
    final renderId = Random().nextInt(0xffffffff).toRadixString(16);

    final tree = _elementToNode(rootElement, extensions);
    postEvent('ext.jaspr.serverTree', {
      'id': renderId,
      'url': url,
      'tree': tree.toJsonMap(),
    });
    return (renderId: renderId, serverTree: tree);
  }

  void sendClientTree(String url, String attachTarget, Element rootElement) {
    postEvent('ext.jaspr.clientTree', {
      'id': debugData['renderId'],
      'url': url,
      'tree': _elementToNode(rootElement).toJsonMap(),
      'info': {
        'attachTarget': attachTarget,
        'title': web.window.document.title,
      },
    });
  }

  DiagnosticsNode _elementToNode(Element element, [Map<Element, Diagnosticable>? extensions]) {
    final children = <DiagnosticsNode>[];
    element.debugVisitChildren((element) {
      children.add(_elementToNode(element, extensions));
    });

    final elementProps = element.debugFillProperties();
    final processedProps = <DiagnosticsProperty>[];

    for (final prop in elementProps) {
      if (prop.name == 'component' && (prop.properties == null || prop.properties!.isEmpty)) {
        final fallbackProps = _getObjectProperties(element.component);
        if (fallbackProps.isNotEmpty) {
          processedProps.add(DiagnosticsProperty(name: 'component', properties: fallbackProps));
          continue;
        }
      }
      if (prop.name == 'state' && (prop.properties == null || prop.properties!.isEmpty) && element is StatefulElement) {
        final fallbackProps = _getObjectProperties(element.state);
        if (fallbackProps.isNotEmpty) {
          processedProps.add(DiagnosticsProperty(name: 'state', properties: fallbackProps));
          continue;
        }
      }
      processedProps.add(prop);
    }

    return DiagnosticsNode(
      name: element.runtimeType.toString(),
      properties: [
        DiagnosticsProperty(name: 'id', value: LocalElement.toId(element)),
        DiagnosticsProperty(name: 'location', value: CreationLocation.of(element.component)?.toJsonMap()),
        ...processedProps,
        if (extensions?[element] case final extension?) ...extension.debugFillProperties(),
      ],
      children: children,
    );
  }

  List<DiagnosticsProperty> _getObjectProperties(Object target) {
    if (!kIsWeb) return const [];
    try {
      final targetRef = target.toExternalReference;
      final keysArray = _jsReflectOwnKeys(targetRef);
      final length = keysArray.length;
      final props = <DiagnosticsProperty>[];
      final seenNames = <String>{};

      for (var i = 0; i < length; i++) {
        final keyAny = keysArray.toDart[i];
        if (keyAny == null) continue;
        final rawKey = keyAny.toString();

        // Skip internal framework and runtime fields
        if (rawKey.startsWith('_element') ||
            rawKey.startsWith('_state') ||
            rawKey.startsWith('_lifecycle') ||
            rawKey.startsWith('_dirty') ||
            rawKey.startsWith('hashCode') ||
            rawKey.startsWith('runtimeType') ||
            rawKey.startsWith('key') ||
            rawKey.startsWith('Symbol(')) {
          continue;
        }

        // Clean up DDC mangled names (e.g. name$ -> name, _count -> count)
        var cleanName = rawKey;
        if (cleanName.endsWith('\$')) {
          cleanName = cleanName.substring(0, cleanName.length - 1);
        }
        if (cleanName.startsWith('_')) {
          cleanName = cleanName.substring(1);
        }
        if (cleanName.isEmpty || seenNames.contains(cleanName)) {
          continue;
        }

        try {
          final jsVal = _jsReflectGet(targetRef, rawKey.toJS);
          dynamic dartVal;
          if (jsVal == null) {
            dartVal = null;
          } else if (jsVal.isA<JSString>()) {
            dartVal = (jsVal as JSString).toDart;
          } else if (jsVal.isA<JSNumber>()) {
            dartVal = (jsVal as JSNumber).toDartDouble;
          } else if (jsVal.isA<JSBoolean>()) {
            dartVal = (jsVal as JSBoolean).toDart;
          } else {
            dartVal = jsVal.toString();
          }

          seenNames.add(cleanName);
          props.add(DiagnosticsProperty(name: cleanName, value: dartVal));
        } catch (_) {}
      }
      return props;
    } catch (_) {
      return const [];
    }
  }
}
