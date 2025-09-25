import '../../framework/framework.dart';
import '../markup_render_object.dart';
import 'head_scope_adapter.dart';

class ClientScriptAdapter extends HeadScopeAdapter {
  ClientScriptAdapter();

  final List<Element> clientElements = [];

  int serverElementNum = 1;
  final Map<Component, int> serverComponents = {};
  final Map<int, Element?> serverElements = {0: null};

  @override
  bool applyHead(MarkupRenderObject head) {
    if (clientElements.isEmpty) {
      return false;
    }

    final base = head.children.findWhere<MarkupRenderElement>((c) => c.tag == 'base');

    // Use absolute path if no base tag is present, otherwise relative to the base.
    final scriptSrc = base == null ? '/main.clients.dart.js' : 'main.clients.dart.js';

    head.children.insertBefore(
      head.createChildRenderElement('script')..update(null, null, null, {'src': scriptSrc, 'defer': ''}, null),
    );

    return true;
  }
}
