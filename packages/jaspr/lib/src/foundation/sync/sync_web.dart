import 'dart:convert';
import 'dart:html' as html;

import '../../../browser.dart';
import '../marker_utils.dart';

final _syncRegex = RegExp('^$syncMarkerPrefixRegex(.*)\$');

void initSyncState(SyncStateMixin sync) {
  var r = (sync.context as Element).parentRenderObjectElement?.renderObject as DomRenderObject?;
  if (r == null) return;
  for (var node in r.toHydrate) {
    if (node is html.Text) {
      continue;
    }
    if (node is html.Comment) {
      var value = node.nodeValue ?? '';
      var match = _syncRegex.firstMatch(value);

      if (match == null) continue;

      r.toHydrate.remove(node);
      node.remove();

      var data = unescapeMarkerText(match.group(1)!);
      sync.updateState(jsonDecode(data));
      break;
    }
    break;
  }
}
