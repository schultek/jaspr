import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:meta/meta.dart';

import '../foundation/basic_types.dart';
import '../foundation/binding.dart';
import '../framework/framework.dart';
import 'dom_render_object.dart';
import 'js_data.dart';

class BrowserAppBinding extends AppBinding with ComponentsBinding {
  @override
  bool get isClient => true;

  late final String _baseOrigin = () {
    final base = document.querySelector('head>base') as BaseElement?;
    return base?.href ?? window.location.origin;
  }();

  @override
  Uri get currentUri {
    if (_baseOrigin.length > window.location.href.length) {
      return Uri(path: '/');
    }
    var pathWithoutOrigin = window.location.href.substring(_baseOrigin.length);
    if (!pathWithoutOrigin.startsWith('/')) {
      pathWithoutOrigin = '/$pathWithoutOrigin';
    }
    return Uri.parse(pathWithoutOrigin);
  }

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
    if (attachBetween case (final start, final end)) {
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
    final stateData = loadSyncState();
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
  Future<Map<String, dynamic>> fetchState(String url) async {
    return window
        .fetch(url, {
          'headers': {'jaspr-mode': 'data-only'}
        })
        // ignore: avoid_dynamic_calls
        .then((result) => result.text() as String)
        .then((data) => jsonDecode(data) as Map<String, dynamic>);
  }

  @override
  void scheduleFrame(VoidCallback frameCallback) {
    // We want the build to trigger asynchronously (to batch updates), but as soon as possible.
    // Microtasks are run before other tasks or events.
    scheduleMicrotask(frameCallback);
  }

  static late Future<void> Function({Function? runApp}) warmupFlutterEngine;
}
