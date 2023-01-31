@JS()
library flutter_interop;

import 'dart:html';

import 'package:js/js.dart';

void runFlutterApp({required String attachTo}) {
  var target = querySelector(attachTo);

  flutter.loader
      .loadEntrypoint(LoadEntrypointOptions(
    entrypointUrl: 'main.dart.js',
    onEntrypointLoaded: allowInterop((engineInitializer) {
      return engineInitializer
          .initializeEngine(InitializeEngineOptions(hostElement: target!))
          .then(allowInterop((runner) => runner.runApp()))
          .then(allowInterop((_) => window.document.dispatchEvent(Event('dart-app-ready'))));
    }),
  ))
      .then(allowInterop((_) {
    // Normally this module would be set as 'data-main' for require.js by main.dart.js,
    // however since the script is already loaded this has no effect and we have to require
    // this module manually.
    require(['main_module.bootstrap']);
  }));
}

@JS()
external void Function(List<String>) require;

@JS('_flutter')
external FlutterInterop get flutter;

@JS()
class FlutterInterop {
  external factory FlutterInterop();

  external FlutterLoader get loader;
}

@JS()
class FlutterLoader {
  external factory FlutterLoader();

  external Promise<dynamic> loadEntrypoint(LoadEntrypointOptions options);
}

typedef OnEntrypointLoaded = Promise<void> Function(EngineInitializer engineInitializer);

@JS()
@anonymous
class LoadEntrypointOptions {
  external factory LoadEntrypointOptions({
    String? entrypointUrl,
    OnEntrypointLoaded? onEntrypointLoaded,
  });
}

@JS()
class EngineInitializer {
  external factory EngineInitializer();

  external Promise<AppRunner> initializeEngine(InitializeEngineOptions options);
}

@JS()
@anonymous
class InitializeEngineOptions {
  external factory InitializeEngineOptions({
    Element? hostElement,
  });
}

@JS()
class AppRunner {
  external factory AppRunner();

  external Promise<void> runApp();
}

@JS()
class Promise<T> {
  external Promise(void executor(void resolve(T result), Function reject));
  external Promise then(void onFulfilled(T result), [Function onRejected]);
}
