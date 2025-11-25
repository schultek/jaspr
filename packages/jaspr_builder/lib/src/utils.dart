import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:dart_style/dart_style.dart';
import 'package:jaspr/jaspr.dart' show ClientAnnotation, Import, Component, Key, SyncAnnotation, State;
// ignore: implementation_imports
import 'package:jaspr/src/dom/styles/css.dart' show CssUtility;
// ignore: implementation_imports
import 'package:jaspr/src/dom/styles/rules.dart' show StyleRule;
import 'package:source_gen/source_gen.dart';
import 'package:yaml/yaml.dart' as yaml;

const String generationHeader =
    "// dart format off\n"
    "// ignore_for_file: type=lint\n\n"
    "// GENERATED FILE, DO NOT MODIFY\n"
    "// Generated with jaspr_builder\n\n";

final formatter = DartFormatter(languageVersion: DartFormatter.latestLanguageVersion);

extension DartOutput on BuildStep {
  Future<void> writeAsFormattedDart(AssetId outputId, String source) async {
    await writeAsString(outputId, '$generationHeader${formatter.format(source)}');
  }
}

final TypeChecker clientChecker = TypeChecker.typeNamed(ClientAnnotation, inPackage: 'jaspr');
final TypeChecker componentChecker = TypeChecker.typeNamed(Component, inPackage: 'jaspr');
final TypeChecker keyChecker = TypeChecker.typeNamed(Key, inPackage: 'jaspr');
final TypeChecker stylesChecker = TypeChecker.typeNamed(CssUtility, inPackage: 'jaspr');
final TypeChecker styleRuleChecker = TypeChecker.typeNamed(StyleRule, inPackage: 'jaspr');
final TypeChecker syncChecker = TypeChecker.typeNamed(SyncAnnotation, inPackage: 'jaspr');
final TypeChecker stateChecker = TypeChecker.typeNamed(State, inPackage: 'jaspr');
final TypeChecker importChecker = TypeChecker.typeNamed(Import, inPackage: 'jaspr');

class ImportEntry {
  final String url;
  final int platform;
  final List<ImportElement> elements;

  ImportEntry(this.url, this.platform, this.elements);

  factory ImportEntry.from(String url, List<String> show, int platform, LibraryElement lib) {
    final elements = <ImportElement>[];
    for (final name in show) {
      final element = lib.exportNamespace.get2(name);
      if (element == null) {
        throw StateError('Import "$url" does not export symbol "$name".');
      }

      List<String> details = [];

      if (element case ExtensionElement ext) {
        for (final child in ext.children) {
          if (child.isSynthetic || child.isPrivate || child.name == null) continue;
          if (child is ExecutableElement && child.isStatic) continue;
          if (child is VariableElement && child.isStatic) continue;

          details.add(switch (child) {
            SetterElement() => 'set ${child.name!}(dynamic _) {}',
            _ => 'dynamic get ${child.name!} => null;',
          });
        }
      }

      elements.add(
        ImportElement(name, switch (element) {
          ExtensionElement() => ElementType.extension,
          TypeDefiningElement() => ElementType.type,
          TopLevelVariableElement() || GetterElement() => ElementType.variable,
          _ => throw StateError('Unsupported import symbol type: ${element.runtimeType}'),
        }, details),
      );
    }

    return ImportEntry(url, platform, elements);
  }

  factory ImportEntry.fromJson(Map<String, Object?> json) {
    return ImportEntry(
      json['url'] as String,
      json['platform'] as int,
      (json['elements'] as List<Object?>).map((e) => ImportElement.fromJson(e as Map<String, Object?>)).toList(),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'url': url,
      'platform': platform,
      'elements': elements.map((e) => e.toJson()).toList(),
    };
  }
}

class ImportElement {
  final String name;
  final ElementType type;
  final List<String> details;

  ImportElement(this.name, this.type, this.details);

  factory ImportElement.fromJson(Map<String, Object?> json) {
    return ImportElement(
      json['name'] as String,
      ElementType.values[json['type'] as int],
      (json['details'] as List<Object?>).cast<String>(),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'type': type.index,
      'details': details,
    };
  }
}

enum ElementType {
  type,
  extension,
  variable,
}

class ImportsWriter {
  ImportsWriter({this.deferred = false});

  final bool deferred;

  final List<String> imports = [];
  bool _sorted = false;

  void addAsset(AssetId id) {
    add(id.toImportUrl());
  }

  void add(String url) {
    assert(!_sorted);
    var index = imports.indexOf(url);
    if (index == -1) {
      imports.add(url);
    }
  }

  String prefixOfAsset(AssetId id) {
    return prefixOf(id.toImportUrl());
  }

  String prefixOf(String url) {
    assert(_sorted);
    return 'prefix${imports.indexOf(url)}';
  }

  void sort() {
    imports.sort(compareImports);
    _sorted = true;
  }

  static int comparePaths(List<String> a, List<String> b) {
    if (a.length > 1 && b.length > 1) {
      var comp = a.first.compareTo(b.first);
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

  static int compareImports(String a, String b) {
    return comparePaths(a.split('/'), b.split('/'));
  }

  String resolve(String source) {
    source.writeImports(this);
    sort();
    return source.resolveImports(this).replaceFirst('[[/]]', toString());
  }

  @override
  String toString() {
    assert(_sorted);
    return imports
        .mapIndexed((index, url) => "import '$url' ${deferred ? 'deferred ' : ''}as prefix$index;")
        .join('\n');
  }
}

final _importsRegex = RegExp(r'\[\[(?!/)(.+?)\]\]');

extension ImportUrl on AssetId {
  String toImportUrl() {
    return 'package:$package/${path.replaceFirst('lib/', '')}';
  }
}

extension ResolveImports on String {
  void writeImports(ImportsWriter imports) {
    for (var match in _importsRegex.allMatches(this)) {
      imports.add(match.group(1)!);
    }
  }

  String resolveImports(ImportsWriter imports) {
    return replaceAllMapped(_importsRegex, (match) {
      var url = match.group(1)!;
      return imports.prefixOf(url);
    });
  }
}

extension LoadBundle on BuildStep {
  Stream<T> loadBundle<T>(String name, T Function(Map<String, Object?>) decoder) async* {
    var packages = {inputId.package, ...(await packageConfig).packages.map((p) => p.name)};
    for (var package in packages) {
      var bundleId = AssetId(package, 'lib/$name.bundle.json');
      if (await canRead(bundleId)) {
        var bundle = jsonDecode(await readAsString(bundleId)) as List<Object?>;
        for (var element in bundle.cast<Map<String, Object?>>()) {
          yield decoder(element);
        }
      }
    }
  }

  Future<Set<AssetId>> loadTransitiveSources(String target) async {
    final main = AssetId(inputId.package, target);
    if (!await canRead(main)) {
      return {};
    }
    await resolver.libraryFor(main);
    return resolver.libraries.expand<AssetId>((lib) {
      try {
        return [AssetId.resolve(lib.firstFragment.source.uri)];
      } catch (_) {
        return [];
      }
    }).toSet();
  }

  Future<({String? mode, String target})> loadProjectConfig(BuilderOptions options) async {
    final pubspecYaml = await readAsString(AssetId(inputId.package, 'pubspec.yaml'));
    final jasprConfig = (yaml.loadYaml(pubspecYaml) as Map<Object?, Object?>?)?['jaspr'] as Map<Object?, Object?>?;
    final mode = jasprConfig?['mode'] as String?;
    final target = jasprConfig?['target'];

    final firstTarget = switch (target) {
      String t => t,
      List<Object?> l => l.cast<String>().firstOrNull,
      _ => null,
    };
    final targetOption = options.config['jaspr-target'] as String?;
    final effectiveTarget = targetOption ?? firstTarget ?? 'lib/main.dart';

    return (mode: mode, target: effectiveTarget);
  }
}
