// ignore_for_file: avoid_web_libraries_in_flutter
@JS()
library;

import 'dart:async';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart' as flt;
import 'package:web/web.dart';

import 'multi_view_app.dart';
import 'view_constraints.dart';

Map<int, flt.Widget> _viewWidgets = {};

Future<void> _flutterApp = Future(() async {
  await ui_web.bootstrapEngineServices(
    jsConfiguration: ui_web.EngineConfiguration(
      multiViewEnabled: true,
      renderer: 'canvaskit',
    ),
  );
  await ui_web.bootstrapEngineUi();
  flt.runWidget(MultiViewApp(viewBuilder: (viewId) => _viewWidgets[viewId]));
});

Future<void> preloadEngine() => _flutterApp;

final viewManager = ui_web.engineDispatcher.viewManager;

Future<int> addView(Element target, ViewConstraints? constraints, flt.Widget widget) async {
  await _flutterApp;
  final id = viewManager
      .createAndRegisterView(ViewOptions(hostElement: target, viewConstraints: constraints) as ui_web.ViewOptions)
      .viewId;
  _viewWidgets[id] = widget;
  return id;
}

Future<void> removeView(int viewId) async {
  await _flutterApp;
  viewManager.disposeAndUnregisterView(viewId);
}

extension type ViewOptions._(JSObject _) {
  external ViewOptions({Element? hostElement, JSAny? initialData, ViewConstraints? viewConstraints});
}
