import 'dart:convert';

import '../../../server.dart';
import '../../dom/validator.dart';

void initSyncState(SyncStateMixin<StatefulComponent, Object?> element) {
  if (element.context.binding case final ServerAppBinding b) {
    b.addRenderAdapter(SyncAdapter(element, element.context as Element));
  }
}

class SyncAdapter extends ElementBoundaryAdapter {
  SyncAdapter(this.sync, super.element);

  final SyncStateMixin<StatefulComponent, Object?> sync;

  @override
  void applyBoundary(ChildListRange range) {
    final value = sync.getState();
    if (value == null) return;
    final data = const DomValidator().escapeMarkerText(jsonEncode(value));
    range.start.insertNext(ChildNodeData(MarkupRenderText('<!--${DomValidator.syncMarkerPrefix}$data-->', true)));
  }
}
