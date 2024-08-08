import 'dart:convert';

import '../../../server.dart';

void initSyncState(SyncStateMixin element) {
  (element.context.binding as ServerAppBinding).addRenderAdapter(SyncAdapter(element, element.context as Element));
}

class SyncAdapter extends ElementBoundaryAdapter {
  SyncAdapter(this.sync, super.element);

  final SyncStateMixin sync;

  @override
  void applyBoundary(ChildListRange range) {
    var value = sync.getState();
    if (value == null) return;
    var data = HtmlEscape(HtmlEscapeMode(escapeLtGt: true)).convert(jsonEncode(value));
    range.start.insertNext(ChildNodeData(MarkupRenderObject()..updateText('<!--\$ =$data-->', true)));
  }
}
