import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:meta/meta.dart';
import 'package:web/web.dart';

import '../foundation/basic_types.dart';
import '../foundation/binding.dart';
import '../framework/framework.dart';
import 'dom_render_object.dart';
import 'js_data.dart';

final _queryReg = RegExp(r'^(.*?)(?:\((\d+):(\d+)\))?$');

/// Global component binding for the browser
class BrowserAppBinding extends AppBinding with ComponentsBinding {
  @override
  bool get isClient => true;

  @override
  Uri get currentUri => Uri.parse(window.location.href.substring(window.location.origin.length));

  late String attachTarget;

  @override
  Future<void> attachRootComponent(Component app, {String attachTo = 'body'}) {
    _loadRawState();
    attachTarget = attachTo;
    return super.attachRootComponent(app);
  }

  @override
  RenderObject createRootRenderObject() {
    var attachMatch = _queryReg.firstMatch(attachTarget)!;
    var target = attachMatch.group(1)!;
    var from = int.tryParse(attachMatch.group(2) ?? '');
    var to = int.tryParse(attachMatch.group(3) ?? '');

    return RootDomRenderObject(document.querySelector(target)!, from, to);
  }

  final Map<String, dynamic> _rawState = {};

  @protected
  @visibleForOverriding
  Map<String, dynamic>? loadSyncState() {
    return jasprConfig.sync;
  }

  void _loadRawState() {
    var stateData = loadSyncState();
    if (stateData != null) {
      _rawState.addAll(stateData);
    }
  }

  @override
  void updateRawState(String id, dynamic state) {
    _rawState[id] = state;
  }

  @override
  dynamic getRawState(String id) {
    return _rawState[id];
  }

  @override
  Future<Map<String, dynamic>> fetchState(String url) {
    return (window.fetch(
            url as dynamic,
            {
              'headers': {'jaspr-mode': 'data-only'}
            } as dynamic) as dynamic)
        .then((result) => result.text())
        .then((data) => jsonDecode(data));
  }

  @override
  void scheduleFrame(VoidCallback frameCallback) {
    // This seems to give the best results over futures and microtasks
    // Needs to be inspected in more detail
    window.requestAnimationFrame(((JSAny _) {
      frameCallback();
    }).toJS);
  }

  static late Future<void> Function({Function? runApp}) warmupFlutterEngine;
}
