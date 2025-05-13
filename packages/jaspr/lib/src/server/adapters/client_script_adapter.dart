import '../../foundation/options.dart';
import '../markup_render_object.dart';
import '../server_binding.dart';
import 'head_scope_adapter.dart';

class ClientScriptAdapter extends HeadScopeAdapter {
  ClientScriptAdapter(this.binding, this.clientTargets);

  final ServerAppBinding binding;
  final List<ClientTarget> clientTargets;

  @override
  bool applyHead(MarkupRenderObject head) {
    if (clientTargets.isEmpty) {
      return false;
    }

    head.children.insertBefore(
      head.createChildRenderObject()
        ..updateElement('script', null, null, null, {'src': 'main.clients.dart.js', 'defer': ''}, null),
    );

    return true;
  }
}
