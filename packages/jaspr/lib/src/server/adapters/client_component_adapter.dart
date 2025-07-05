import '../../foundation/options.dart';
import '../../foundation/validator.dart';
import '../../framework/framework.dart';
import '../markup_render_object.dart';
import '../server_binding.dart';
import 'client_script_adapter.dart';
import 'element_boundary_adapter.dart';

class ClientComponentAdapter extends ElementBoundaryAdapter {
  ClientComponentAdapter(this.name, this.data, super.element);

  final String name;
  final String? data;

  @override
  void applyBoundary(ChildListRange range) {
    range.start.insertNext(ChildNodeData(MarkupRenderObject()
      ..updateText('<!--${DomValidator.clientMarkerPrefix}$name${data != null ? ' data=$data' : ''}-->', true)));
    range.end.insertPrev(
        ChildNodeData(MarkupRenderObject()..updateText('<!--/${DomValidator.clientMarkerPrefix}$name-->', true)));
  }
}

class ClientComponentRegistry extends ObserverComponent {
  ClientComponentRegistry({required super.child, super.key});

  @override
  ObserverElement createElement() => ClientComponentRegistryElement(this);
}

class ClientComponentRegistryElement extends ObserverElement {
  ClientComponentRegistryElement(super.component);

  bool _didAddClientScript = false;
  final List<Element> _clientElements = [];
  final List<ClientTarget> _clientTargets = [];

  @override
  void willRebuildElement(Element element) {
    var binding = this.binding as ServerAppBinding;

    if (!_didAddClientScript) {
      (binding).addRenderAdapter(ClientScriptAdapter(binding, _clientTargets));
      _didAddClientScript = true;
    }

    var entry = binding.options.clients?[element.component.runtimeType];

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
  void didRebuildElement(Element element) {}

  @override
  void didUnmountElement(Element element) {}
}
