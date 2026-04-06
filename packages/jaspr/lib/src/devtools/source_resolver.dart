import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// Bindings to DDC's RequireJS `require()` function.
@JS('require')
external JSObject _jsRequire(String moduleName);

/// Binding to JavaScript's `Object.keys()`.
@JS('Object.keys')
external JSArray<JSString> _objectKeys(JSObject obj);

/// Resolves Dart component class names to their source file locations using
/// DDC's runtime module metadata.
///
/// Only available when running under DDC (Dart Development Compiler) in debug
/// mode. In production builds or non-DDC environments, all methods return null.
///
/// Synchronously builds a class name → `package:` URI mapping from DDC's
/// module registry (`dart.getModuleNames` / `getModuleLibraries` / `getLibrary`).
///
/// Line-number resolution is deferred until the Dart SDK provides proper
/// source location APIs. See: https://github.com/dart-lang/sdk/issues/61580
class SourceResolver {
  SourceResolver() {
    _buildClassMap();
  }

  /// Maps Dart class name → `package:` library URI.
  final Map<String, String> _classToLibrary = {};

  /// Synchronously builds the class → library URI map from DDC metadata.
  void _buildClassMap() {
    try {
      final sdk = _jsRequire('dart_sdk');
      final dart = sdk.getProperty<JSObject>('dart'.toJS);

      final moduleNames = dart.callMethod<JSArray<JSString>>('getModuleNames'.toJS);

      for (var i = 0; i < moduleNames.length; i++) {
        final modName = moduleNames[i].toDart;
        if (modName == 'dart_sdk') continue;

        try {
          final libs = dart.callMethod<JSObject>('getModuleLibraries'.toJS, modName.toJS);
          final libKeys = _objectKeys(libs);

          for (var j = 0; j < libKeys.length; j++) {
            final libUri = libKeys[j].toDart;

            try {
              final lib = dart.callMethod<JSObject>('getLibrary'.toJS, libUri.toJS);
              final exportNames = _objectKeys(lib);

              for (var k = 0; k < exportNames.length; k++) {
                final exportName = exportNames[k].toDart;
                final exported = lib.getProperty(exportName.toJS);
                if (exported != null && exported.typeofEquals('function')) {
                  _classToLibrary[exportName] = libUri;
                }
              }
            } catch (_) {}
          }
        } catch (_) {}
      }
    } catch (_) {
      // Not running in DDC mode — silently fall back.
    }
  }

  /// Returns the `package:` library URI for a Dart class, or `null`.
  String? resolveFile(String className) {
    return _classToLibrary[className];
  }

  /// Returns the source location for a Dart class as `package:…/file.dart`.
  ///
  /// Line numbers are not yet available — they require a Dart SDK change.
  /// See: https://github.com/dart-lang/sdk/issues/61580
  ///
  /// For framework-internal classes (`package:jaspr/…`), returns `null` to avoid
  /// noise in the inspector.
  String? resolveLocation(String className) {
    final libUri = _classToLibrary[className];
    if (libUri == null) return null;

    // Skip framework internals — users don't need to navigate to these.
    if (libUri.startsWith('package:jaspr/')) return null;

    return libUri;
  }

  /// Returns a map of all non-framework class names to their source locations.
  Map<String, String> buildClassLocations() {
    final map = <String, String>{};
    for (final entry in _classToLibrary.entries) {
      final loc = resolveLocation(entry.key);
      if (loc != null) map[entry.key] = loc;
    }
    return map;
  }

  // Line-number fetching removed — requires Dart SDK support.
  // See: https://github.com/dart-lang/sdk/issues/61580
  //
  // When the SDK provides source location APIs, line-number resolution
  // can be re-added here without changing the public interface.
}
