import '../../dom/validator.dart';
import '../../foundation/constants.dart';
import '../../framework/framework.dart';
import '../markup_render_object.dart';
import '../options.dart';
import '../server_binding.dart';
import 'client_script_adapter.dart';
import 'element_boundary_adapter.dart';

class ClientComponentAdapter extends ElementBoundaryAdapter {
  ClientComponentAdapter(this.name, this.data, super.element);

  final String name;
  final String? data;

  @override
  void applyBoundary(ChildListRange range) {
    final startMarker = MarkupRenderText(
      '<!--${DomValidator.clientMarkerPrefix}$name${data != null ? ' data=$data' : ''}-->',
      true,
    );
    final endMarker = MarkupRenderText('<!--/${DomValidator.clientMarkerPrefix}$name-->', true);

    range.start.insertNext(ChildNodeData(startMarker));
    range.end.insertPrev(ChildNodeData(endMarker));
  }
}

class ClientComponentRegistry extends ObserverComponent {
  ClientComponentRegistry({required super.child, super.key});

  @override
  ObserverElement createElement() => ClientComponentRegistryElement(this);
}

class ClientComponentRegistryElement extends ObserverElement {
  ClientComponentRegistryElement(super.component);

  bool _didHandleClientScript = false;
  final List<Element> _clientElements = [];
  final List<ClientTarget> _clientTargets = [];

  @override
  void willRebuildElement(Element element) {}

  @override
  void didRebuildElement(Element element) {
    final binding = this.binding as ServerAppBinding;

    if (!_didHandleClientScript) {
      if (binding.options.clientId != null) {
        (binding).addRenderAdapter(ClientScriptAdapter(binding.options.clientId!));
      } else if (kDebugMode) {
        (binding).addRenderAdapter(NoClientScriptAdapter());
      }
      _didHandleClientScript = true;
    }

    final entry = binding.options.clients?[element.component.runtimeType];

    if (entry == null) {
      return;
    }

    var isClientBoundary = true;
    element.visitAncestorElements((e) {
      return isClientBoundary = !_clientElements.contains(e);
    });

    if (!isClientBoundary) {
      return;
    }

    _clientElements.add(element);
    _clientTargets.add(entry);
    binding.addRenderAdapter(ClientComponentAdapter(entry.name, entry.dataFor(element.component), element));
  }

  @override
  void didUnmountElement(Element element) {}
}
