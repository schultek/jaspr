import '../../dom/validator.dart';
import '../markup_render_object.dart';
import 'element_boundary_adapter.dart';

final class ServerComponentAdapter extends ElementBoundaryAdapter {
  ServerComponentAdapter(this.id, super.element)
    : super(priority: ElementBoundaryAdapter.serverComponentBoundaryPriority);

  final int id;

  @override
  void applyBoundary(ChildGroup group) {
    final startMarker = MarkupRenderText('<!--s${DomValidator.clientMarkerPrefix}$id-->', true);
    final endMarker = MarkupRenderText('<!--/s${DomValidator.clientMarkerPrefix}$id-->', true);

    group.children.insertAfter(startMarker);
    group.children.insertBefore(endMarker);
  }
}
