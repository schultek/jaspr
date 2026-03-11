import 'dart:async';
import 'dart:io' as io;
import 'dart:isolate';

import 'package:collection/collection.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

import '../commands/tooling_daemon_command.dart';
import '../helpers/daemon_helper.dart';
import '../logging.dart';
import 'scopes_isolate.dart';

class ScopesDomain extends Domain {
  ScopesDomain(Daemon daemon, this.logger) : super(daemon, 'scopes') {
    registerHandler('register', registerScopes);
  }

  final Logger logger;
  final Map<String, ScopesContext> _scopes = {};

  Future<void> registerScopes(Map<String, Object?> params) async {
    final clientId = params['__clientId'] as int?;
    if (clientId == null) {
      logger.write('Missing clientId in scopes message.', level: Level.error);
      return;
    }

    final clientOnDone = params['__clientOnDone'] as Future<void>?;
    clientOnDone?.then((_) {
      _removeClient(clientId);
    });

    final folders = (params['folders'] as List<Object?>).cast<String>();

    for (final folder in folders) {
      createScopes(folder, clientId: clientId);
    }
  }

  Future<void> createScopes(String folder, {int? clientId}) async {
    final serverEntrypointGlob = Glob('**/*.server.dart');

    final entryPaths = <String>[];
    var allowServerLibsInClient = false;

    toolingDaemonDebugLog('Creating scopes for $folder...');

    check:
    {
      try {
        final pubspecFile = io.File(path.join(folder, 'pubspec.yaml'));
        if (!pubspecFile.existsSync()) {
          toolingDaemonDebugLog('No pubspec.yaml found in $folder');
          logger.write('No pubspec.yaml found in $folder');
          break check;
        }

        final pubspecYaml = loadYaml(pubspecFile.readAsStringSync()) as YamlMap;
        if (pubspecYaml case {'jaspr': {'mode': 'server' || 'static'}}) {
          // ok
        } else {
          toolingDaemonDebugLog('Scopes not available in client mode.');
          logger.write('Scopes not available in client mode.');
          break check;
        }

        if (pubspecYaml case {'jaspr': {'flutter': 'embedded' || 'plugins'}}) {
          allowServerLibsInClient = true;
        }
      } catch (e) {
        toolingDaemonDebugLog('Failed to read pubspec.yaml in $folder: $e');
        logger.write('Failed to read pubspec.yaml in $folder: $e');
        break check;
      }

      final serverEntrypoints = serverEntrypointGlob.listSync(root: folder);
      if (serverEntrypoints.isEmpty) {
        toolingDaemonDebugLog('No server entrypoints found in $folder.');
        logger.write('No server entrypoints found in $folder.');
        break check;
      }

      entryPaths.addAll(serverEntrypoints.map((e) => e.path));
    }

    if (entryPaths.isEmpty) {
      if (_scopes.containsKey(folder)) {
        await _disposeScope(folder);
      }
      return;
    }

    if (_scopes[folder] case final scope?) {
      if (clientId != null) {
        scope.dependentClients.add(clientId);
      }

      toolingDaemonDebugLog('Scopes already available.');

      if (!const ListEquality<String>().equals(scope.entryPaths, entryPaths) ||
          scope.allowServerLibsInClient != allowServerLibsInClient) {
        toolingDaemonDebugLog('Entry paths or allowServerLibsInClient changed. Updating...');

        await scope.update(
          entryPaths: entryPaths,
          allowServerLibsInClient: allowServerLibsInClient,
        );
      } else if (clientId != null) {
        emitScopes({clientId});
        emitStatus({clientId});
      }

      return;
    }

    final scope = _scopes[folder] = await ScopesContext.create(
      folder: folder,
      parent: this,
      logger: logger,
    );

    if (clientId != null) {
      scope.dependentClients.add(clientId);
    }
    await scope.initialize(
      entryPaths: entryPaths,
      allowServerLibsInClient: allowServerLibsInClient,
    );
  }

  Future<void> _removeClient(int clientId) async {
    final keys = _scopes.keys.toList();
    for (final key in keys) {
      final scope = _scopes[key]!;
      if (scope.dependentClients.contains(clientId)) {
        scope.dependentClients.remove(clientId);

        // Delay disposal by 30 seconds to allow for re-registration.
        if (scope.dependentClients.isEmpty) {
          Timer(const Duration(seconds: 30), () async {
            if (scope.dependentClients.isEmpty) {
              await _disposeScope(key);
            }
          });
        }
      }
    }
  }

  Future<void> _disposeScope(String folder) async {
    await _scopes.remove(folder)?.dispose();
    toolingDaemonDebugLog('Remaining scopes: ${_scopes.length}');
  }

  void emitScopes([Set<int>? clientIds]) {
    final targetClientIds = clientIds ?? _scopes.values.expand((s) => s.dependentClients).toSet();

    for (final clientId in targetClientIds) {
      final output = <String, Object?>{
        '__clientId': clientId,
      };

      final scopes = _scopes.values.where((s) => s.dependentClients.contains(clientId)).toList();
      final allLibraries = scopes.expand((s) => s.inspectedData.values.expand((libraries) => libraries.keys)).toSet();

      for (final libraryPath in allLibraries) {
        final components = <String>{};
        final clientScopeRoots = <String, InspectTarget>{};
        final serverScopeRoots = <String, InspectTarget>{};

        for (final scope in scopes) {
          for (final data in scope.inspectedData.values) {
            if (data.containsKey(libraryPath)) {
              final item = data[libraryPath]!;

              components.addAll(item.components.map((e) => e.name));
              clientScopeRoots.addAll({
                for (final target in item.clientScopeRoots) '${target.path}:${target.name}': target,
              });
              serverScopeRoots.addAll({
                for (final target in item.serverScopeRoots) '${target.path}:${target.name}': target,
              });
            }
          }
        }

        final invalidDependencies = <String, SerializedInspectItemDependency>{};

        for (final scope in scopes) {
          for (final data in scope.inspectedData.values) {
            if (data.containsKey(libraryPath)) {
              final item = data[libraryPath]!;

              for (final c in item.children) {
                if ((clientScopeRoots.isNotEmpty && c.invalidOnClient != null) ||
                    (serverScopeRoots.isNotEmpty && c.invalidOnServer != null)) {
                  final uri = c.uri;
                  invalidDependencies[uri] = c;
                }
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

      toolingDaemonDebugLog('Emitting scopes result for $clientId');
      sendEvent('scopes.result', output);
    }
  }

  void emitStatus([Set<int>? clientIds]) {
    final targetClientIds = clientIds ?? _scopes.values.expand((s) => s.dependentClients).toSet();

    for (final clientId in targetClientIds) {
      final output = <String, Object?>{
        '__clientId': clientId,
      };

      for (final scope in _scopes.values) {
        if (scope.dependentClients.contains(clientId)) {
          for (final entry in scope.analysisStatus.entries) {
            output[entry.key] = entry.value;
          }
        }
      }

      toolingDaemonDebugLog('Emitting scopes status for $clientId');
      sendEvent('scopes.status', output);
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

class ScopesContext {
  ScopesContext({
    required this.folder,
    required this.parent,
    required this.logger,
    required this.isolate,
    required this.isolateMessagePort,
  }) {
    isolateEventPort = ReceivePort();
    isolateEventPort.listen((event) {
      if (event is StatusEvent) {
        analysisStatus[event.contextRoot] = event.isAnalyzing;
        parent.emitStatus(dependentClients);
      } else if (event is ResultEvent) {
        inspectedData[event.contextRoot] = event.libraries;
        parent.emitScopes(dependentClients);
      } else if (event is LogEvent) {
        toolingDaemonDebugLog(event.message);
        logger.write(event.message, level: event.level);
      } else if (event is RecreateScopesEvent) {
        parent.createScopes(folder);
      }
    });
  }

  final String folder;
  final ScopesDomain parent;
  final Logger logger;

  final Isolate isolate;
  final SendPort isolateMessagePort;
  late final ReceivePort isolateEventPort;

  List<String> entryPaths = [];
  bool allowServerLibsInClient = false;
  final Map<String, bool> analysisStatus = {};
  final Map<String, Map<String, SerializedInspectDataItem>> inspectedData = {};

  final Set<int> dependentClients = {};

  static Future<ScopesContext> create({
    required String folder,
    required ScopesDomain parent,
    required Logger logger,
  }) async {
    final receivePort = ReceivePort();
    final isolate = await Isolate.spawn(ScopesIsolate.spawn, receivePort.sendPort);

    final isolatePort = await receivePort.first as SendPort;
    receivePort.close();

    final context = ScopesContext(
      folder: folder,
      parent: parent,
      logger: logger,
      isolate: isolate,
      isolateMessagePort: isolatePort,
    );

    return context;
  }

  Future<void> initialize({required List<String> entryPaths, required bool allowServerLibsInClient}) async {
    toolingDaemonDebugLog('Initializing scopes for $folder...');

    this.entryPaths = entryPaths;
    this.allowServerLibsInClient = allowServerLibsInClient;
    isolateMessagePort.send(InitializeMessage(entryPaths, allowServerLibsInClient, isolateEventPort.sendPort));
  }

  Future<void> update({required List<String> entryPaths, required bool allowServerLibsInClient}) async {
    toolingDaemonDebugLog('Updating scopes for $folder...');

    this.entryPaths = entryPaths;
    this.allowServerLibsInClient = allowServerLibsInClient;
    analysisStatus.clear();
    inspectedData.clear();

    isolateMessagePort.send(UpdateMessage(entryPaths, allowServerLibsInClient));
  }

  Future<void> dispose() async {
    toolingDaemonDebugLog('Disposing scopes for $folder...');

    isolateMessagePort.send(DisposeMessage());
    isolateEventPort.close();
    analysisStatus.clear();
    inspectedData.clear();
  }
}
