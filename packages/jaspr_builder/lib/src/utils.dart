import 'dart:convert';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:dart_style/dart_style.dart';
import 'package:jaspr/jaspr.dart'
    show ClientAnnotation, CssUtility, Import, Component, Key, StyleRule, SyncAnnotation, State;
import 'package:source_gen/source_gen.dart';

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
  String url;
  List<String> show;
  final int platform;

  ImportEntry(this.url, this.show, this.platform);

  Map<String, Object?> toJson() {
    return {'url': url, 'show': show, 'platform': platform};
  }
}

extension TypeStub on String {
  bool get isType {
    var n = substring(0, 1);
    return n.toLowerCase() != n;
  }
}

extension ElementNode on Element {
  AstNode? get node {
    var result = session?.getParsedLibraryByElement(library!);
    if (result is ParsedLibraryResult) {
      return result.getFragmentDeclaration(firstFragment)?.node;
    } else {
      return null;
    }
  }
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

  Future<Set<AssetId>> loadTransitiveSources(BuilderOptions options, String? target) async {
    final targetOption = options.config['jaspr-target'] as String?;
    final effectiveTarget = targetOption ?? target ?? 'lib/main.dart';

    final main = AssetId(inputId.package, effectiveTarget);
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
}
