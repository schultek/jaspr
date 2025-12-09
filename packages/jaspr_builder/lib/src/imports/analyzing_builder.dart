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
      final file = await buildStep.readAsString(buildStep.inputId);
      if (!file.contains('@Import')) {
        return;
      }

      if (!await buildStep.resolver.isLibrary(buildStep.inputId)) {
        return;
      }

      final lib = await buildStep.resolver.libraryFor(buildStep.inputId, allowSyntaxErrors: true);

      final outputId = buildStep.inputId.changeExtension('.imports.json');
      final partId = buildStep.inputId.changeExtension('.imports.dart');

      final import = lib.firstFragment.libraryImports
          .cast<ElementDirective>()
          .followedBy(lib.firstFragment.libraryExports)
          .where((ElementDirective e) => importChecker.firstAnnotationOf(e) != null)
          .where((ElementDirective e) {
            final uri = e.uri;
            if (uri is DirectiveUriWithRelativeUriString && uri.relativeUriString == path.basename(partId.path)) {
              return true;
            }
            log.severe(
              '@Import must only be applied to the respective "<filename>.imports.dart" import of a library. '
              'Instead found it on "$uri" in library ${lib.firstFragment.source.uri}.',
            );
            return false;
          })
          .firstOrNull;

      if (import == null) {
        return;
      }

      final annotations = importChecker.annotationsOf(import);
      if (annotations.isEmpty) {
        return;
      }

      final entries = <ImportEntry>[];

      for (final annotation in annotations) {
        final url = annotation.getField('import')!.toStringValue()!;
        final show = annotation.getField('show')!.toListValue()!.map((s) {
          return s.toSymbolValue() ?? s.toStringValue() ?? s.toString();
        }).toList();
        final platform = annotation.getField('platform')!.getField('index')!.toIntValue()!;

        try {
          final libUri = Uri.parse(url);
          if (libUri.scheme == 'dart') {
            final lib = (await buildStep.resolver.libraries.where((lib) {
              return lib.isInSdk && lib.uri == libUri;
            }).toList()).firstOrNull;
            if (lib == null) {
              throw NonLibraryAssetException(AssetId('', url));
            }
            entries.add(ImportEntry.from(url, show, platform, lib));
          } else {
            final libId = AssetId.resolve(libUri, from: buildStep.inputId);
            final lib = await buildStep.resolver.libraryFor(libId, allowSyntaxErrors: true);
            entries.add(ImportEntry.from(url, show, platform, lib));
          }
        } on NonLibraryAssetException {
          log.severe(
            'Could not resolve import "$url" in @Import annotation in '
            'library ${buildStep.inputId.uri}. Make sure the import URI is correct.',
          );
        }
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
