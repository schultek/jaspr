import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;

import '../utils.dart';

final path = p.posix;

class ImportsStubsBuilder implements Builder {
  ImportsStubsBuilder(BuilderOptions options);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    final imports = buildStep.findAssets(Glob('**/*.imports.json'));

    final webImports = PlatformImports();
    final vmImports = PlatformImports();

    final stubs = <String>[];
    final stubbedNames = <String>{};

    final allEntries = <ImportEntry>[];

    await for (final id in imports) {
      final entries = (jsonDecode(await buildStep.readAsString(id)) as List<Object?>).cast<Map<String, Object?>>().map(
        ImportEntry.fromJson,
      );

      for (final entry in entries) {
        final uri = Uri.parse(entry.url);
        if (uri.scheme.isEmpty && path.isRelative(uri.path)) {
          final absUrl = path.join(path.dirname(id.path), entry.url);
          allEntries.add(
            ImportEntry(
              path.relative(absUrl, from: 'lib/generated/imports/_.dart'),
              entry.platform,
              entry.elements,
            ),
          );
        } else {
          allEntries.add(entry);
        }
      }
    }

    allEntries.sortBy((e) => e.url);

    for (final entry in allEntries) {
      if (entry.platform == 0) {
        webImports.add(entry.url, entry.elements);
      } else {
        vmImports.add(entry.url, entry.elements);
      }

      for (final elem in entry.elements) {
        if (stubbedNames.contains(elem.name)) {
          continue;
        }
        stubbedNames.add(elem.name);
        if (elem.type == ElementType.variable) {
          stubs.add('dynamic ${elem.name};');
        } else if (elem.type == ElementType.type) {
          stubs.add(
            'dynamic ${elem.name};\n'
            'typedef ${elem.name}OrStubbed = dynamic;',
          );
        } else if (elem.type == ElementType.extension) {
          stubs.add(
            'extension ${elem.name} on dynamic {\n'
            '${elem.details.join('\n')}\n'
            '}',
          );
        }
      }
    }

    if (!vmImports.isEmpty) {
      await buildStep.writeAsFormattedDart(AssetId(buildStep.inputId.package, 'lib/generated/imports/_vm.dart'), '''
        // ignore_for_file: directives_ordering, deprecated_member_use
        
        ${vmImports.imports}
        ${vmImports.exports}

        ${vmImports.stubs}
      ''');
    }

    if (!webImports.isEmpty) {
      await buildStep.writeAsFormattedDart(AssetId(buildStep.inputId.package, 'lib/generated/imports/_web.dart'), '''
        // ignore_for_file: directives_ordering, deprecated_member_use

        ${webImports.imports}
        ${webImports.exports}

        ${webImports.stubs}
      ''');
    }

    if (stubs.isNotEmpty) {
      await buildStep.writeAsFormattedDart(AssetId(buildStep.inputId.package, 'lib/generated/imports/_stubs.dart'), """
        // ignore_for_file: directives_ordering, non_constant_identifier_names
        
        ${stubs.join('\n')}
      """);
    }
  }

  @override
  Map<String, List<String>> get buildExtensions => const {
    r'lib/$lib$': [
      'lib/generated/imports/_stubs.dart',
      'lib/generated/imports/_web.dart',
      'lib/generated/imports/_vm.dart',
    ],
  };
}

class PlatformImports {
  final Map<String, String> _uniqueNames = {};
  final Map<String, Set<String>> _importedNames = {};
  final Map<String, Set<String>> _exportedNames = {};
  final Set<String> _stubbedNames = {};

  void add(String url, List<ImportElement> elements) {
    final importedNames = _importedNames[url] ??= <String>{};
    final exportedNames = _exportedNames[url] ??= <String>{};

    for (final element in elements) {
      if (_uniqueNames[element.name] case final existingImport? when existingImport != url) {
        throw Exception(
          'Cannot import ${element.name} from $url, because it is also imported from $existingImport. '
          'Names imported via @Import must be unique for each platform across the project.',
        );
      }
      _uniqueNames[element.name] = url;
      exportedNames.add(element.name);
      if (element.type == ElementType.type) {
        importedNames.add(element.name);
        _stubbedNames.add(element.name);
      }
    }
  }

  bool get isEmpty => _uniqueNames.isEmpty;

  String get imports => [
    for (final MapEntry(key: url, value: names) in _importedNames.entries)
      if (names.isNotEmpty) "import '$url' show ${names.join(', ')};",
  ].join('\n');
  String get exports => [
    for (final MapEntry(key: url, value: names) in _exportedNames.entries)
      if (names.isNotEmpty) "export '$url' show ${names.join(', ')};",
  ].join('\n');
  String get stubs => [
    for (final name in _stubbedNames.toList()..sort()) 'typedef ${name}OrStubbed = $name;',
  ].join('\n');
}
