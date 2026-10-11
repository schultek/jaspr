// ignore_for_file: avoid_web_libraries_in_flutter
library;

import 'dart:async';
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart' as flt;
import 'package:web/web.dart';

import 'multi_view_app.dart';
import 'view_constraints.dart';

Map<int, flt.Widget> _viewWidgets = {};

Future<void> _flutterEngine = Future(() async {
  await ui_web.bootstrapEngineServices(
    jsConfiguration: ui_web.EngineFlutterConfiguration(
      multiViewEnabled: true,
      renderer: 'canvaskit',
    ),
  );
  await ui_web.bootstrapEngineUi();
  flt.runWidget(MultiViewApp(viewBuilder: (viewId) => _viewWidgets[viewId]));
});

Future<void> preloadEngine() => _flutterEngine;

Future<int> addView(Element target, ViewConstraints? constraints, flt.Widget widget) async {
  await _flutterEngine;
  final id = ui_web.views.addView(
    ui_web.EngineFlutterViewOptions(
      hostElement: target as dynamic,
      viewConstraints: constraints != null
          ? ui_web.EngineViewConstraints(
              minWidth: constraints.minWidth,
              maxWidth: constraints.maxWidth,
              minHeight: constraints.minHeight,
              maxHeight: constraints.maxHeight,
            )
          : null,
    ),
  );
  _viewWidgets[id] = widget;
  return id;
}

Future<void> removeView(int viewId) async {
  await _flutterEngine;
  ui_web.views.removeView(viewId);
  _viewWidgets.remove(viewId);
}
