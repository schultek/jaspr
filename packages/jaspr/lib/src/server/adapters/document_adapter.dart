import '../markup_render_object.dart';
import '../server_binding.dart';

class DocumentAdapter extends RenderAdapter {
  @override
  void prepare() {}

  @override
  void apply(MarkupRenderObject root) {
    var html = root.children.findWhere((c) => c.tag == 'html')?.node;
    if (html == null) {
      final range = root.children.range();
      root.children.insertAfter(
        html = root.createChildRenderObject()
          ..tag = 'html'
          ..children.insertNodeAfter(range),
      );
    }

    final head = html.children.findWhere((c) => c.tag == 'head');
    final body = html.children.findWhere((c) => c.tag == 'body');

    if (head == null) {
      final head = html.createChildRenderObject()..tag = 'head';
      head.children.insertAfter(head.createChildRenderObject()
        ..tag = 'base'
        ..attributes = {'href': '/'});

      if (body == null) {
        final range = html.children.range();
        html.children.insertAfter(head);
        html.children.insertBefore(html.createChildRenderObject()
          ..tag = 'body'
          ..children.insertNodeAfter(range));
      } else {
        html.children.insertAfter(head);
      }
    } else {
      if (body == null) {
        final rangeBefore = html.children.range(endBefore: head);
        final rangeAfter = html.children.range(startAfter: head);

        final body = html.createChildRenderObject()..tag = 'body';
        body.children
          ..insertNodeAfter(rangeAfter)
          ..insertNodeAfter(rangeBefore);
        html.children.insertAfter(body, after: head.node);
      }

      final base = head.node.children.findWhere((c) => c.tag == 'base');
      if (base == null) {
        head.node.children.insertAfter(head.node.createChildRenderObject()
          ..tag = 'base'
          ..attributes = {'href': '/'});
      }
    }

    final hasDoctype =
        root.children.findWhere((r) => r.text != null && r.text!.startsWith('<!DOCTYPE') && (r.rawHtml ?? false)) !=
            null;

    if (!hasDoctype) {
      root.children.insertAfter(root.createChildRenderObject()..updateText('<!DOCTYPE html>', true));
    }
  }
}
