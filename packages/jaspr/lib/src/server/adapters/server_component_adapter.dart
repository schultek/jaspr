import '../../dom/validator.dart';
import '../../framework/framework.dart';
import '../components/client_component_registry.dart';
import '../markup_render_object.dart';
import 'element_boundary_adapter.dart';

final class ServerComponentAdapter extends ElementBoundaryAdapter {
  ServerComponentAdapter(this.registry, this.id, super.element)
    : super(priority: ElementBoundaryAdapter.serverComponentBoundaryPriority);

  final ClientComponentRegistryElement registry;
  final int id;

  @override
  void applyBoundary(ChildGroup group) {
    _applyParamsToSubtree(element);

    final startMarker = MarkupRenderText('<!--s${DomValidator.clientMarkerPrefix}$id-->', true);
    final endMarker = MarkupRenderText('<!--/s${DomValidator.clientMarkerPrefix}$id-->', true);

    group.children.insertAfter(startMarker);
    group.children.insertBefore(endMarker);
  }

  void _applyParamsToSubtree(Element element) {
    if (registry.clientBoundaries.contains(element)) {
      return;
    }
    if (element is DomElement) {
      if (element.appliedDiff case final diff?) {
        if (element.renderObject case final MarkupRenderElement renderObject) {
          (renderObject.attributes ??= {})['data-j-apply'] = diff;
        }
      }
    }
    element.visitChildren(_applyParamsToSubtree);
  }
}
