import '../../../jaspr.dart';
import '../adapters/client_component_adapter.dart';
import '../adapters/client_script_adapter.dart';
import '../options.dart';
import '../server_binding.dart';

class ClientComponentRegistry extends ObserverComponent {
  ClientComponentRegistry({required super.child, super.key});

  @override
  ObserverElement createElement() => ClientComponentRegistryElement(this);
}

class ClientComponentRegistryElement extends ObserverElement {
  ClientComponentRegistryElement(super.component);

  bool _didHandleClientScript = false;

  final Map<Element, ClientTarget> clientElements = {};

  int serverElementNum = 1;
  final Map<Component, int> serverComponents = {};
  final Map<int, Element?> serverElements = {0: null};

  @override
  void willRebuildElement(Element element) {
    final binding = this.binding as ServerAppBinding;

    final entry = binding.options.clients?[element.component.runtimeType];
    if (entry == null) {
      return;
    }

    if (!_didHandleClientScript) {
      if (binding.options.clientId != null) {
        (binding).addRenderAdapter(ClientScriptAdapter(binding.options.clientId!));
      } else if (kDebugMode) {
        (binding).addRenderAdapter(NoClientScriptAdapter());
      }
      _didHandleClientScript = true;
    }

    clientElements[element] = entry;
    binding.addRenderAdapter(ClientComponentAdapter(this, entry, element));
  }

  @override
  void didRebuildElement(Element element) {}

  @override
  void didUnmountElement(Element element) {}
}
