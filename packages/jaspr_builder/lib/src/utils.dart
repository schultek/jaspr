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
import 'package:path/path.dart' as path;
import 'package:source_gen/source_gen.dart';
import 'package:yaml/yaml.dart' as yaml;

const String generationHeader =
    '// dart format off\n'
    '// ignore_for_file: type=lint\n\n'
    '// GENERATED FILE, DO NOT MODIFY\n'
    '// Generated with jaspr_builder\n\n';

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

Map<String, String> compressPaths(List<String> paths) {
  final segments = paths.map((p) => p.split('/')).toList();
  segments.sort((a, b) {
    if (a.length != b.length) {
      return a.length - b.length;
    }
    var i = 0;
    var c = a[i].compareTo(b[i]);
    while (c == 0 && i < a.length - 1) {
      i++;
      c = a[i].compareTo(b[i]);
    }
    return c;
  });

  final compressed = <String, String>{};
  final used = <String>{};
  for (final segment in segments) {
    var i = segment.length - 1;
    var compressedPath = path.url.withoutExtension(segment.last);
    while (i > 0 && used.contains(compressedPath)) {
      i--;
      compressedPath = '${segment[i]}/$compressedPath';
    }
    used.add(compressedPath);
    compressed[segment.join('/')] = compressedPath;
  }
  return compressed;
}

int compareSegments(Iterable<String> a, Iterable<String> b) {
  if (a.length > 1 && b.length > 1) {
    final comp = a.first.compareTo(b.first);
    if (comp == 0) {
      return compareSegments(a.skip(1), b.skip(1));
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

int comparePaths(String a, String b) {
  return compareSegments(a.split('/'), b.split('/'));
}

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

      final List<String> details = [];

      if (element case final ExtensionElement ext) {
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
          InterfaceElement() || TypeAliasElement() => ElementType.type,
          TopLevelVariableElement() || TopLevelFunctionElement() || GetterElement() => ElementType.variable,
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
  ImportsWriter();

  String resolve(String source) {
    final imports = <String>{};
    final deferredImports = <String>{};
    for (final match in _importsRegex.allMatches(source)) {
      final url = match.group(2)!;
      imports.add(url);
      if (match.group(1) != null) {
        deferredImports.add(url);
      }
    }

    final compressed = compressPaths(imports.toList());
    final prefixes = {
      for (final url in imports)
        url: '_${compressed[url]!.replaceFirst('package:', '\$').replaceAll('/', '_').replaceAll('.', r'$')}',
    };

    return source
        .replaceAllMapped(_importsRegex, (match) {
          final url = match.group(2)!;
          return prefixes[url]!;
        })
        .replaceFirst(
          '[[/]]',
          imports
              .sortedByCompare((s) => s, comparePaths)
              .map((url) => "import '$url' ${deferredImports.contains(url) ? 'deferred ' : ''}as ${prefixes[url]};")
              .join('\n'),
        );
  }
}

final _importsRegex = RegExp(r'\[\[(?!/)(=)?(.+?)\]\]');

extension ImportUrl on AssetId {
  String toImportUrl() {
    return 'package:$package/${this.path.replaceFirst('lib/', '')}';
  }
}

extension LoadBundle on BuildStep {
  Stream<T> loadBundle<T>(String name, T Function(Map<String, Object?>) decoder) async* {
    final packages = {inputId.package, ...(await packageConfig).packages.map((p) => p.name)};
    for (final package in packages) {
      final bundleId = AssetId(package, 'lib/$name.bundle.json');
      if (await canRead(bundleId)) {
        final bundle = jsonDecode(await readAsString(bundleId)) as List<Object?>;
        for (final element in bundle.cast<Map<String, Object?>>()) {
          yield decoder(element);
        }
      }
    }
  }

  Future<Set<AssetId>> loadTransitiveSourcesFor(AssetId entryId) async {
    if (!await canRead(entryId)) {
      return {};
    }
    await resolver.libraryFor(entryId);
    return loadTransitiveSources();
  }

  Future<Set<AssetId>> loadTransitiveSources() async {
    return resolver.libraries.expand<AssetId>((lib) {
      try {
        return [AssetId.resolve(lib.firstFragment.source.uri)];
      } catch (_) {
        return [];
      }
    }).toSet();
  }

  Future<(String?, String?)> loadProjectMode(BuilderOptions options, BuildStep buildStep) async {
    final pubspecYaml = await readAsString(AssetId(inputId.package, 'pubspec.yaml'));
    final jasprConfig = (yaml.loadYaml(pubspecYaml) as Map<Object?, Object?>?)?['jaspr'] as Map<Object?, Object?>?;
    final mode = jasprConfig?['mode'] as String?;
    final flutter = jasprConfig?['flutter'] as String?;

    return (mode, flutter);
  }
}
