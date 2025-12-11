import '../markup_render_object.dart';
import '../server_binding.dart';

mixin DocumentStructureMixin on RenderAdapter {
  (MarkupRenderElement, MarkupRenderElement, MarkupRenderElement) createDocumentStructure(MarkupRenderObject root) {
    var html = root.children.findWhere<MarkupRenderElement>((c) => c.tag == 'html')?.node as MarkupRenderElement?;
    if (html == null) {
      final range = root.children.range();
      root.children.insertAfter(html = root.createChildRenderElement('html')..children.insertNodeAfter(range));
    }

    final headNode = html.children.findWhere<MarkupRenderElement>((c) => c.tag == 'head');
    var head = headNode?.node as MarkupRenderElement?;
    final bodyNode = html.children.findWhere<MarkupRenderElement>((c) => c.tag == 'body');
    var body = bodyNode?.node as MarkupRenderElement?;

    if (head == null) {
      head = html.createChildRenderElement('head');

      if (body == null) {
        final range = html.children.range();
        html.children.insertAfter(head);
        html.children.insertBefore(body = html.createChildRenderElement('body')..children.insertNodeAfter(range));
      } else {
        html.children.insertAfter(head);
      }
    } else {
      if (body == null) {
        final rangeBefore = html.children.range(endBefore: headNode);
        final rangeAfter = html.children.range(startAfter: headNode);

        body = html.createChildRenderElement('body');
        body.children
          ..insertNodeAfter(rangeAfter)
          ..insertNodeAfter(rangeBefore);
        html.children.insertAfter(body, after: head);
      }
    }

    return (html, head, body);
  }
}

class DocumentAdapter extends RenderAdapter with DocumentStructureMixin {
  @override
  (MarkupRenderObject, MarkupRenderObject, MarkupRenderObject) apply(MarkupRenderObject root) {
    final (html, head, body) = createDocumentStructure(root);

    final doctype = root.children.findWhere<MarkupRenderText>((r) => r.text.startsWith('<!DOCTYPE') && r.rawHtml);
    if (doctype == null) {
      root.children.insertAfter(root.createChildRenderText('<!DOCTYPE html>', true));
    }

    return (html, head, body);
  }
}
