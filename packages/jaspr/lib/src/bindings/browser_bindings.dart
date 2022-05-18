import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:domino/browser.dart' as domino;

import '../foundation/binding.dart';
import '../foundation/sync.dart';
import '../framework/framework.dart';
import '../scheduler/binding.dart';

/// Main entry point for the browser app
void runApp(Component app, {String attachTo = 'body'}) {
  AppBinding.ensureInitialized().attachRootComponent(app, attachTo: attachTo);
}

/// Global component binding for the browser
class AppBinding extends BindingBase with ComponentsBinding, SyncBinding, SchedulerBinding {
  static AppBinding ensureInitialized() {
    if (ComponentsBinding.instance == null) {
      AppBinding();
    }
    return ComponentsBinding.instance! as AppBinding;
  }

  @override
  void initInstances() {
    super.initInstances();
    _loadRawState();
  }

  @override
  bool get isClient => true;

  @override
  void didAttachRootElement(BuildScheduler element, {required String to}) {
    element.view = registerView(document.querySelector(to)!, element.render, true);
  }

  @override
  DomView registerView(dynamic root, DomBuilderFn builderFn, bool initialRender) {
    return domino.registerView(root: root, builderFn: builderFn, skipInitialUpdate: !initialRender);
  }

  @override
  Uri get currentUri => Uri.parse(window.location.toString());

  final Map<String, dynamic> _rawState = {};

  void _loadRawState() {
    var stateData = document.body!.attributes.remove('state-data');
    if (stateData != null) {
      _rawState.addAll(stateCodec.decode(stateData).cast<String, dynamic>());
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
  void scheduleBuild() {
    // This seems to give the best results over futures and microtasks
    // Needs to be inspected in more detail
    window.requestAnimationFrame((highResTime) {
      buildOwner.performBuild();
    });
  }
}
