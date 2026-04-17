import 'dart:async';
import 'dart:convert';
import 'dart:math';

import '../../foundation/diagnostics.dart';
import '../markup_render_object.dart';
import '../server_binding.dart';
import 'document_structure_helper.dart';

class DebugInfoAdapter extends RenderAdapter {
  DebugInfoAdapter() {
    renderId = _createId();
  }

  late String renderId;
  DiagnosticsNode? tree;

  @override
  FutureOr<void> prepare() {
    renderId = _createId();
  }

  @override
  void apply(MarkupRenderObject root) {
    final (body: _, :head, html: _) = createDocumentStructure(root);

    head.children.insertAfter(
      head.createChildRenderElement('meta')..update(null, null, null, {
        'name': 'jaspr-debug-data',
        'content': jsonEncode({
          'renderId': renderId,
          'serverTree': tree?.toJsonMap(),
        }),
      }, null),
    );
  }

  String _createId() => Random().nextInt(0xffffffff).toRadixString(16);
}
