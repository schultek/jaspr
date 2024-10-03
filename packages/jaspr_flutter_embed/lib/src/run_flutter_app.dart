// ignore_for_file: avoid_web_libraries_in_flutter
@JS()
library flutter_interop;

import 'dart:async';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart' as flt;
import 'package:web/web.dart';

import 'multi_view_app.dart';
import 'view_constraints.dart';

Map<int, flt.Widget> _viewWidgets = {};

Future<FlutterApp> _flutterApp = Future(() {
  final completer = Completer<FlutterApp>();

  flutter!.loader!.didCreateEngineInitializer = (EngineInitializer engineInitializer) {
    return Future(() async {
      var engine = await engineInitializer.initializeEngine(InitializeEngineOptions(multiViewEnabled: true)).toDart;
      var app = await engine.runApp().toDart;
      completer.complete(app);
    }).toJS;
  }.toJS;

  ui_web.bootstrapEngine(runApp: () {
    flt.runWidget(MultiViewApp(viewBuilder: (viewId) => _viewWidgets[viewId]));
  });

  return completer.future;
});

Future<void> preloadEngine() => _flutterApp;

Future<int> addView(Element target, ViewConstraints? constraints, flt.Widget widget) async {
  var app = await _flutterApp;
  var id = app.addView(ViewOptions(hostElement: target, viewConstraints: constraints));
  _viewWidgets[id] = widget;
  return id;
}

Future<void> removeView(int viewId) async {
  var app = await _flutterApp;
  app.removeView(viewId);
}

/// Handle to the [_flutter] object defined by the 'flutter.js' script.
@JS('_flutter')
external FlutterInterop? flutter;

// Below are some js bindings to interact with the flutter loader script
// from dart in a type-safe way.

extension type FlutterInterop._(JSObject _) {
  external FlutterInterop({FlutterLoader? loader});

  external FlutterLoader? loader;
}

extension type FlutterLoader._(JSObject _) {
  external FlutterLoader({JSFunction? didCreateEngineInitializer});

  external JSPromise<JSAny?> load(LoadOptions options);

  external JSFunction? didCreateEngineInitializer;
}

extension type LoadOptions._(JSObject _) {
  external LoadOptions({
    String? entrypointUrl,
    JSFunction? onEntrypointLoaded,
  });
}

extension type EngineInitializer._(JSObject _) {
  external EngineInitializer();

  external JSPromise<AppRunner> initializeEngine(InitializeEngineOptions options);
}

extension type InitializeEngineOptions._(JSObject _) {
  external InitializeEngineOptions({
    Element? hostElement,
    bool? multiViewEnabled,
  });
}

extension type AppRunner._(JSObject _) implements JSObject {
  external AppRunner();

  external JSPromise<FlutterApp> runApp();
}

extension type ViewOptions._(JSObject _) {
  external ViewOptions({Element? hostElement, JSAny? initialData, ViewConstraints? viewConstraints});
}

extension type FlutterApp._(JSObject _) implements JSObject {
  external int addView(ViewOptions options);

  external void removeView(int viewId);
}
