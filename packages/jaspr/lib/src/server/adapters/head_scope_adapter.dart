import '../markup_render_object.dart';
import '../server_binding.dart';

abstract class HeadScopeAdapter extends RenderAdapter {
  @override
  void prepare() {}

  @override
  void apply(MarkupRenderObject root) {
    var html = root.children.findWhere((c) => c is MarkupRenderElement && c.tag == 'html')?.node ?? root;
    var head = html.children.findWhere((c) => c is MarkupRenderElement && c.tag == 'head')?.node;

    bool needsInsert = false;
    if (head == null) {
      head = html.createChildRenderElement('head');
      needsInsert = true;
    }

    var didApply = applyHead(head);
    if (didApply && needsInsert) {
      html.children.insertAfter(head);
    }
  }

  bool applyHead(MarkupRenderObject head);
}
