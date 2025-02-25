import 'dart:convert';

import '../../../server.dart';
import '../marker_utils.dart';

void initSyncState(SyncStateMixin element) {
  if (element.context.binding case ServerAppBinding b) {
    b.addRenderAdapter(SyncAdapter(element, element.context as Element));
  }
}

class SyncAdapter extends ElementBoundaryAdapter {
  SyncAdapter(this.sync, super.element);

  final SyncStateMixin sync;

  @override
  void applyBoundary(ChildListRange range) {
    var value = sync.getState();
    if (value == null) return;
    var data = escapeMarkerText(jsonEncode(value));
    range.start.insertNext(ChildNodeData(MarkupRenderObject()..updateText('<!--$syncMarkerPrefix$data-->', true)));
  }
}
