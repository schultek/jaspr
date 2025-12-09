import '../../../server.dart';
import '../../dom/styles/rules.dart' show StyleRulesRender;

class GlobalStylesAdapter extends HeadScopeAdapter {
  GlobalStylesAdapter(this.binding);

  final ServerAppBinding binding;

  @override
  bool applyHead(MarkupRenderObject head) {
    final styles = binding.options.styles?.call() ?? [];
    if (styles.isEmpty) {
      return false;
    }

    head.children.insertBefore(
      head.createChildRenderElement('style')..children.insertBefore(head.createChildRenderText(styles.render(), true)),
    );

    return true;
  }
}
