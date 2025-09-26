import 'dart:async';
import 'dart:convert';

import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/session.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:collection/collection.dart';
import 'package:watcher/watcher.dart';
import 'package:yaml/yaml.dart';

import '../helpers/daemon_helper.dart';
import '../logging.dart';

class ScopesDomain extends Domain {
  ScopesDomain(Daemon daemon, this.logger) : super(daemon, 'scopes') {
    registerHandler('register', registerScopes);
  }

  final Logger logger;
  AnalysisContextCollection? _collection;
  final List<StreamSubscription<WatchEvent>> _watcherSubscriptions = [];
  final Map<AnalysisContext, bool> _analysisStatus = {};
  final Map<AnalysisContext, InspectData> _inspectedData = {};

  Future<void> registerScopes(
    Map<String, dynamic> params, {
    ResourceProvider? resourceProvider,
  }) async {
    await _collection?.dispose();
    // ignore: avoid_function_literals_in_foreach_calls
    _watcherSubscriptions.forEach((sub) => sub.cancel());
    _watcherSubscriptions.clear();
    _inspectedData.clear();

    final folders = params['folders'] as List<dynamic>;

    _collection = AnalysisContextCollection(
      includedPaths: folders.cast(),
      resourceProvider: resourceProvider ?? PhysicalResourceProvider.INSTANCE,
    );

    if (resourceProvider == null) {
      for (final context in _collection!.contexts) {
        _watcherSubscriptions.add(
          DirectoryWatcher(context.contextRoot.root.path).events.listen((event) {
            final path = event.path;
            logger.write('File changed: $path');

            if (path.endsWith('.dart')) {
              _reanalyze(path);
            } else if (path.endsWith('pubspec.yaml') ||
                path.endsWith('pubspec.lock') ||
                path.endsWith('package_config.json')) {
              // Recreate all scopes if pubspec or package config changes.
              registerScopes(params);
            }
          }),
        );
      }
    }

    for (final context in _collection!.contexts) {
      analyze(context);
    }
  }

  void _reanalyze(String path) {
    for (final context in _collection!.contexts) {
      context.changeFile(path);
      analyze(context, true);
    }
  }

  Future<void> analyze(AnalysisContext context, [bool awaitPendingChanges = false]) async {
    final rootPath = context.contextRoot.root.path;

    try {
      final pubspecFile = context.contextRoot.root.getChildAssumingFile('pubspec.yaml');
      if (!pubspecFile.exists) {
        logger.write('No pubspec.yaml found in $rootPath');
        return;
      }

      try {
        final pubspecYaml = loadYaml(pubspecFile.readAsStringSync()) as YamlMap;

        if (pubspecYaml case {'jaspr': {'mode': 'server' || 'static'}}) {
          // ok
        } else {
          logger.write('Scopes not available in client mode.');
          return;
        }
      } catch (e) {
        logger.write('Failed to read pubspec.yaml in $rootPath: $e');
        return;
      }

      final mainFile = context.contextRoot.root.getChildAssumingFolder('lib').getChildAssumingFile('main.dart');

      if (!mainFile.exists) {
        logger.write('No main.dart found in $rootPath');
        return;
      }

      final sw = Stopwatch()..start();
      logger.write('Analyzing $rootPath...');

      _analysisStatus[context] = true;
      emitStatus();

      if (awaitPendingChanges) {
        await context.applyPendingFileChanges();
        logger.write('Applied pending changes in ${sw.elapsedMilliseconds}ms');
        sw.reset();
      }

      final result = await context.currentSession.getResolvedLibrary(mainFile.path);
      sw.stop();

      if (result is! ResolvedLibraryResult) {
        logger.write('Failed to resolve main.dart in $rootPath');
        return;
      }
      logger.write('Resolved main.dart in ${sw.elapsedMilliseconds}ms');

      bool usesJasprWebCompilers = false;
      try {
        final packagesContent = context.contextRoot.packagesFile?.readAsStringSync();
        final packagesJson = jsonDecode(packagesContent ?? '{}');
        if (packagesJson case {
          'packages': List packages,
        } when packages.any((p) => p['name'] == 'jaspr_web_compilers')) {
          usesJasprWebCompilers = true;
        }
      } catch (_) {
        // Ignore errors in reading packages file.
      }

      final inspectData = await InspectData.analyze(result.element, usesJasprWebCompilers, logger);
      _inspectedData[context] = inspectData;
      emitScopes();
    } on InconsistentAnalysisException catch (e) {
      logger.write('Skipping inconsistent analysis for $rootPath');
    } on Exception catch (e) {
      logger.write('Error analyzing $rootPath: $e');
    } finally {
      _analysisStatus[context] = false;
      emitStatus();
    }
  }

  void emitScopes() {
    final allLibraries = _inspectedData.values.expand((data) => data.libraries.keys).toSet();

    final output = <String, dynamic>{};

    for (final libraryPath in allLibraries) {
      final components = <String>{};
      final clientScopeRoots = <String, InspectTarget>{};
      final serverScopeRoots = <String, InspectTarget>{};

      for (final data in _inspectedData.values) {
        if (data.libraries.containsKey(libraryPath)) {
          final item = data.libraries[libraryPath]!;

          components.addAll(item.components.map((e) => e.name));
          clientScopeRoots.addAll({
            for (final target in item.clientScopeRoots) '${target.path}:${target.name}': target,
          });
          serverScopeRoots.addAll({
            for (final target in item.serverScopeRoots) '${target.path}:${target.name}': target,
          });
        }
      }

      final invalidDependencies = <String, InspectItemDependency>{};

      for (final data in _inspectedData.values) {
        if (data.libraries.containsKey(libraryPath)) {
          final item = data.libraries[libraryPath]!;

          for (final c in item.children) {
            if ((clientScopeRoots.isNotEmpty && c.invalidOnClient != null) ||
                (serverScopeRoots.isNotEmpty && c.invalidOnServer != null)) {
              final uri = c.item.library.uri.toString();
              invalidDependencies[uri] = c;
            }
          }
        }
      }

      if (components.isEmpty && invalidDependencies.isEmpty) {
        continue; // Skip libraries without components or invalid dependencies
      }

      output[libraryPath] = {
        if (components.isNotEmpty) 'components': components.toList(),
        if (components.isNotEmpty && clientScopeRoots.isNotEmpty)
          'clientScopeRoots': clientScopeRoots.values.map((e) => e.toJson()).toList(),
        if (components.isNotEmpty && serverScopeRoots.isNotEmpty)
          'serverScopeRoots': serverScopeRoots.values.map((e) => e.toJson()).toList(),
        if (invalidDependencies.isNotEmpty)
          'invalidDependencies': [
            for (final entry in invalidDependencies.entries)
              {
                'uri': entry.key,
                if (clientScopeRoots.isNotEmpty && entry.value.invalidOnClient != null)
                  'invalidOnClient': entry.value.invalidOnClient!.toJson(),
                if (serverScopeRoots.isNotEmpty && entry.value.invalidOnServer != null)
                  'invalidOnServer': entry.value.invalidOnServer!.toJson(),
              },
          ],
      };
    }

    sendEvent('scopes.result', output);
  }

  void emitStatus() {
    final output = <String, dynamic>{};

    for (final context in _collection!.contexts) {
      final status = _analysisStatus[context] ?? false;
      output[context.contextRoot.root.path] = status;
    }

    sendEvent('scopes.status', output);
  }

  @override
  void dispose() {
    _collection?.dispose();
    // ignore: avoid_function_literals_in_foreach_calls
    _watcherSubscriptions.forEach((sub) => sub.cancel());
    super.dispose();
  }
}

class InspectData {
  InspectData._(this.usesJasprWebCompilers, this.logger);
  static Future<InspectData> analyze(LibraryElement root, bool usesJasprWebCompilers, Logger logger) async {
    final inspectData = InspectData._(usesJasprWebCompilers, logger);

    final mainFunction = root.topLevelFunctions.where((e) => e.name == 'main').firstOrNull?.firstFragment;
    final mainLocation = mainFunction?.libraryFragment.lineInfo.getLocation(
      mainFunction.nameOffset ?? mainFunction.offset,
    );
    final mainTarget = InspectTarget(
      root.firstFragment.source.fullName,
      'main',
      mainLocation?.lineNumber ?? 0,
      mainLocation?.columnNumber ?? 0,
    );

    var data = await inspectData.inspectLibrary(root, null, {}, {mainTarget});
    await data.analyzeChildren();
    return inspectData;
  }

  final bool usesJasprWebCompilers;
  final Logger logger;
  Map<String, InspectDataItem> libraries = {};

  Future<InspectDataItem> inspectLibrary(
    LibraryElement library,
    InspectDataItem? parent, [
    Set<InspectTarget> clientScopeRoots = const {},
    Set<InspectTarget> serverScopeRoots = const {},
  ]) async {
    final path = library.firstFragment.source.fullName;

    if (library.isInSdk ||
        library.identifier.startsWith('package:jaspr/') ||
        library.identifier.startsWith('package:web/')) {
      // Skip SDK and framework libraries.
      return libraries[path] ??= InspectDataItem(library, parent, this);
    }

    if (libraries.containsKey(path)) {
      var data = libraries[path]!;
      bool hasChangedScopes =
          clientScopeRoots.any((e) => !data.clientScopeRoots.contains(e)) ||
          serverScopeRoots.any((e) => !data.serverScopeRoots.contains(e));
      if (hasChangedScopes) {
        data.clientScopeRoots.addAll(clientScopeRoots);
        data.serverScopeRoots.addAll(serverScopeRoots);

        for (final InspectItemDependency(:item, :onClient, :onServer) in data.children) {
          await inspectLibrary(item.library, data, onClient ? clientScopeRoots : {}, onServer ? serverScopeRoots : {});
        }
      }

      return data;
    }

    final data = InspectDataItem(library, parent, this);
    data.clientScopeRoots.addAll(clientScopeRoots);
    data.serverScopeRoots.addAll(serverScopeRoots);

    libraries[path] = data;

    for (final clazz in library.classes) {
      final location = clazz.firstFragment.libraryFragment.lineInfo.getLocation(
        clazz.firstFragment.nameOffset ?? clazz.firstFragment.offset,
      );
      final target = InspectTarget(path, clazz.name ?? '', location.lineNumber, location.columnNumber);
      if (isComponent(clazz)) {
        data.components.add(target);
        if (hasClientAnnotation(clazz)) {
          data.clientScopeRoots.add(target);
        }
      }
    }

    return data;
  }

  bool isComponent(ClassElement clazz) {
    return clazz.allSupertypes.any(
      (e) =>
          e.element.name == 'Component' && e.element.library.identifier == 'package:jaspr/src/framework/framework.dart',
    );
  }

  bool hasClientAnnotation(ClassElement clazz) {
    return clazz.metadata.annotations.any(
      (a) =>
          a.element?.name == 'client' &&
          a.element?.library?.identifier == 'package:jaspr/src/foundation/annotations.dart',
    );
  }

  bool isClientLib(LibraryElement lib) {
    return lib.identifier == 'package:jaspr/browser.dart' ||
        lib.identifier == 'package:web/web.dart' ||
        lib.identifier == 'dart:js_interop' ||
        lib.identifier == 'dart:js_interop_unsafe' ||
        lib.identifier == 'dart:html' ||
        lib.identifier == 'dart:js' ||
        lib.identifier == 'dart:js_util';
  }

  bool isServerLib(LibraryElement lib) {
    return lib.identifier == 'package:jaspr/server.dart' ||
        (!usesJasprWebCompilers && lib.identifier == 'dart:io') ||
        lib.identifier == 'dart:ffi' ||
        lib.identifier == 'dart:isolate' ||
        lib.identifier == 'dart:mirrors';
  }
}

class InspectDataItem {
  InspectDataItem(this.library, this.parent, this.data);

  final LibraryElement library;
  final InspectDataItem? parent;
  final InspectData data;

  final List<InspectTarget> components = [];
  final Set<InspectTarget> clientScopeRoots = {};
  final Set<InspectTarget> serverScopeRoots = {};

  final List<InspectItemDependency> children = [];

  Future<void> analyzeChildren() async {
    final dependencies = await resolveDependencies(library);

    for (final (:lib, :dir, :onClient, :onServer) in dependencies) {
      var child = await data.inspectLibrary(
        lib,
        this,
        onClient ? clientScopeRoots : {},
        onServer ? serverScopeRoots : {},
      );
      var dep = InspectItemDependency(child, dir, onClient, onServer);
      dep.invalidOnClient = onClient && data.isServerLib(lib) ? dir : null;
      dep.invalidOnServer = onServer && data.isClientLib(lib) ? dir : null;
      children.add(dep);
    }

    for (final child in children) {
      if (child.item.children.isNotEmpty) continue; // Already analyzed
      await child.item.analyzeChildren();
    }

    for (final child in children) {
      if (child.item.components.isEmpty) {
        if (child.invalidOnClient == null) {
          var childInvalidOnClient = child.onClient
              ? child.item.children.map((c) => c.invalidOnClient).nonNulls.firstOrNull
              : null;
          if (childInvalidOnClient != null) {
            child.invalidOnClient = child.dir.withTarget(childInvalidOnClient);
            for (var c in child.item.children) {
              c.invalidOnClient = null;
            }
          }
        }

        if (child.invalidOnServer == null) {
          var childInvalidOnServer = child.onServer
              ? child.item.children.map((c) => c.invalidOnServer).nonNulls.firstOrNull
              : null;
          if (childInvalidOnServer != null) {
            child.invalidOnServer = child.dir.withTarget(childInvalidOnServer);
            for (var c in child.item.children) {
              c.invalidOnServer = null;
            }
          }
        }
      }
    }
  }

  Future<List<({LibraryElement lib, DirectiveTarget dir, bool onClient, bool onServer})>> resolveDependencies(
    LibraryElement library,
  ) async {
    if (library.isInSdk ||
        library.identifier.startsWith('package:jaspr/') ||
        library.identifier.startsWith('package:web/')) {
      // Skip SDK and framework libraries.
      return [];
    }

    final result = library.session.getParsedLibraryByElement(library);
    if (result is! ParsedLibraryResult) {
      data.logger.write('Tooling Daemon: Failed to parse library ${library.uri}', level: Level.warning);
      return [];
    }

    final imports = library.fragments.expand((f) => f.libraryImports).toList();
    final exports = library.fragments.expand((f) => f.libraryExports).toList();

    LibraryElement? getBaseLibraryForDirective(NamespaceDirective directive) {
      bool matchesUri(ElementDirective d) => switch (d.uri) {
        DirectiveUriWithRelativeUriString uri => uri.relativeUriString == directive.uri.stringValue,
        _ => false,
      };
      if (directive is ImportDirective) {
        return directive.libraryImport?.importedLibrary ?? imports.where(matchesUri).firstOrNull?.importedLibrary;
      } else if (directive is ExportDirective) {
        return directive.libraryExport?.exportedLibrary ?? exports.where(matchesUri).firstOrNull?.exportedLibrary;
      }
      return null;
    }

    Future<LibraryElement?> resolveLibraryFromUri(String? uri) async {
      if (uri == null) return null;
      final absolutePath = library.session.uriConverter.uriToPath(library.uri.resolve(uri));
      if (absolutePath == null) return null;
      var lib2 = await library.session.getResolvedLibrary(absolutePath);
      if (lib2 is ResolvedLibraryResult) {
        return lib2.element;
      }
      return null;
    }

    final dependencies = <({LibraryElement lib, DirectiveTarget dir, bool onClient, bool onServer})>[];

    for (final unit in result.units) {
      for (final directive in unit.unit.directives) {
        if (directive is NamespaceDirective) {
          final configuration = directive.configurations;

          const clientLibs = ['js_interop', 'js_interop_unsafe', 'html', 'js', 'js_util'];
          const serverLibs = ['io', 'ffi', 'isolate', 'mirrors'];

          final libConfigurations = configuration.where(
            (c) =>
                c.name.components.length == 3 &&
                c.name.components[0].name == 'dart' &&
                c.name.components[1].name == 'library',
          );

          final clientConfiguration = libConfigurations
              .where((c) => clientLibs.contains(c.name.components.last.name))
              .firstOrNull;
          final serverConfiguration = libConfigurations
              .where((c) => serverLibs.contains(c.name.components.last.name))
              .firstOrNull;

          final baseLib = getBaseLibraryForDirective(directive);
          if (baseLib == null) {
            data.logger.write(
              'Tooling Daemon: Could not resolve base library for ${directive.uri.stringValue}',
              level: Level.warning,
            );
          }

          final baseLoc = unit.lineInfo.getLocation(directive.offset);
          final baseDir = DirectiveTarget(
            directive.uri.stringValue ?? '',
            baseLib?.uri.toString() ?? '',
            baseLoc.lineNumber,
            baseLoc.columnNumber,
            directive.length,
          );

          if (clientConfiguration == null && serverConfiguration == null) {
            // This is a general import (or with unsupported configurations), add to general dependencies
            if (baseLib != null) {
              dependencies.add((lib: baseLib, dir: baseDir, onClient: true, onServer: true));
            }
            continue;
          }

          if (clientConfiguration != null) {
            final clientLib = await resolveLibraryFromUri(clientConfiguration.uri.stringValue);
            if (clientLib != null) {
              final clientLoc = unit.lineInfo.getLocation(clientConfiguration.uri.offset);
              final clientDir = DirectiveTarget(
                clientConfiguration.uri.stringValue ?? '',
                clientLib.uri.toString(),
                clientLoc.lineNumber,
                clientLoc.columnNumber,
                clientConfiguration.uri.length,
              );
              dependencies.add((lib: clientLib, dir: clientDir, onClient: true, onServer: false));
            } else {
              data.logger.write(
                'Tooling Daemon: Could not resolve client library for ${directive.uri.stringValue}',
                level: Level.warning,
              );
            }
          } else {
            // On the client, the base import is used.
            if (baseLib != null) {
              dependencies.add((lib: baseLib, dir: baseDir, onClient: true, onServer: false));
            }
          }

          if (serverConfiguration != null) {
            final serverLib = await resolveLibraryFromUri(serverConfiguration.uri.stringValue);
            if (serverLib != null) {
              final serverLoc = unit.lineInfo.getLocation(serverConfiguration.uri.offset);
              final serverDir = DirectiveTarget(
                serverConfiguration.uri.stringValue ?? '',
                serverLib.uri.toString(),
                serverLoc.lineNumber,
                serverLoc.columnNumber,
                serverConfiguration.uri.length,
              );
              dependencies.add((lib: serverLib, dir: serverDir, onClient: false, onServer: true));
            } else {
              data.logger.write(
                'Tooling Daemon: Could not resolve server library for ${directive.uri.stringValue}',
                level: Level.warning,
              );
            }
          } else {
            // On the server, the base import is used.
            if (baseLib != null) {
              dependencies.add((lib: baseLib, dir: baseDir, onClient: false, onServer: true));
            }
          }
        }
      }
    }

    return dependencies;
  }
}

class InspectItemDependency {
  InspectItemDependency(this.item, this.dir, this.onClient, this.onServer);

  final InspectDataItem item;
  final DirectiveTarget dir;
  final bool onClient;
  final bool onServer;

  DirectiveTarget? invalidOnClient;
  DirectiveTarget? invalidOnServer;
}

class DirectiveTarget {
  final String uri;
  final String target;
  final int line;
  final int character;
  final int length;

  DirectiveTarget(this.uri, this.target, this.line, this.character, this.length);

  Map<String, dynamic> toJson() {
    return {'uri': uri, 'target': target, 'line': line, 'character': character, 'length': length};
  }

  DirectiveTarget withTarget(DirectiveTarget childDir) {
    return DirectiveTarget(uri, childDir.target, line, character, length);
  }
}

class InspectTarget {
  final String path;
  final String name;
  final int line;
  final int character;

  InspectTarget(this.path, this.name, this.line, this.character);

  Map<String, dynamic> toJson() {
    return {'path': path, 'name': name, 'line': line, 'character': character};
  }
}
