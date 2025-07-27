import 'dart:async';

import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:watcher/watcher.dart';

import '../helpers/daemon_helper.dart';
import '../logging.dart';
import 'base_command.dart';

class ToolingDaemonCommand extends BaseCommand with DaemonHelper {
  ToolingDaemonCommand() : super(logger: DaemonLogger());

  @override
  String get description => 'Start the Jaspr tooling daemon.';

  @override
  String get name => 'tooling-daemon';

  @override
  String get category => 'Tooling';

  @override
  bool get hidden => true;

  @override
  // ignore: overridden_fields
  final bool requiresPubspec = false;

  @override
  // ignore: overridden_fields
  final bool verbose = true;

  @override
  Future<int> runCommand() async {
    return runWithDaemon((daemon) async {
      daemon.registerDomain(ScopesDomain(daemon, logger));
      return 0;
    });
  }
}

// [{"id":1,"method":"scoping.registerScopes","params":{"scopes":["/Users/kilian/Documents/Work/Packages/jaspr/apps/website/lib/main.dart"]}}]

class ScopesDomain extends Domain {
  ScopesDomain(Daemon daemon, this.logger) : super(daemon, 'scopes') {
    registerHandler('register', _registerScopes);
  }

  final Logger logger;
  AnalysisContextCollection? _collection;
  final List<StreamSubscription<WatchEvent>> _watcherSubscriptions = [];

  Future<dynamic> _registerScopes(Map<String, dynamic> params) async {
    await _collection?.dispose();
    // ignore: avoid_function_literals_in_foreach_calls
    _watcherSubscriptions.forEach((sub) => sub.cancel());
    _watcherSubscriptions.clear();

    final folders = params['folders'] as List<dynamic>;

    _collection = AnalysisContextCollection(
      includedPaths: folders.cast(),
      resourceProvider: PhysicalResourceProvider.INSTANCE,
    );

    for (final context in _collection!.contexts) {
      _watcherSubscriptions.add(DirectoryWatcher(
        context.contextRoot.root.path,
      ).events.listen((event) {
        final path = event.path;
        logger.write('File changed: $path');

        if (path.endsWith('.dart')) {
          _reanalyze(path);
        } else if (path.endsWith('pubspec.yaml') ||
            path.endsWith('pubspec.lock') ||
            path.endsWith('package_config.json')) {
          // Recreate all scopes if pubspec or package config changes.
          _registerScopes(params);
        }
      }));
    }

    for (final context in _collection!.contexts) {
      await analyze(context);
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
    final mainFile = context.contextRoot.root.getChildAssumingFolder('lib').getChildAssumingFile('main.dart');

    if (!mainFile.exists) {
      logger.write('No main.dart found in $rootPath');
      return;
    }

    final sw = Stopwatch()..start();
    logger.write('Analyzing $rootPath...');

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

    final inspectData = InspectData(result.element2);
    sendEvent('scopes.result', inspectData.toJson());
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
  InspectData(LibraryElement root) {
    final mainFunction = root.topLevelFunctions.where((e) => e.name == 'main').firstOrNull?.firstFragment;
    final mainLocation =
        mainFunction?.libraryFragment.lineInfo.getLocation(mainFunction.nameOffset ?? mainFunction.offset);
    mainTarget = InspectTarget(
      root.firstFragment.source.fullName,
      'main',
      mainLocation?.lineNumber ?? 0,
      mainLocation?.columnNumber ?? 0,
    );

    inspectLibrary(root);
  }

  late InspectTarget mainTarget;
  Map<String, InspectDataItem> libraries = {};

  void inspectLibrary(LibraryElement library, [Set<InspectTarget> clientScopeRoots = const {}]) {
    final path = library.firstFragment.source.fullName;
    if (libraries.containsKey(path)) {
      var data = libraries[path]!;
      if (clientScopeRoots.any((e) => !data.clientScopeRoots.contains(e))) {
        data.clientScopeRoots.addAll(clientScopeRoots);

        final dependencies = [
          ...library.fragments.expand((f) => f.importedLibraries),
          ...library.exportedLibraries,
        ];
        for (final dependency in dependencies) {
          inspectLibrary(dependency, clientScopeRoots);
        }
      }

      return;
    }

    final data = InspectDataItem();
    data.clientScopeRoots.addAll(clientScopeRoots);

    libraries[path] = data;

    for (final clazz in library.classes) {
      final location = clazz.firstFragment.libraryFragment.lineInfo
          .getLocation(clazz.firstFragment.nameOffset ?? clazz.firstFragment.offset);
      final target = InspectTarget(path, clazz.name ?? '', location.lineNumber, location.columnNumber);
      if (clazz.allSupertypes.any((e) => e.element.name == 'Component')) {
        data.components.add(target);
        if (clazz.metadata.annotations.any((a) => a.element?.name == 'client')) {
          data.clientScopeRoots.add(target);
        }
      }
    }

    final dependencies = [
      ...library.fragments.expand((f) => f.importedLibraries),
      ...library.exportedLibraries,
    ];
    for (final dep in dependencies) {
      inspectLibrary(dep, data.clientScopeRoots);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'root': mainTarget.toJson(),
      'data': {
        for (var entry in libraries.entries)
          if (entry.value.components.isNotEmpty)
            entry.key: {
              'components': entry.value.components.map((e) => e.name).toList(),
              'clientScopeRoots': entry.value.clientScopeRoots.map((e) => e.toJson()).toList(),
            }
      }
    };
  }
}

class InspectDataItem {
  final List<InspectTarget> components = [];
  final Set<InspectTarget> clientScopeRoots = {};

  InspectDataItem();
}

class InspectTarget {
  final String path;
  final String name;
  final int line;
  final int character;

  InspectTarget(this.path, this.name, this.line, this.character);

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'name': name,
      'line': line,
      'character': character,
    };
  }
}
