@JS()
library flutter_interop;

import 'dart:html';

import 'package:js/js.dart';

/// Starts a flutter app and attaches it to the [attachTo] dom element.
void runFlutterApp({required String attachTo}) {
  var target = querySelector(attachTo);
  var promise = flutter.loader.loadEntrypoint(LoadEntrypointOptions(
    entrypointUrl: 'main.dart.js',
    onEntrypointLoaded: allowInterop((engineInitializer) {
      return engineInitializer
          .initializeEngine(InitializeEngineOptions(hostElement: target!))
          .then(allowInterop((runner) => runner.runApp()))
          .then(allowInterop((_) {
        // We have to manually dispatch this event to hide the loader bar.
        window.document.dispatchEvent(Event('dart-app-ready'));
      }));
    }),
  ));

  // This promise will resolve once the 'main.dart.js' file is fetched, but before the
  // [onEntrypointLoaded] callback is called.
  promise.then(allowInterop((_) {
    // Normally this module would be set as 'data-main' for require.js by 'main.dart.js' and
    // loaded automatically, however since the script is already loaded for 'main_jaspr.dart.js'
    // this has no effect and we have to require this module manually.
    require(['main_module.bootstrap']);
    // By requiring this, flutter will continue to initialize and eventually call [onEntrypointLoaded].
  }));
}

/// Handle to the [require()] function from RequireJS
@JS()
external void Function(List<String>) require;

/// Handle to the [_flutter] object defined by the 'flutter.js' script.
@JS('_flutter')
external FlutterInterop get flutter;

// Below are some js bindings to interact with the flutter loader script
// from dart in a type-safe way.

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
