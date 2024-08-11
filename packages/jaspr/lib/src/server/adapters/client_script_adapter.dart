import '../../framework/framework.dart';
import '../markup_render_object.dart';
import '../server_binding.dart';
import 'head_scope_adapter.dart';

class ClientScriptAdapter extends HeadScopeAdapter {
  ClientScriptAdapter(this.binding, this.clientElements);

  final ServerAppBinding binding;
  final List<Element> clientElements;

  @override
  void applyHead(MarkupRenderObject head) {
    if (clientElements.isEmpty) {
      return;
    }

    String source;
    if (clientElements.length == 1) {
      var entry = binding.options.clients[clientElements.first.component.runtimeType]!;
      source = '${entry.name}.client';
    } else {
      source = 'main.clients';
    }

    head.children.insertBefore(
      head.createChildRenderObject()
        ..updateElement('script', null, null, null, {'src': '$source.dart.js', 'defer': ''}, null),
    );
  }
}
