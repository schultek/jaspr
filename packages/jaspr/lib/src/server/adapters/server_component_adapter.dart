import '../../foundation/marker_utils.dart';
import '../markup_render_object.dart';
import 'element_boundary_adapter.dart';

class ServerComponentAdapter extends ElementBoundaryAdapter {
  ServerComponentAdapter(this.id, super.element);

  final int id;

  @override
  void applyBoundary(ChildListRange range) {
    range.start.insertNext(ChildNodeData(MarkupRenderObject()..updateText('<!--s$componentMarkerPrefix$id-->', true)));
    range.end.insertPrev(ChildNodeData(MarkupRenderObject()..updateText('<!--/s$componentMarkerPrefix$id-->', true)));
  }
}
