import '../markup_render_object.dart';
import '../server_binding.dart';

class DocumentAdapter extends RenderAdapter {
  @override
  void apply(MarkupRenderObject root) {
    var html = root.children.where((c) => c.tag == 'html').firstOrNull;
    if (html == null) {
      var children = root.children;
      root.children = [
        html = root.createChildRenderObject()
          ..tag = 'html'
          ..children = children,
      ];
    }

    var head = html.children.where((c) => c.tag == 'head').firstOrNull;
    var body = html.children.where((c) => c.tag == 'body').firstOrNull;
    var rest = html.children.where((c) => c != head && c != body).toList();

    print("HEAD $head BODY $body");

    if (body == null) {
      html.children = [
        head ??= html.createChildRenderObject()..tag = 'head',
        body = html.createChildRenderObject()
          ..tag = 'body'
          ..children = rest,
      ];
    }

    if (head == null) {
      html.children.insert(0, head = html.createChildRenderObject()..tag = 'head');
    }
  }
}
