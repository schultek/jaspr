import 'dart:async';
import 'dart:math';

import '../markup_render_object.dart';
import '../server_binding.dart';
import 'document_structure_helper.dart';

class DebugInfoAdapter extends RenderAdapter {
  DebugInfoAdapter() {
    uniqueId = _createId();
  }

  late String uniqueId;

  @override
  FutureOr<void> prepare() {
    uniqueId = _createId();
  }

  @override
  void apply(MarkupRenderObject root) {
    final (body: _, :head, html: _) = createDocumentStructure(root);

    head.children.insertAfter(
      head.createChildRenderElement('meta')..update(null, null, null, {
        'name': 'jaspr-devtools-id',
        'content': uniqueId,
      }, null),
    );
  }

  String _createId() => Random().nextInt(0xffffffff).toRadixString(16);
}
