import '../markup_render_object.dart';
import '../server_binding.dart';

abstract class HeadScopeAdapter extends RenderAdapter {
  @override
  void prepare() {}

  @override
  void apply(MarkupRenderObject root) {
    final html = root.children.findWhere((c) => c.tag == 'html')?.node ?? root;
    var head = html.children.findWhere((c) => c.tag == 'head')?.node;

    if (head == null) {
      html.children.insertAfter(head = html.createChildRenderObject()..tag = 'head');
    }

    applyHead(head);
  }

  void applyHead(MarkupRenderObject head);
}
