import '../../../server.dart';
import '../../dom/styles/rules.dart' show StyleRulesRender;

class GlobalStylesAdapter extends HeadScopeAdapter {
  GlobalStylesAdapter(this.binding);

  final ServerAppBinding binding;

  @override
  bool applyHead(MarkupRenderObject head) {
    var stylesId = binding.options.stylesId;
    if (stylesId != null) {
      // Use absolute path if no base tag is present, otherwise relative to the base.
      final base = head.children.findWhere<MarkupRenderElement>((c) => c.tag == 'base');
      if (base == null) {
        stylesId = '/$stylesId';
      }

      head.children.insertBefore(
        head.createChildRenderElement('link')..attributes = {'rel': 'stylesheet', 'href': stylesId},
      );
      return true;
    }

    final styles = binding.options.styles?.call() ?? [];
    if (styles.isNotEmpty) {
      head.children.insertBefore(
        head.createChildRenderElement('style')
          ..children.insertBefore(head.createChildRenderText(styles.render(), true)),
      );
      return true;
    }

    return false;
  }
}
