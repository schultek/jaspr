import '../../../server.dart';

class GlobalStylesAdapter extends HeadScopeAdapter {
  GlobalStylesAdapter(this.binding);

  final ServerAppBinding binding;

  @override
  bool applyHead(MarkupRenderObject head) {
    var styles = binding.options.styles?.call() ?? [];
    if (styles.isEmpty) {
      return false;
    }

    head.children.insertBefore(
      head.createChildRenderElement()
        ..update('style', null, null, null, null, null)
        ..children.insertBefore(head.createChildRenderText()..update(styles.render(), true)),
    );

    return true;
  }
}
