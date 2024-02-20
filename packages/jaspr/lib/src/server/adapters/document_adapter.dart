import '../markup_render_object.dart';
import '../server_binding.dart';

class DocumentAdapter extends RenderAdapter {
  @override
  void prepare() {}

  @override
  void apply(MarkupRenderObject root) {
    var html = root.children.findWhere((c) => c.tag == 'html')?.node;
    if (html == null) {
      var range = root.children.range();
      root.children.insertAfter(
        html = root.createChildRenderObject()
          ..tag = 'html'
          ..children.insertNodeAfter(range),
      );
    }

    var head = html.children.findWhere((c) => c.tag == 'head');
    var body = html.children.findWhere((c) => c.tag == 'body');

    if (body == null && head == null) {
      var range = html.children.range();
      html.children.insertAfter(html.createChildRenderObject()..tag = 'head');
      html.children.insertBefore(html.createChildRenderObject()
        ..tag = 'body'
        ..children.insertNodeAfter(range));
    } else if (body != null && head == null) {
      html.children.insertAfter(html.createChildRenderObject()..tag = 'head');
    } else if (body == null && head != null) {
      var rangeBefore = html.children.range(endBefore: head);
      var rangeAfter = html.children.range(startAfter: head);

      var body = html.createChildRenderObject()..tag = 'body';
      body.children
        ..insertNodeAfter(rangeAfter)
        ..insertNodeAfter(rangeBefore);
      html.children.insertAfter(body, after: head.node);
    }

    var hasDoctype =
        root.children.findWhere((r) => r.text != null && r.text!.startsWith('<!DOCTYPE') && (r.rawHtml ?? false)) !=
            null;

    if (!hasDoctype) {
      root.children.insertAfter(root.createChildRenderObject()..updateText('<!DOCTYPE html>', true));
    }
  }
}
