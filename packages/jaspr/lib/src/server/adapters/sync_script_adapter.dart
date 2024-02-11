import 'dart:convert';

import '../../../jaspr.dart';
import '../markup_render_object.dart';
import 'head_scope_adapter.dart';

class SyncScriptAdapter extends HeadScopeAdapter {
  SyncScriptAdapter(this.getData);

  final Map<String, dynamic> Function() getData;

  @override
  void applyHead(MarkupRenderObject head) {
    var state = getData();
    var jasprConfig = {
      if (state.isNotEmpty) 'sync': kDebugMode ? state : stateCodec.encode(state),
    };

    var source = 'window.jaspr = ${JsonEncoder.withIndent(kDebugMode ? '  ' : null).convert(jasprConfig)};';

    head.children.add(
      head.createChildRenderObject()
        ..tag = 'script'
        ..children.add(head.createChildRenderObject()..updateText(source, true))
        ..updateElement('script', null, null, null, null, null),
    );
  }
}
