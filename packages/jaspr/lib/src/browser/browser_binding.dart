import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:meta/meta.dart';

import '../foundation/basic_types.dart';
import '../foundation/binding.dart';
import '../framework/framework.dart';
import 'dom_render_object.dart';
import 'js_data.dart';

/// Global component binding for the browser
class BrowserAppBinding extends AppBinding with ComponentsBinding {
  @override
  bool get isClient => true;

  late final String _baseOrigin = (document.querySelector('head>base') as BaseElement?)?.href ?? window.location.origin;

  @override
  Uri get currentUri => Uri.parse(window.location.href.substring(_baseOrigin.length));

  late String attachTarget;
  late (Node, Node)? attachBetween;

  @override
  Future<void> attachRootComponent(Component app, {String attachTo = 'body', (Node, Node)? attachBetween}) {
    _loadRawState();
    attachTarget = attachTo;
    this.attachBetween = attachBetween;
    return super.attachRootComponent(app);
  }

  @override
  RenderObject createRootRenderObject() {
    if (attachBetween case (var start, var end)) {
      return RootDomRenderObject.between(start, end);
    } else {
      return RootDomRenderObject(document.querySelector(attachTarget)!);
    }
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

  static late Future<void> Function({Function? runApp}) warmupFlutterEngine;
}
