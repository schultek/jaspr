import 'dart:async';
import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as path;

import '../utils.dart';

class ImportsModuleBuilder implements Builder {
  ImportsModuleBuilder(BuilderOptions options);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    try {
      // Performance optimization
      var file = await buildStep.readAsString(buildStep.inputId);
      if (!file.contains('@Import')) {
        return;
      }

      if (!await buildStep.resolver.isLibrary(buildStep.inputId)) {
        return;
      }

      var lib = await buildStep.resolver.libraryFor(buildStep.inputId, allowSyntaxErrors: true);

      var outputId = buildStep.inputId.changeExtension('.imports.json');
      var partId = buildStep.inputId.changeExtension('.imports.dart');

      var import = lib.firstFragment.libraryImports
          .cast<ElementDirective>()
          .followedBy(lib.firstFragment.libraryExports)
          .where((ElementDirective e) => importChecker.firstAnnotationOf(e) != null)
          .where((ElementDirective e) {
            var uri = e.uri;
            if (uri is DirectiveUriWithRelativeUriString && uri.relativeUriString == path.basename(partId.path)) {
              return true;
            }
            log.severe(
              '@Import must only be applied to the respective "<filename>.imports.dart" import of a library. '
              'Instead found it on "${uri.toString()}" in library ${lib.firstFragment.source.uri.toString()}.',
            );
            return false;
          })
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

      await buildStep.writeAsString(outputId, jsonEncode(entries));
    } catch (e, st) {
      print(e);
      print(st);
    }
  }

  @override
  Map<String, List<String>> get buildExtensions => const {
    '.dart': ['.imports.json'],
  };
}
