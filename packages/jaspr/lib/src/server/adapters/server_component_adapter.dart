import '../../foundation/validator.dart';
import '../markup_render_object.dart';
import 'element_boundary_adapter.dart';

class ServerComponentAdapter extends ElementBoundaryAdapter {
  ServerComponentAdapter(this.id, super.element);

  final int id;

  @override
  void applyBoundary(ChildListRange range) {
    final startMarker = MarkupRenderText('<!--s${DomValidator.clientMarkerPrefix}$id-->', true);
    final endMarker = MarkupRenderText('<!--/s${DomValidator.clientMarkerPrefix}$id-->', true);

    range.start.insertNext(ChildNodeData(startMarker));
    range.end.insertPrev(ChildNodeData(endMarker));
  }
}
