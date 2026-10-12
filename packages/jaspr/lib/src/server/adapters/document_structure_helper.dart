import '../child_nodes.dart';
import '../markup_render_object.dart';

({MarkupRenderElement html, MarkupRenderElement head, MarkupRenderElement body}) createDocumentStructure(
  MarkupRenderObject root, [
  bool includeDoctype = false,
]) {
  var html = root.children.findWhere<MarkupRenderElement>((c) => c.tag == 'html')?.node as MarkupRenderElement?;
  if (html == null) {
    final range = root.children.range();
    html = root.createChildRenderElement('html');
    html.children.insertNodeAfter(range);
    root.children.insertAfter(html);
  }

  var head = html.children.findWhere<MarkupRenderElement>((c) => c.tag == 'head')?.node as MarkupRenderElement?;
  var body = html.children.findWhere<MarkupRenderElement>((c) => c.tag == 'body')?.node as MarkupRenderElement?;

  if (head == null) {
    head = html.createChildRenderElement('head');
    html.children.insertAfter(head);
  }

  if (body == null) {
    // Find what to keep in `<html>` before its contents move into `<body>`.
    final headContents = _findHeadContents(html.children, head)!.node;

    body = html.createChildRenderElement('body');
    body.children.insertNodeAfter(html.children.range());
    html.children
      ..insertBefore(body)
      ..insertNodeAfter(headContents);
  }

  if (includeDoctype) {
    final doctype = root.children.findWhere<MarkupRenderText>((r) => r.text.startsWith('<!DOCTYPE') && r.rawHtml);
    if (doctype == null) {
      root.children.insertAfter(root.createChildRenderText('<!DOCTYPE html>', true));
    }
  }

  return (html: html, head: head, body: body);
}

/// Finds [head] in [list], or within a fragment in it, and
/// returns its node together with its element boundaries and markers.
///
/// Fragments that contain only the head are included with their own boundaries,
/// so the markers of a component that renders only the head stay around it.
/// The returned `onlyHead` is whether nothing else in [list] renders.
({ChildNode node, bool onlyHead})? _findHeadContents(ChildList list, MarkupRenderElement head) {
  for (final child in list) {
    if (child is MarkupRenderFragment) {
      final found = _findHeadContents(child.children, head);
      if (found == null) continue;
      // Stop at the first fragment that contains more than the head.
      if (!found.onlyHead) return found;
    } else if (child != head) {
      continue;
    }

    final node = list.findWithBoundaries(child)!;
    // Nothing else renders if all render objects in the list are in the node.
    final nodeLength = node is ChildListRange ? node.length : 1;
    return (node: node, onlyHead: list.length == nodeLength);
  }
  return null;
}
