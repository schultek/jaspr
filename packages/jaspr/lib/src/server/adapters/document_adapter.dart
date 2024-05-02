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

    if (head == null) {
      var head = html.createChildRenderObject()..tag = 'head';
      head.children.insertAfter(head.createChildRenderObject()
        ..tag = 'base'
        ..attributes = {'href': '/'});

      if (body == null) {
        var range = html.children.range();
        html.children.insertAfter(head);
        html.children.insertBefore(html.createChildRenderObject()
          ..tag = 'body'
          ..children.insertNodeAfter(range));
      } else {
        html.children.insertAfter(head);
      }
    } else {
      if (body == null) {
        var rangeBefore = html.children.range(endBefore: head);
        var rangeAfter = html.children.range(startAfter: head);

        var body = html.createChildRenderObject()..tag = 'body';
        body.children
          ..insertNodeAfter(rangeAfter)
          ..insertNodeAfter(rangeBefore);
        html.children.insertAfter(body, after: head.node);
      }

      var base = head.node.children.findWhere((c) => c.tag == 'base');
      if (base == null) {
        head.node.children.insertAfter(head.node.createChildRenderObject()
          ..tag = 'base'
          ..attributes = {'href': '/'});
      }
    }

    var hasDoctype =
        root.children.findWhere((r) => r.text != null && r.text!.startsWith('<!DOCTYPE') && (r.rawHtml ?? false)) !=
            null;

    if (!hasDoctype) {
      root.children.insertAfter(root.createChildRenderObject()..updateText('<!DOCTYPE html>', true));
    }
  }
}
