import 'dart:convert';

import '../../../client.dart';
import '../../dom/type_checks.dart';
import '../../dom/validator.dart';

final _syncRegex = RegExp('^${DomValidator.syncMarkerPrefixRegex}(.*)\$');

void initSyncState(SyncStateMixin<StatefulComponent, Object?> sync) {
  final r = (sync.context as Element).parentRenderObjectElement?.renderObject as DomRenderObject?;
  if (r == null) return;

  bool isNext = true;
  final syncMarker = r.retakeNode((node) {
    if (!isNext || node.isText) {
      return false;
    }
    if (node.isComment) {
      final value = node.nodeValue ?? '';
      return _syncRegex.hasMatch(value);
    } else {
      isNext = false;
    }
    return false;
  });

  if (syncMarker != null) {
    syncMarker.parentNode?.removeChild(syncMarker);

    final data = const DomValidator().unescapeMarkerText(_syncRegex.firstMatch(syncMarker.nodeValue ?? '')!.group(1)!);
    sync.updateState(jsonDecode(data));
  }
}
