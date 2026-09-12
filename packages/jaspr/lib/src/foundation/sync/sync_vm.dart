import 'dart:convert';

import '../../../server.dart';
import '../../dom/validator.dart';

void initSyncState(SyncStateMixin<StatefulComponent, Object?> element) {
  if (element.context.binding case final ServerAppBinding b) {
    b.addRenderAdapter(_SyncAdapter(element, element.context as Element));
  }
}

final class _SyncAdapter extends ElementBoundaryAdapter {
  _SyncAdapter(this.sync, super.element);

  final SyncStateMixin<StatefulComponent, Object?> sync;

  @override
  void applyBoundary(ChildListRange range) {
    final value = sync.getState();
    if (value == null) return;
    final data = const DomValidator().escapeMarkerText(jsonEncode(value));
    range.start.insertNext(ChildNodeData(MarkupRenderText('<!--${DomValidator.syncMarkerPrefix}$data-->', true)));
  }
}
