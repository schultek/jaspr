import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;

import '../utils.dart';

final path = p.posix;

class ImportsStubsBuilder implements Builder {
  ImportsStubsBuilder(BuilderOptions options);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    final imports = buildStep.findAssets(Glob('**/*.imports.json'));

    final webImports = <String, Set<ImportElement>>{};
    final vmImports = <String, Set<ImportElement>>{};

    final stubs = <String>{};

    await for (final id in imports) {
      final entries = (jsonDecode(await buildStep.readAsString(id)) as List<Object?>)
          .cast<Map<String, Object?>>()
          .map(ImportEntry.fromJson)
          .toList();
      for (final entry in entries) {
        var url = entry.url;

        for (final elem in entry.elements) {
          if (elem.type == ElementType.variable) {
            stubs.add('dynamic ${elem.name};');
          } else if (elem.type == ElementType.type) {
            stubs.add('dynamic ${elem.name};');
            stubs.add('typedef ${elem.name}OrStubbed = dynamic;');
          } else if (elem.type == ElementType.extension) {
            stubs.add(
              'extension ${elem.name} on dynamic {\n'
              '${elem.details.join('\n')}\n'
              '}',
            );
          }
        }

        var uri = Uri.parse(url);
        if (uri.scheme.isEmpty && path.isRelative(uri.path)) {
          var absUrl = path.join(path.dirname(id.path), url);
          url = path.relative(absUrl, from: 'lib/generated/imports/_.dart');
        }

        if (entry.platform == 0) {
          (webImports[url] ??= {}).addAll(entry.elements);
        } else {
          (vmImports[url] ??= {}).addAll(entry.elements);
        }
      }
    }

    if (vmImports.isNotEmpty) {
      await buildStep.writeAsFormattedDart(AssetId(buildStep.inputId.package, 'lib/generated/imports/_vm.dart'), """
        // ignore_for_file: directives_ordering, deprecated_member_use
        
        ${vmImports.entries.where((e) => e.value.any((e) => e.type == ElementType.type)).map((e) => "import '${e.key}' show ${e.value.where((e) => e.type == ElementType.type).map((e) => e.name).join(', ')};").join('\n')}
        ${vmImports.entries.map((e) => "export '${e.key}' show ${e.value.map((e) => e.name).join(', ')};").join('\n')}

        ${vmImports.values.expand((v) => v.where((e) => e.type == ElementType.type)).map((e) => 'typedef ${e.name}OrStubbed = ${e.name};').join('\n')}
      """);
    }

    if (webImports.isNotEmpty) {
      await buildStep.writeAsFormattedDart(AssetId(buildStep.inputId.package, 'lib/generated/imports/_web.dart'), """
        // ignore_for_file: directives_ordering, deprecated_member_use

        ${webImports.entries.where((e) => e.value.any((v) => v.type == ElementType.type)).map((e) => "import '${e.key}' show ${e.value.where((v) => v.type == ElementType.type).map((v) => v.name).join(', ')};").join('\n')}
        ${webImports.entries.map((e) => "export '${e.key}' show ${e.value.map((e) => e.name).join(', ')};").join('\n')}

        ${webImports.values.expand((v) => v.where((e) => e.type == ElementType.type)).map((e) => 'typedef ${e.name}OrStubbed = ${e.name};').join('\n')}
      """);
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
