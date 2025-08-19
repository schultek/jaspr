import 'dart:convert';

import '../../../browser.dart';
import '../../foundation/type_checks.dart';

final _syncRegex = RegExp('^${DomValidator.syncMarkerPrefixRegex}(.*)\$');

void initSyncState(SyncStateMixin sync) {
  var r = (sync.context as Element).parentRenderObjectElement?.renderObject as DomRenderObject?;
  if (r == null) return;

  bool isNext = true;
  final syncMarker = r.retakeNode((node) {
    if (!isNext) {
      return false;
    }
    isNext = false;
    if (node.isComment) {
      var value = node.nodeValue ?? '';
      return _syncRegex.hasMatch(value);
    }
    return false;
  });

  if (syncMarker != null) {
    syncMarker.parentNode?.removeChild(syncMarker);

    var data = const DomValidator().unescapeMarkerText(_syncRegex.firstMatch(syncMarker.nodeValue ?? '')!.group(1)!);
    sync.updateState(jsonDecode(data));
  }
}
