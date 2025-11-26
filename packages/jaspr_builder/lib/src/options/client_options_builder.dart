import 'dart:async';

import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:yaml/yaml.dart';

import '../client/client_bundle_builder.dart';
import '../client/client_module_builder.dart';
import '../utils.dart';

/// Builds the options file for client components.
class ClientOptionsBuilder implements Builder {
  ClientOptionsBuilder(this.options);

  final BuilderOptions options;

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    try {
      await generateClientOptions(buildStep);
    } catch (e, st) {
      print(
        'An unexpected error occurred.\n'
        'This is probably a bug in jaspr_builder.\n'
        'Please report this here: '
        'https://github.com/schultek/jaspr/issues\n\n'
        'The error was:\n$e\n\n$st',
      );
      rethrow;
    }
  }

  @override
  Map<String, List<String>> get buildExtensions => const {
    'lib/{{file}}.client.dart': ['lib/{{file}}.client.g.dart'],
  };

  Future<void> generateClientOptions(BuildStep buildStep) async {
    final mode = await buildStep.loadProjectMode(options, buildStep);
    if (mode != 'static' && mode != 'server') {
      return;
    }

    final serverId = AssetId(
      buildStep.inputId.package,
      buildStep.inputId.path.replaceFirst('.client.dart', '.server.dart'),
    );

    var (clients, sources, plugins) = await (
      buildStep.loadClients(),
      buildStep.loadTransitiveSourcesFor(serverId),
      loadWebPlugins(buildStep),
    ).wait;

    if (sources.isNotEmpty) {
      clients = clients.where((c) => sources.contains(c.id)).toList();
    }

    clients.sortByCompare((c) => '${c.import}/${c.name}', comparePaths);

    final package = buildStep.inputId.package;
    final outputId = buildStep.inputId.changeExtension('.g.dart');

    var source =
        '''
      import 'package:jaspr/client.dart';
      ${plugins.isNotEmpty ? "import 'package:flutter_web_plugins/flutter_web_plugins.dart';" : ''}
      [[/]]

      /// Default [ClientOptions] for use with your Jaspr project.
      ///
      /// Use this to initialize Jaspr **before** calling [runApp].
      ///
      /// Example:
      /// ```dart
      /// import '${outputId.path.split('/').last}';
      /// 
      /// void main() {
      ///   Jaspr.initializeApp(
      ///     options: defaultClientOptions,
      ///   );
      ///   
      ///   runApp(...);
      /// }
      /// ```
      ClientOptions get defaultClientOptions => ClientOptions(
        ${buildPluginInitializer(plugins)}
        ${buildClientEntries(clients, package)}
      );
    ''';

    source = ImportsWriter().resolve(source);
    await buildStep.writeAsFormattedDart(outputId, source);
  }

  String buildPluginInitializer(List<Plugin> plugins) {
    if (plugins.isEmpty) return '';

    return '''
      initialize: () {
        final Registrar registrar = webPluginRegistrar;
        ${plugins.map((p) => '[[${p.import}]].${p.pluginClass}.registerWith(registrar);').join('\n')}
        registrar.registerMessageHandler();
      },''';
  }

  String buildClientEntries(List<ClientModule> clients, String package) {
    if (clients.isEmpty) return '';

    final compressed = compressPaths(clients.map((c) => c.id.path).toList());

    return 'clients: {${clients.map((c) {
      final id = compressed[c.id.path]!;
      final fullId = c.id.package != package ? '${c.id.package}:$id' : id;
      return '''
        '$fullId': ClientLoader((p) => ${c.componentFactory()}, loader: [[=${c.import}]].loadLibrary),
      ''';
    }).join()}},';
  }
}

Future<List<Plugin>> loadWebPlugins(BuildStep buildStep) async {
  var pubspecId = AssetId(buildStep.inputId.package, 'pubspec.yaml');
  if (!await buildStep.canRead(pubspecId)) {
    return [];
  }

  final pubspecYaml = loadYaml(await buildStep.readAsString(pubspecId));

  final isWorkspace = switch (pubspecYaml) {
    {'resolution': 'workspace'} => true,
    _ => false,
  };
  final dependencies = switch (pubspecYaml) {
    {'dependencies': Map<Object?, Object?> deps} => deps.keys.cast<String>().toSet(),
    _ => <String>{},
  };

  var packageConfig = await buildStep.packageConfig;

  final packages = {for (var p in packageConfig.packages) p.name: p};

  final plugins = <String, Plugin>{};
  // If we're in a workspace, only consider packages that are direct dependencies.
  final toVisit = isWorkspace ? dependencies.toList() : packages.keys.toList();

  while (toVisit.isNotEmpty) {
    final packageName = toVisit.removeLast();
    if (plugins.containsKey(packageName)) {
      continue;
    }
    final package = packages[packageName];
    if (package == null) {
      continue;
    }

    final plugin = await _loadPluginForPackage(package.name, package.root, buildStep, toVisit);
    if (plugin != null) {
      plugins[packageName] = plugin;
    }
  }

  return plugins.values.toList();
}

Future<Plugin?> _loadPluginForPackage(String pluginName, Uri root, BuildStep buildStep, List<String> toVisit) async {
  var pubspecId = AssetId.resolve(root.resolve('pubspec.yaml'));
  Object? pubspec;
  try {
    pubspec = loadYaml(await buildStep.readAsString(pubspecId));
  } on YamlException catch (_) {
    // Do nothing, potentially not a plugin.
  } on AssetNotFoundException catch (_) {
    // Do nothing, potentially not a plugin.
  }

  if (pubspec case {
    'flutter': {'plugin': {'platforms': {'web': YamlMap webPlatformYaml}}},
  }) {
    if (webPlatformYaml case {'default_package': String defaultPackageName}) {
      toVisit.add(defaultPackageName);
      return null;
    }

    if (webPlatformYaml case {
      'pluginClass': String pluginClass,
      'fileName': String fileName,
    }) {
      return Plugin(
        name: pluginName,
        pluginClass: pluginClass,
        fileName: fileName,
      );
    }
  }

  return null;
}

class Plugin {
  Plugin({
    required this.name,
    required this.pluginClass,
    required this.fileName,
  });

  final String name;
  final String pluginClass;
  final String fileName;

  String get import => 'package:$name/$fileName';
}
