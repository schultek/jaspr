import '../markup_render_object.dart';
import '../server_binding.dart';

abstract class HeadScopeAdapter extends RenderAdapter {
  @override
  void apply(MarkupRenderObject root) {
    var html = root.children.where((c) => c.tag == 'html').firstOrNull ?? root;
    var head = html.children.where((c) => c.tag == 'head').firstOrNull;

    if (head == null) {
      html.children.insert(0, head = html.createChildRenderObject()..tag = 'head');
    }

    applyHead(head);
  }

  void applyHead(MarkupRenderObject head);
}
