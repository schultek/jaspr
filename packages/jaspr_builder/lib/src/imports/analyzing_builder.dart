import 'dart:async';
import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as path;

import '../utils.dart';

class ImportsAnalyzingBuilder implements Builder {
  ImportsAnalyzingBuilder(BuilderOptions options);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    try {
      if (await buildStep.resolver.isLibrary(buildStep.inputId)) {
        var lib = await buildStep.resolver.libraryFor(buildStep.inputId, allowSyntaxErrors: true);

        var outputId = buildStep.inputId.changeExtension('.imports.json');
        var partId = buildStep.inputId.changeExtension('.imports.dart');

        var import = lib.libraryImports
            .where((i) =>
        (i.uri is DirectiveUriWithRelativeUriString) &&
            (i.uri as DirectiveUriWithRelativeUriString).relativeUriString == path.basename(partId.path))
            .firstOrNull;

        if (import == null) {
          return;
        }

        var annotations = importChecker.annotationsOf(import);
        if (annotations.isEmpty) {
          return;
        }

        var entries = [];

        for (var annotation in annotations) {
          var url = annotation.getField('import')!.toStringValue()!;
          var show = annotation.getField('show')!.toListValue()!.map((s) {
            return s.toSymbolValue() ?? s.toStringValue() ?? s.toString();
          }).toList();
          var platform = annotation.getField('platform')!.getField('index')!.toIntValue()!;
          entries.add(ImportEntry(url, show, platform));
        }

        if (entries.isNotEmpty) {
          await buildStep.writeAsString(outputId, JsonEncoder.withIndent('  ').convert(entries));
        }
      }
    } catch (e, st) {
      print(e);
      print(st);
    }
  }

  @override
  Map<String, List<String>> get buildExtensions => const {
    '.dart': ['.imports.json']
  };
}