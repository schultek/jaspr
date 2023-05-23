import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:meta/meta.dart';

import '../foundation/basic_types.dart';
import '../foundation/binding.dart';
import '../framework/framework.dart';
import 'dom_renderer.dart';
import 'js_data.dart';

/// Global component binding for the browser
class BrowserAppBinding extends AppBinding with ComponentsBinding {
  @override
  bool get isClient => true;

  @override
  Uri get currentUri => Uri.parse(window.location.toString());

  @override
  Future<void> attachRootComponent(Component app, {required String attachTo}) {
    _loadRawState();
    return super.attachRootComponent(app, attachTo: attachTo);
  }

  @override
  Renderer attachRenderer(String target, {int? from, int? to}) {
    return BrowserDomRenderer(document.querySelector(target)!, from, to);
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
    return window
        .fetch(url, {
          'headers': {'jaspr-mode': 'data-only'}
        })
        .then((result) => result.text())
        .then((data) => jsonDecode(data));
  }

  @override
  void scheduleFrame(VoidCallback frameCallback) {
    // This seems to give the best results over futures and microtasks
    // Needs to be inspected in more detail
    window.requestAnimationFrame((highResTime) {
      frameCallback();
    });
  }
}
