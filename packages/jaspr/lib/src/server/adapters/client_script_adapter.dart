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

    final base = head.children.findWhere((c) => c is MarkupRenderElement && c.tag == 'base');

    // Use absolute path if no base tag is present, otherwise relative to the base.
    final scriptSrc = base == null ? '/main.clients.dart.js' : 'main.clients.dart.js';

    head.children.insertBefore(
      head.createChildRenderElement('script')..update(null, null, null, {'src': scriptSrc, 'defer': ''}, null),
    );

    return true;
  }
}
