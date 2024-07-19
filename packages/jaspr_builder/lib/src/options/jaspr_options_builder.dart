import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart' as yaml;

import '../client/client_module_builder.dart';
import '../styles/styles_module_builder.dart';

/// Builds part files and web entrypoints for components annotated with @app
class JasprOptionsBuilder implements Builder {
  JasprOptionsBuilder(BuilderOptions options);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    try {
      await generateOptionsOutput(buildStep);
    } catch (e, st) {
      print('An unexpected error occurred.\n'
          'This is probably a bug in jaspr_builder.\n'
          'Please report this here: '
          'https://github.com/schultek/jaspr/issues\n\n'
          'The error was:\n$e\n\n$st');
      rethrow;
    }
  }

  @override
  Map<String, List<String>> get buildExtensions => const {
        r'lib/$lib$': ['lib/jaspr_options.dart'],
      };

  String get generationHeader => "// GENERATED FILE, DO NOT MODIFY\n"
      "// Generated with jaspr_builder\n";

  Future<void> generateOptionsOutput(BuildStep buildStep) async {
    final pubspecYaml = await buildStep.readAsString(AssetId(buildStep.inputId.package, 'pubspec.yaml'));
    final mode = yaml.loadYaml(pubspecYaml)?['jaspr']?['mode'];

    if (mode != 'static' && mode != 'server') {
      return;
    }

    final imports = ImportsWriter();

    final clients = await loadClientModules(buildStep);
    final styles = await loadStylesModules(buildStep);

    for (var c in clients) {
      imports.add(c.id);
    }
    for (var s in styles) {
      imports.add(s.id);
    }

    imports.sort();
    clients.sortBy((c) => '${imports.prefixOf(c.id)}.${c.name}');
    styles.sortBy((s) => imports.prefixOf(s.id));

    final optionsId = AssetId(buildStep.inputId.package, 'lib/jaspr_options.dart');
    final optionsSource = DartFormatter(pageWidth: 120).format('''
      $generationHeader
      
      import 'package:jaspr/jaspr.dart';
      $imports
      
      /// Default [JasprOptions] for use with your jaspr project.
      ///
      /// Use this to initialize jaspr **before** calling [runApp].
      ///
      /// Example:
      /// ```dart
      /// import 'jaspr_options.dart';
      /// 
      /// void main() {
      ///   Jaspr.initializeApp(
      ///     options: defaultJasprOptions,
      ///   );
      ///   
      ///   runApp(...);
      /// }
      /// ```
      final defaultJasprOptions = JasprOptions(
        clients: {
          ${buildClientEntries(imports, clients)}
        },
        styles: [
          ${buildStylesEntries(imports, styles)}
        ],
      );
      
      ${buildClientParamGetters(imports, clients)}
      
    ''');

    await buildStep.writeAsString(optionsId, optionsSource);
  }

  Future<List<ClientModule>> loadClientModules(BuildStep buildStep) {
    return buildStep
        .findAssets(Glob('lib/**.client.json'))
        .asyncMap((id) => buildStep.readAsString(id))
        .map((c) => ClientModule.deserialize(jsonDecode(c)))
        .toList();
  }

  Future<List<StylesModule>> loadStylesModules(BuildStep buildStep) {
    return buildStep
        .findAssets(Glob('lib/**.styles.json'))
        .asyncMap((id) => buildStep.readAsString(id))
        .map((c) => StylesModule.deserialize(jsonDecode(c)))
        .toList();
  }

  String buildClientEntries(ImportsWriter imports, List<ClientModule> clients) {
    return clients.map((c) {
      final prefix = imports.prefixOf(c.id);
      return '''
        $prefix.${c.name}: ClientTarget<$prefix.${c.name}>(
          '${path.url.relative(path.url.withoutExtension(c.id.path), from: 'lib')}'
          ${c.params.isNotEmpty ? ', params: _$prefix${c.name}' : ''}
        ),
      ''';
    }).join('\n');
  }

  String buildClientParamGetters(ImportsWriter imports, List<ClientModule> clients) {
    return clients.where((c) => c.params.isNotEmpty).map((c) {
      final prefix = imports.prefixOf(c.id);
      return 'Map<String, dynamic> _$prefix${c.name}($prefix.${c.name} c) => {${c.params.map((p) => "'${p.name}': ${p.encoder}").join(', ')}};';
    }).join('\n');
  }

  String buildStylesEntries(ImportsWriter imports, List<StylesModule> styles) {
    return styles.map((s) {
      final prefix = imports.prefixOf(s.id);
      return s.elements.map((e) => '...$prefix.$e,').join('\n');
    }).join('\n');
  }
}

class ImportsWriter {
  ImportsWriter();

  final List<String> imports = [];
  bool _sorted = false;

  void add(AssetId id) {
    assert(!_sorted);

    var url = path.url.relative(id.path, from: 'lib');
    var index = imports.indexOf(url);
    if (index == -1) {
      imports.add(url);
    }
  }

  String prefixOf(AssetId id) {
    assert(_sorted);

    var url = path.url.relative(id.path, from: 'lib');
    return 'prefix${imports.indexOf(url)}';
  }

  void sort() {
    imports.sort((a, b) {
      var ap = a.split('/');
      var bp = b.split('/');
      return comparePaths(ap, bp);
    });
    _sorted = true;
  }

  int comparePaths(List<String> a, List<String> b) {
    if (a.length > 1 && b.length > 1) {
      var comp = a.first.compareTo(b.first);
      ;
      if (comp == 0) {
        return comparePaths(a.skip(1).toList(), b.skip(1).toList());
      } else {
        return comp;
      }
    } else if (a.length > 1) {
      return -1;
    } else if (b.length > 1) {
      return 1;
    } else {
      return a.first.compareTo(b.first);
    }
  }

  @override
  String toString() {
    assert(_sorted);
    return imports.mapIndexed((index, url) => "import '$url' as prefix$index;").join('\n');
  }
}
