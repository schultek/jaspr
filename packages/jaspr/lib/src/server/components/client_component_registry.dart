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

  bool _didAddClientScript = false;

  final List<Element> clientElements = [];

  int serverElementNum = 1;
  final Map<Component, int> serverComponents = {};
  final Map<int, Element?> serverElements = {0: null};

  @override
  void willRebuildElement(Element element) {}

  @override
  void didRebuildElement(Element element) {
    final binding = this.binding as ServerAppBinding;

    if (!_didAddClientScript && binding.options.clientId != null) {
      (binding).addRenderAdapter(ClientScriptAdapter(binding.options.clientId!));
      _didAddClientScript = true;
    }

    final entry = binding.options.clients?[element.component.runtimeType];
    if (entry == null) {
      return;
    }

    clientElements.add(element);
    binding.addRenderAdapter(ClientComponentAdapter(this, entry, element));
  }

  @override
  void didUnmountElement(Element element) {}
}
