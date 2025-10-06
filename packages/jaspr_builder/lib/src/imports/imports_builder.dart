import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:path/path.dart' as p;

import '../utils.dart';

final p.Context path = p.posix;

class ImportsOutputBuilder implements Builder {
  ImportsOutputBuilder(BuilderOptions options);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    try {
      var json = jsonDecode(await buildStep.readAsString(buildStep.inputId)) as List<Object?>;
      var outputId = buildStep.inputId.changeExtension('.dart');

      var webShow = <String>{};
      var vmShow = <String>{};

      for (var e in json.cast<Map<String, Object?>>()) {
        var platform = e['platform'] as int?;
        var show = (e['show'] as List<Object?>).cast<String>();

        var items = <String>[...show, ...show.where((v) => v.isType).map((v) => '${v}OrStubbed')];
        if (platform == 0) {
          webShow.addAll(items);
        } else {
          vmShow.addAll(items);
        }
      }

      var outputDir = 'lib/generated/imports';
      var relativeDir = path.relative(outputDir, from: path.dirname(buildStep.inputId.path));

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
