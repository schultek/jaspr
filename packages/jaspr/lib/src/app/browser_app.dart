import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:domino/browser.dart' hide DomComponent;

import '../framework/framework.dart';

/// Main entry point for the browser app
void runApp(Component app, {String attachTo = 'body'}) {
  BrowserComponentsBinding.ensureInitialized().attachRootComponent(app, attachTo: attachTo);
}

/// Global component binding for the browser
class BrowserComponentsBinding extends ComponentsBinding {
  static ComponentsBinding ensureInitialized() {
    if (ComponentsBinding.instance == null) {
      BrowserComponentsBinding();
    }
    return ComponentsBinding.instance!;
  }

  BrowserComponentsBinding() {
    _loadRawState();
  }

  @override
  bool get isClient => true;

  @override
  Future<void> didAttachRootElement(BuildScheduler element, {required String to}) async {
    await firstBuild;
    element.view = registerView(
      root: document.querySelector(to)!,
      builderFn: element.render,
    );
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
}
