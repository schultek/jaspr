import '../markup_render_object.dart';
import 'head_scope_adapter.dart';

class ClientScriptAdapter extends HeadScopeAdapter {
  ClientScriptAdapter(this.clientId);

  final String clientId;

  @override
  bool applyHead(MarkupRenderObject head) {
    var scriptSrc = clientId;

    // Use absolute path if no base tag is present, otherwise relative to the base.
    final base = head.children.findWhere<MarkupRenderElement>((c) => c.tag == 'base');
    if (base == null) {
      scriptSrc = '/$scriptSrc';
    }

    head.children.insertBefore(
      head.createChildRenderElement('script')..update(null, null, null, {'src': scriptSrc, 'defer': ''}, null),
    );

    return true;
  }
}
