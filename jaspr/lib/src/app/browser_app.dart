import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:domino/browser.dart' hide DomComponent;

import '../framework/framework.dart';

/// Main entry point for the browser app
void runApp(Component Function() setup, {required String id}) {
  BrowserComponentsBinding.ensureInitialized().attachRootComponent(setup(), to: id);
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
      root: document.getElementById(to)!,
      builderFn: element.render,
    );
  }

  @override
  Uri get currentUri => Uri.parse(window.location.toString());

  @override
  FutureOr<void> performRebuild(Element? child) {
    if (child is StatefulElement && child.state is DeferRenderMixin && isFirstBuild) {
      return Future.sync(() async {
        await (child.state as DeferRenderMixin).defer;
        return super.performRebuild(child);
      });
    } else {
      return super.performRebuild(child);
    }
  }

  final Map<String, String> _rawState = {};

  void _loadRawState() {
    var attrs = document.body!.attributes;
    var stateKeys = attrs.keys.where((k) => k.startsWith('data-state-')).toList();
    for (var key in stateKeys) {
      _rawState[key.replaceFirst('data-state-', '')] = attrs.remove(key)!;
    }
  }

  @override
  void updateRawState(String id, String state) {
    _rawState[id] = state;
  }

  @override
  String? getRawState(String id) {
    return _rawState[id];
  }

  @override
  Future<Map<String, String>> fetchState(String url) {
    return window
        .fetch(url, {
          'headers': {'jaspr-mode': 'data-only'}
        })
        .then((result) => result.text())
        .then((data) => (jsonDecode(data) as Map<String, dynamic>).cast());
  }
}
