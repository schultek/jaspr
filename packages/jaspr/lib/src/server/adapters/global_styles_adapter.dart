import '../../../server.dart';

class GlobalStylesAdapter extends HeadScopeAdapter {
  GlobalStylesAdapter(this.binding);

  final ServerAppBinding binding;

  @override
  void applyHead(MarkupRenderObject head) {
    var styles = binding.options.styles?.call() ?? [];
    if (styles.isEmpty) {
      return;
    }

    head.children.insertBefore(
      head.createChildRenderObject()
        ..updateElement('style', null, null, null, null, null)
        ..children.insertBefore(head.createChildRenderObject()..updateText(styles.render(), true)),
    );
  }
}
