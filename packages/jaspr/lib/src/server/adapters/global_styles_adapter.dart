import '../../../server.dart';

class GlobalStylesAdapter extends HeadScopeAdapter {
  @override
  bool applyHead(MarkupRenderObject head) {
    var styles = binding.options.styles?.call() ?? [];
    if (styles.isEmpty) {
      return false;
    }

    head.children.insertBefore(
      head.createChildRenderObject()
        ..updateElement('style', null, null, null, null, null)
        ..children.insertBefore(head.createChildRenderObject()..updateText(styles.render(), true)),
    );

    return true;
  }
}
