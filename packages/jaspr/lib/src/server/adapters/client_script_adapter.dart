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

    String source;
    if (clientTargets.length == 1) {
      var entry = clientTargets.first;
      source = '${entry.name}.client';
    } else {
      source = 'main.clients';
    }

    head.children.insertBefore(
      head.createChildRenderObject()
        ..updateElement('script', null, null, null, {'src': '$source.dart.js', 'defer': ''}, null),
    );

    return true;
  }
}
