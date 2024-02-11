import '../../framework/framework.dart';
import '../markup_render_object.dart';
import '../server_binding.dart';
import 'client_script_adapter.dart';
import 'element_boundary_adapter.dart';

class ClientComponentAdapter extends ElementBoundaryAdapter {
  ClientComponentAdapter(this.name, this.data, super.element);

  final String name;
  final String data;

  @override
  void processBoundary(MarkupRenderObject parent, int start, int end) {
    parent.children.insert(start, parent.createChildRenderObject()..updateText('<!-- \$$name $data  -->', true));
    parent.children.insert(end + 1, parent.createChildRenderObject()..updateText('<!-- /\$$name -->', true));
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

  @override
  void willRebuildElement(Element element) {
    var binding = this.binding as ServerAppBinding;

    if (!_didAddClientScript) {
      (binding).addRenderAdapter(ClientScriptAdapter(binding, _clientElements));
      _didAddClientScript = true;
    }

    var entry = binding.options.targets[element.component.runtimeType];

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
    binding.addRenderAdapter(ClientComponentAdapter(entry.name, entry.dataFor(element.component), element));
  }

  @override
  void didRebuildElement(Element element) {}

  @override
  void didUnmountElement(Element element) {}
}
