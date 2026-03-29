import 'dart:math';

import '../markup_render_object.dart';
import '../server_binding.dart';
import 'document_adapter.dart';

class DebugInfoAdapter extends RenderAdapter with DocumentStructureMixin {
  DebugInfoAdapter(this.uniqueId);

  static String createId() => Random().nextInt(0xffffffff).toRadixString(16);

  final String uniqueId;

  @override
  void apply(MarkupRenderObject root) {
    final (_, head, _) = createDocumentStructure(root);

    head.children.insertAfter(
      head.createChildRenderElement('meta')..update(null, null, null, {
        'name': 'jaspr-devtools-id',
        'content': uniqueId,
      }, null),
    );
  }
}
