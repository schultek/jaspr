import '../markup_render_object.dart';
import '../server_binding.dart';

mixin DocumentStructureMixin on RenderAdapter {
  (MarkupRenderObject, MarkupRenderObject, MarkupRenderObject) createDocumentStructure(MarkupRenderObject root) {
    var html = root.children.findWhere((c) => c.tag == 'html')?.node;
    if (html == null) {
      var range = root.children.range();
      root.children.insertAfter(
        html = root.createChildRenderObject()
          ..tag = 'html'
          ..children.insertNodeAfter(range),
      );
    }

    var headNode = html.children.findWhere((c) => c.tag == 'head');
    var head = headNode?.node;
    var bodyNode = html.children.findWhere((c) => c.tag == 'body');
    var body = bodyNode?.node;

    if (head == null) {
      head = html.createChildRenderObject()..tag = 'head';
     
      if (body == null) {
        var range = html.children.range();
        html.children.insertAfter(head);
        html.children.insertBefore(body = html.createChildRenderObject()
          ..tag = 'body'
          ..children.insertNodeAfter(range));
      } else {
        html.children.insertAfter(head);
      }
    } else {
      if (body == null) {
        var rangeBefore = html.children.range(endBefore: headNode);
        var rangeAfter = html.children.range(startAfter: headNode);

        body = html.createChildRenderObject()..tag = 'body';
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

    var doctype = root.children.findWhere((r) => (r.text?.startsWith('<!DOCTYPE') ?? false) && (r.rawHtml ?? false));
    if (doctype == null) {
      root.children.insertAfter(root.createChildRenderObject()..updateText('<!DOCTYPE html>', true));
    }

    return (html, head, body);
  }
}
