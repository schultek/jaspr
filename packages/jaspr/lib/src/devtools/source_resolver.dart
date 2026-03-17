import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:universal_web/web.dart' as web;

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
/// The resolution works in two phases:
/// 1. **Synchronous**: Builds a class name → `package:` URI mapping from DDC's
///    module registry (`dart.getModuleNames` / `getModuleLibraries` / `getLibrary`).
/// 2. **Asynchronous**: Fetches the actual Dart source files from the dev server
///    and parses them to find the line number of each class definition.
class SourceResolver {
  SourceResolver() {
    _buildClassMap();
  }

  /// Maps Dart class name → `package:` library URI.
  final Map<String, String> _classToLibrary = {};

  /// Maps library URI → { className → line number }.
  final Map<String, Map<String, int>> _libraryLines = {};

  /// Whether async line number resolution has been initiated.
  bool _linesFetchStarted = false;

  /// Whether async line number resolution has completed.
  bool _linesFetched = false;

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

  /// Returns the source location for a Dart class as `package:…/file.dart:42`
  /// (with line number if resolved, otherwise just the file URI).
  ///
  /// For framework-internal classes (`package:jaspr/…`), returns `null` to avoid
  /// noise in the inspector.
  String? resolveLocation(String className) {
    final libUri = _classToLibrary[className];
    if (libUri == null) return null;

    // Skip framework internals — users don't need to navigate to these.
    if (libUri.startsWith('package:jaspr/')) return null;

    final lines = _libraryLines[libUri];
    if (lines != null && lines.containsKey(className)) {
      return '$libUri:${lines[className]}';
    }

    return libUri;
  }

  /// Whether line numbers have finished loading.
  bool get hasLineNumbers => _linesFetched;

  /// Returns a map of all non-framework class names to their source locations.
  Map<String, String> buildClassLocations() {
    final map = <String, String>{};
    for (final entry in _classToLibrary.entries) {
      final loc = resolveLocation(entry.key);
      if (loc != null) map[entry.key] = loc;
    }
    return map;
  }

  /// Asynchronously fetches source files from the dev server to resolve
  /// class definition line numbers.
  ///
  /// Safe to call multiple times — only the first call triggers fetching.
  Future<void> fetchLineNumbers() async {
    if (_linesFetchStarted) return;
    _linesFetchStarted = true;

    // Collect unique non-framework library URIs.
    final uniqueLibs = <String>{};
    for (final libUri in _classToLibrary.values) {
      if (libUri.startsWith('package:jaspr/')) continue;
      uniqueLibs.add(libUri);
    }

    for (final libUri in uniqueLibs) {
      // Convert package: URI to the HTTP path served by the DDC dev server.
      final httpPath = libUri.replaceFirst('package:', 'packages/');

      try {
        final response = await web.window.fetch(httpPath.toJS).toDart;
        if (!response.ok) continue;

        final text = (await response.text().toDart).toDart;
        final lines = text.split('\n');
        final lineMap = <String, int>{};

        for (var i = 0; i < lines.length; i++) {
          final match = RegExp(r'^\s*(?:(?:abstract|base|final|interface|sealed|mixin)\s+)*class\s+(\w+)')
              .firstMatch(lines[i]);
          if (match != null) {
            lineMap[match.group(1)!] = i + 1;
          }
        }

        _libraryLines[libUri] = lineMap;
      } catch (_) {
        // Network error or parse error — skip this file.
      }
    }

    _linesFetched = true;
  }
}
