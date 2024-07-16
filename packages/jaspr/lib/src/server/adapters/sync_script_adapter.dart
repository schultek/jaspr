import 'dart:convert';

import '../../../jaspr.dart';
import '../markup_render_object.dart';
import 'head_scope_adapter.dart';

class SyncScriptAdapter extends HeadScopeAdapter {
  SyncScriptAdapter(this.getData);

  final Map<String, dynamic> Function() getData;

  @override
  void applyHead(MarkupRenderObject head) {
    final state = getData();
    final jasprConfig = {
      if (state.isNotEmpty) 'sync': kDebugMode ? state : stateCodec.encode(state),
    };

    final source = 'window.jaspr = ${const JsonEncoder.withIndent(kDebugMode ? '  ' : null).convert(jasprConfig)};';

    head.children.insertBefore(
      head.createChildRenderObject()
        ..tag = 'script'
        ..children.insertAfter(head.createChildRenderObject()..updateText(source, true))
        ..updateElement('script', null, null, null, null, null),
    );
  }
}
