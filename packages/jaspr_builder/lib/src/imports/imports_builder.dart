import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;

import '../utils.dart';

final p.Context path = p.posix;

class ImportsOutputBuilder implements Builder {
  ImportsOutputBuilder(BuilderOptions options);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    try {
      final entries = (jsonDecode(await buildStep.readAsString(buildStep.inputId)) as List<Object?>)
          .cast<Map<String, Object?>>()
          .map(ImportEntry.fromJson)
          .toList()
          .sortedBy((e) => e.url);
      final outputId = buildStep.inputId.changeExtension('.dart');

      final webShow = <String>{};
      final vmShow = <String>{};

      for (final entry in entries) {
        final items = <String>[
          for (final elem in entry.elements) ...[
            elem.name,
            if (elem.type == ElementType.type) '${elem.name}OrStubbed',
          ],
        ];
        if (entry.platform == 0) {
          webShow.addAll(items);
        } else {
          vmShow.addAll(items);
        }
      }

      final outputDir = 'lib/generated/imports';
      final relativeDir = path.relative(outputDir, from: path.dirname(buildStep.inputId.path));

      await buildStep.writeAsFormattedDart(outputId, """
          ${webShow.isNotEmpty ? """
            export '$relativeDir/_web.dart' 
              if (dart.library.io) '$relativeDir/_stubs.dart' 
              show ${webShow.join(', ')};
          """ : ''}
          
          ${vmShow.isNotEmpty ? """
            export '$relativeDir/_vm.dart' 
              if (dart.library.js_interop) '$relativeDir/_stubs.dart' 
              show ${vmShow.join(', ')};
          """ : ''}
        """);
    } catch (e, st) {
      print(e);
      print(st);
    }
  }

  @override
  Map<String, List<String>> get buildExtensions => const {
    '.imports.json': ['.imports.dart'],
  };
}
