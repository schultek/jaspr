import 'dart:convert';
import 'dart:math';

import '../../foundation/diagnostics.dart';
import '../markup_render_object.dart';
import '../server_binding.dart';
import 'document_adapter.dart';

class DebugInfoAdapter extends RenderAdapter with DocumentStructureMixin {
  DebugInfoAdapter();

  static String createId() => Random().nextInt(0xffffffff).toRadixString(16);

  final String renderId = createId();
  DiagnosticsNode? tree;

  @override
  void apply(MarkupRenderObject root) {
    final (_, head, _) = createDocumentStructure(root);

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
}
