import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as p;

import '../utils.dart';

var path = p.posix;

class ImportsOutputBuilder implements Builder {
  ImportsOutputBuilder(BuilderOptions options);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    try {
      var json = jsonDecode(await buildStep.readAsString(buildStep.inputId));
      var outputId = buildStep.inputId.changeExtension('.dart');

      var webShow = <String>{};
      var vmShow = <String>{};

      for (var e in json) {
        var platform = e['platform'];
        var show = (e['show'] as List).cast<String>();

        var items = <String>[...show, ...show.where((v) => v.isType).map((v) => '${v}OrStubbed')];
        if (platform == 0) {
          webShow.addAll(items);
        } else {
          vmShow.addAll(items);
        }
      }

      var outputDir = 'lib/generated/imports';
      var relativeDir = path.relative(outputDir, from: path.dirname(buildStep.inputId.path));

      await buildStep.writeAsString(
          outputId,
          DartFormatter().format("""
        $generationHeader
        
        ${webShow.isNotEmpty ? """
          export '$relativeDir/_web.dart' 
            if (dart.library.io) '$relativeDir/_stubs.dart' 
            show ${webShow.join(', ')};
        """ : ''}
        
        ${vmShow.isNotEmpty ? """
          export '$relativeDir/_vm.dart' 
            if (dart.library.html) '$relativeDir/_stubs.dart' 
            show ${vmShow.join(', ')};
        """ : ''}
      """));
    } catch (e, st) {
      print(e);
      print(st);
    }
  }

  @override
  Map<String, List<String>> get buildExtensions => const {
        '.imports.json': ['.imports.dart']
      };
}
