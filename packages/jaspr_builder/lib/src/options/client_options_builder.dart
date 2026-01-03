import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
    'lib/{{file}}.client.dart': ['lib/{{file}}.client.options.dart'],
  };

  Future<void> generateClientOptions(BuildStep buildStep) async {
    final (_, flutter) = await buildStep.loadProjectMode(options, buildStep);

    final serverId = AssetId(
      buildStep.inputId.package,
      buildStep.inputId.path.replaceFirst('.client.dart', '.server.dart'),
    );

    final shouldInitializePlugins = flutter == 'embedded' || flutter == 'plugins';

    var (clients, sources, plugins) = await (
      buildStep.loadClients(),
      buildStep.loadTransitiveSourcesFor(serverId),
      shouldInitializePlugins ? loadWebPlugins(buildStep) : Future.value(<Plugin>[]),
    ).wait;

    if (sources.isNotEmpty) {
      clients = clients.where((c) => sources.contains(c.id)).toList();
    }

    clients.sortByCompare((c) => '${c.import}/${c.name}', comparePaths);

    final package = buildStep.inputId.package;
    final outputId = buildStep.inputId.changeExtension('.options.dart');

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
  final pluginsDependenciesId = AssetId(buildStep.inputId.package, '.flutter-plugins-dependencies');

  Future<String?> readPluginsDependencies() async {
    if (await buildStep.canRead(pluginsDependenciesId)) {
      return buildStep.readAsString(pluginsDependenciesId);
    }
    final file = File('.flutter-plugins-dependencies');
    if (await file.exists()) {
      return file.readAsString();
    }
    return null;
  }

  var content = await readPluginsDependencies();

  if (content == null) {
    try {
      final result = await Process.run('flutter', ['packages', 'get']);
      if (result.exitCode != 0) {
        log.warning('Failed to run `flutter packages get` in order to find Flutter web plugins.\n${result.stderr}');
      }
    } catch (_) {
      return [];
    }
    content = await readPluginsDependencies();
  }

  if (content == null) {
    return [];
  }

  return _parseWebPlugins(content, buildStep);
}

Future<List<Plugin>> _parseWebPlugins(String content, BuildStep buildStep) async {
  final pluginsDependencies = jsonDecode(content);

  if (pluginsDependencies case {'plugins': {'web': final List<Object?> webPluginsDependencies}}) {
    final plugins = <Plugin>[];

    for (final webPluginDependency in webPluginsDependencies) {
      if (webPluginDependency case {'name': final String name, 'path': final String path, 'dev_dependency': false}) {
        final plugin = await _loadPluginForPackage(name, Uri.parse(path), buildStep);
        if (plugin != null) {
          plugins.add(plugin);
        }
      }
    }

    return plugins;
  } else {
    log.warning('Failed to find Flutter web plugins in .flutter-plugins-dependencies file.');
    return [];
  }
}

Future<Plugin?> _loadPluginForPackage(String pluginName, Uri root, BuildStep buildStep) async {
  final pubspecId = AssetId(pluginName, 'pubspec.yaml');
  Object? pubspec;
  try {
    pubspec = loadYaml(await buildStep.readAsString(pubspecId));
  } on YamlException catch (_) {
    // Do nothing, potentially not a plugin.
  } on AssetNotFoundException catch (_) {
    // Do nothing, potentially not a plugin.
  }

  if (pubspec case {
    'flutter': {'plugin': {'platforms': {'web': final YamlMap webPlatformYaml}}},
  }) {
    if (webPlatformYaml case {'default_package': final String defaultPackageName}) {
      log.warning(
        'Failed to read Flutter web plugin for $pluginName. Default package $defaultPackageName not resolved.',
      );
      return null;
    }

    if (webPlatformYaml case {
      'pluginClass': final String pluginClass,
      'fileName': final String fileName,
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
