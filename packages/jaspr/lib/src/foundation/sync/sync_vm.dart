import 'dart:convert';

import '../../../server.dart';

void initSyncState<T extends StatefulComponent, U>(SyncStateMixin<T, U> element) {
  if (element.context.binding case ServerAppBinding b) {
    b.addRenderAdapter(SyncAdapter(element, element.context as Element));
  }
}

class SyncAdapter<T extends StatefulComponent, U> extends ElementBoundaryAdapter {
  SyncAdapter(this.sync, super.element);

  final SyncStateMixin<T, U> sync;

  @override
  void applyBoundary(ChildListRange range) {
    var value = sync.getState();
    if (value == null) return;
    var data = const DomValidator().escapeMarkerText(jsonEncode(value));
    range.start.insertNext(ChildNodeData(MarkupRenderText('<!--${DomValidator.syncMarkerPrefix}$data-->', true)));
  }
}
