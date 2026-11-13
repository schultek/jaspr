import 'dart:convert';

import '../../framework/framework.dart';
import '../components/client_component_registry.dart';
import '../markup_render_object.dart';
import '../server_binding.dart';

final class AppliedParamsAdapter extends RenderAdapter {
  final Map<DomElement, Map<String, dynamic>> elements = {};

  void add(DomElement element, Map<String, dynamic> diff) {
    elements[element] = diff;
  }

  @override
  void apply(MarkupRenderObject root) {
    final registry = binding.clientRegistry;
    if (registry == null) return;

    for (final MapEntry(:key, :value) in elements.entries) {
      if (_hasClientBoundaryAbove(key, registry)) {
        final renderObject = key.renderObject as MarkupRenderElement;
        (renderObject.attributes ??= {})['data-j-apply'] = jsonEncode(value);
      }
    }
  }

  bool _hasClientBoundaryAbove(Element element, ClientComponentRegistryElement registry) {
    if (registry.serverElements.containsKey(element) || registry.clientElements.containsKey(element)) {
      return true;
    }

    var hasBoundary = false;
    element.visitAncestorElements((e) {
      if (registry.serverElements.containsKey(e) || registry.clientElements.containsKey(e)) {
        hasBoundary = true;
        return false;
      }
      return true;
    });
    return hasBoundary;
  }
}
