import '../markup_render_object.dart';
import '../server_binding.dart';

mixin DocumentStructureMixin on RenderAdapter {
  (MarkupRenderObject, MarkupRenderObject, MarkupRenderObject) createDocumentStructure(MarkupRenderObject root) {
    var html = root.children.findWhere((c) => c is MarkupRenderElement && c.tag == 'html')?.node;
    if (html == null) {
      var range = root.children.range();
      root.children.insertAfter(
        html = root.createChildRenderElement('html')..children.insertNodeAfter(range),
      );
    }

    var headNode = html.children.findWhere((c) => c is MarkupRenderElement && c.tag == 'head');
    var head = headNode?.node;
    var bodyNode = html.children.findWhere((c) => c is MarkupRenderElement && c.tag == 'body');
    var body = bodyNode?.node;

    if (head == null) {
      head = html.createChildRenderElement('head');
      head.children.insertAfter(head.createChildRenderElement('base')..attributes = {'href': '/'});

      if (body == null) {
        var range = html.children.range();
        html.children.insertAfter(head);
        html.children.insertBefore(body = html.createChildRenderElement('body')..children.insertNodeAfter(range));
      } else {
        html.children.insertAfter(head);
      }
    } else {
      if (body == null) {
        var rangeBefore = html.children.range(endBefore: headNode);
        var rangeAfter = html.children.range(startAfter: headNode);

        body = html.createChildRenderElement('body');
        body.children
          ..insertNodeAfter(rangeAfter)
          ..insertNodeAfter(rangeBefore);
        html.children.insertAfter(body, after: head);
      }

      var base = head.children.findWhere((c) => c is MarkupRenderElement && c.tag == 'base');
      if (base == null) {
        head.children.insertAfter(head.createChildRenderElement('base')..attributes = {'href': '/'});
      }
    }

    return (html, head, body);
  }
}

class DocumentAdapter extends RenderAdapter with DocumentStructureMixin {
  @override
  (MarkupRenderObject, MarkupRenderObject, MarkupRenderObject) apply(MarkupRenderObject root) {
    final (html, head, body) = createDocumentStructure(root);

    var base = head.children.findWhere((c) => c is MarkupRenderElement && c.tag == 'base');
    if (base == null) {
      head.children.insertAfter(head.createChildRenderElement('base')..attributes = {'href': '/'});
    }

    var doctype = root.children.findWhere((r) => r is MarkupRenderText && r.text.startsWith('<!DOCTYPE') && r.rawHtml);
    if (doctype == null) {
      root.children.insertAfter(root.createChildRenderText('<!DOCTYPE html>')..rawHtml = true);
    }

    return (html, head, body);
  }
}
