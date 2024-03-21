// ignore_for_file: avoid_web_libraries_in_flutter
@JS()
library flutter_interop;

import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:web/web.dart';

/// Starts a flutter app and attaches it to the [attachTo] dom element.
void runFlutterApp({required String attachTo, required void Function() runApp}) {
  var target = document.querySelector(attachTo);

  flutter ??= FlutterInterop();
  flutter!.loader ??= FlutterLoader();

  flutter!.loader!.didCreateEngineInitializer = ((engineInitializer) {
    return engineInitializer
        .initializeEngine(InitializeEngineOptions(hostElement: target!))
        .toDart
        .then((runner) => runner.runApp())
        .toJS;
  });

  ui_web.bootstrapEngine(runApp: runApp);
}

/// Handle to the [_flutter] object defined by the 'flutter.js' script.
@JS('_flutter')
external FlutterInterop? flutter;

// Below are some js bindings to interact with the flutter loader script
// from dart in a type-safe way.

extension type FlutterInterop._(JSObject _) {
  external FlutterInterop({FlutterLoader? loader});

  external FlutterLoader? get loader;
  external set loader(FlutterLoader? loader);
}

extension type FlutterLoader._(JSObject _) {
  external FlutterLoader({JSFunction? didCreateEngineInitializer});

  @JS("didCreateEngineInitializer")
  external set _didCreateEngineInitializer(JSFunction? fn);

  set didCreateEngineInitializer(OnEntrypointLoaded? callback) {
    _didCreateEngineInitializer = callback?.toJS;
  }
}

typedef OnEntrypointLoaded = JSPromise Function(EngineInitializer engineInitializer);

extension type EngineInitializer._(JSObject _) {
  external JSPromise<AppRunner> initializeEngine(InitializeEngineOptions options);
}

extension type InitializeEngineOptions._(JSObject _) {
  external InitializeEngineOptions({Element? hostElement});
}

extension type AppRunner._(JSObject _) implements JSObject {
  external JSPromise<JSAny> runApp();
}
