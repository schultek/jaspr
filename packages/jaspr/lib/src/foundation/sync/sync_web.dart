import 'dart:convert';
import 'dart:js_interop';

import '../../../browser.dart';
import '../../foundation/type_checks.dart';

final _syncRegex = RegExp('^${DomValidator.syncMarkerPrefixRegex}(.*)\$');

void initSyncState(SyncStateMixin sync) {
  var r = (sync.context as Element).parentRenderObjectElement?.renderObject as DomRenderObject?;
  if (r == null) return;
  for (var node in r.toHydrate) {
    if (node.isText) {
      continue;
    }
    if (node.instanceOfString("Comment")) {
      var value = node.nodeValue ?? '';
      var match = _syncRegex.firstMatch(value);

      if (match == null) continue;

      r.toHydrate.remove(node);
      node.parentNode?.removeChild(node);

      var data = const DomValidator().unescapeMarkerText(match.group(1)!);
      sync.updateState(jsonDecode(data));
      break;
    }
    break;
  }
}
