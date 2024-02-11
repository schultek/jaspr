import '../markup_render_object.dart';
import '../server_binding.dart';

class DoctypeAdapter extends RenderAdapter {
  @override
  void apply(MarkupRenderObject root) {
    var hasDoctype =
        root.children.any((r) => r.text != null && r.text!.startsWith('<!DOCTYPE') && (r.rawHtml ?? false));

    if (!hasDoctype) {
      root.children.insert(0, root.createChildRenderObject()..updateText('<!DOCTYPE html>', true));
    }
  }
}
