import '../../../server.dart';
import '../../dom/styles/rules.dart' show StyleRulesRender;
import 'document_structure_helper.dart';

final class GlobalStylesAdapter extends HeadScopeAdapter {
  @override
  bool applyHead(MarkupRenderObject head) {
    var stylesId = binding.options.stylesId;
    if (stylesId != null) {
      // Use a path relative to the base URL if one is set, otherwise from the root.
      if (findBaseWithHref(head) == null) {
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
