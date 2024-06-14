import '../../../jaspr.dart';
import '../adapters/client_component_adapter.dart';
import '../adapters/client_script_adapter.dart';
import '../server_binding.dart';

class ClientComponentRegistry extends ObserverComponent {
  ClientComponentRegistry({required super.child, super.key});

  @override
  ObserverElement createElement() => ClientComponentRegistryElement(this);
}

class ClientComponentRegistryElement extends ObserverElement {
  ClientComponentRegistryElement(super.component);

  final _adapter = ClientScriptAdapter();
  bool _didAddClientScript = false;

  @override
  void willRebuildElement(Element element) {
    var binding = this.binding as ServerAppBinding;

    if (!_didAddClientScript) {
      (binding).addRenderAdapter(_adapter);
      _didAddClientScript = true;
    }

    var entry = binding.options.targets[element.component.runtimeType];
    if (entry == null) {
      return;
    }

    var isClientBoundary = true;
    element.visitAncestorElements((e) {
      return isClientBoundary = !_adapter.clientElements.contains(e);
    });

    if (!isClientBoundary) {
      return;
    }

    _adapter.clientElements.add(element);
    binding.addRenderAdapter(ClientComponentAdapter(_adapter, entry, element));
  }

  @override
  void didRebuildElement(Element element) {}

  @override
  void didUnmountElement(Element element) {}
}
