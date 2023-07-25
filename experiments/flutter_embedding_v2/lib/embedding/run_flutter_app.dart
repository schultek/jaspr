// ignore_for_file: avoid_web_libraries_in_flutter
@JS()
library flutter_interop;

import 'dart:async';
import 'dart:html';

import 'package:jaspr/browser.dart' show kDebugMode;
import 'package:js/js.dart';

/// Starts a flutter app and attaches it to the [attachTo] dom element.
Future<void> runFlutterApp({required String attachTo}) {
  var completer = Completer();

  var target = querySelector(attachTo);

  flutter ??= FlutterInterop();
  flutter!.loader ??= FlutterLoader();

  flutter!.loader!.didCreateEngineInitializer = allowInterop((engineInitializer) {
    return engineInitializer
        .initializeEngine(InitializeEngineOptions(hostElement: target!))
        .then(allowInterop((runner) => runner.runApp()))
        .then(allowInterop((_) {
      completer.complete();
    }));
  });

  if (kDebugMode) {
    require(['main_module.bootstrap']);
  } else {
    var script = document.createElement('script')
      ..attributes.addAll({
        'src': 'main.dart.js',
      });
    document.head!.append(script);
  }

  return completer.future;
}

/// Handle to the [require()] function from RequireJS
@JS()
external void Function(List<String>) require;

/// Handle to the [_flutter] object defined by the 'flutter.js' script.
@JS('_flutter')
external FlutterInterop? flutter;

// Below are some js bindings to interact with the flutter loader script
// from dart in a type-safe way.

@JS()
@anonymous
class FlutterInterop {
  external factory FlutterInterop();

  external FlutterLoader? loader;
}

@JS()
@anonymous
class FlutterLoader {
  external factory FlutterLoader();

  external Promise<dynamic> loadEntrypoint(LoadEntrypointOptions options);

  external OnEntrypointLoaded? didCreateEngineInitializer;
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
