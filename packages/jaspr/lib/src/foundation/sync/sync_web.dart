import 'dart:convert';
import 'dart:js_interop';

import '../../../browser.dart';

final _syncRegex = RegExp(r'^\$\s=(.*)$');

final _escapeRegex = RegExp(r'&(amp|lt|gt);');

void initSyncState(SyncStateMixin sync) {
  var r = (sync.context as Element).parentRenderObjectElement?.renderObject as DomRenderObject?;
  if (r == null) return;
  for (var node in r.toHydrate) {
    if (node.instanceOfString("Text")) {
      continue;
    }
    if (node.instanceOfString("Comment")) {
      var value = node.nodeValue ?? '';
      var match = _syncRegex.firstMatch(value);

      if (match == null) continue;

      r.toHydrate.remove(node);
      node.parentNode?.removeChild(node);

      var data = match.group(1)!.replaceAllMapped(_escapeRegex,
          (match) => switch (match.group(1)) { 'amp' => '&', 'lt' => '<', 'gt' => '>', _ => match.group(0)! });
      sync.updateState(jsonDecode(data));
      break;
    }
    break;
  }
}
