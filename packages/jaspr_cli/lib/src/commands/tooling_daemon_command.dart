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
      daemon.registerDomain(ScopingDomain(daemon, logger));
      return 0;
    });
  }
}

// [{"id":1,"method":"scoping.registerScopes","params":{"scopes":["/Users/kilian/Documents/Work/Packages/jaspr/apps/website/lib/main.dart"]}}]

class ScopingDomain extends Domain {
  ScopingDomain(Daemon daemon, this.logger) : super(daemon, 'scoping') {
    registerHandler('registerScopes', _registerScopes);
  }

  final Logger logger;
  final Map<String, Scope> _scopes = {};

  Future<dynamic> _registerScopes(Map<String, dynamic> params) async {
    final scopes = params['scopes'] as List<dynamic>;
    AnalysisContextCollection collection = AnalysisContextCollection(
      includedPaths: scopes.cast(),
      resourceProvider: PhysicalResourceProvider.INSTANCE,
    );
    for (final path in scopes) {
      final context = collection.contextFor(path as String);
      _scopes.putIfAbsent(path, () => Scope(this, context, logger));
    }
  }

  @override
  void dispose() {
    for (final scope in _scopes.values) {
      scope.dispose();
    }
    _scopes.clear();
    super.dispose();
  }
}

class Scope {
  Scope(this.domain, this.context, this.logger) {
    watcher = DirectoryWatcher(
      context.contextRoot.root.path,
    );
    watcherSub = watcher.events.listen((event) {
      if (event.path.endsWith('.dart')) {
        logger.write('File changed: ${event.path}');
        context.changeFile(event.path);
        analyze(true);
      }
    });
    analyze();
  }

  final ScopingDomain domain;
  final AnalysisContext context;
  final Logger logger;
  late DirectoryWatcher watcher;
  late StreamSubscription<WatchEvent> watcherSub;

  Future<void> analyze([bool awaitPendingChanges = false]) async {
    final mainFile = context.contextRoot.root.getChildAssumingFolder('lib').getChildAssumingFile('main.dart');
    if (!mainFile.exists) {
      logger.write('No main.dart found in ${context.contextRoot.root.path}');
      return;
    }

    final sw = Stopwatch()..start();
    logger.write('Analyzing ${context.contextRoot.root.path}...');

    if (awaitPendingChanges) {
      await context.applyPendingFileChanges();
      logger.write('Applied pending changes in ${sw.elapsedMilliseconds}ms');
      sw.reset();
    }

    final result = await context.currentSession.getResolvedLibrary(mainFile.path);
    sw.stop();

    if (result is! ResolvedLibraryResult) {
      logger.write('Failed to resolve main.dart in ${context.contextRoot.root.path}');
      return;
    }
    logger.write('Resolved main.dart in ${sw.elapsedMilliseconds}ms');

    var inspectData = InspectData();

    inspectData.inspectLibrary(result.element2);
    domain.sendEvent('scoping.inspectResult', {
      'path': context.contextRoot.root.path,
      'data': inspectData.toJson(),
    });
  }

  void dispose() {
    watcherSub.cancel();
  }
}

class InspectData {
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
      final target = InspectTarget(path, clazz.name ?? '');
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
      'items': {
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

  InspectTarget(this.path, this.name);

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'name': name,
    };
  }
}
