import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';

import '../utils.dart';


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

      await buildStep.writeAsString(outputId, DartFormatter().format("""
        $generationHeader
        
        ${webShow.isNotEmpty ? """
          export 'generated/imports/_web.dart' 
            if (dart.library.io) 'generated/imports/_stubs.dart' 
            show ${webShow.join(', ')};
        """ : ''}
        
        ${vmShow.isNotEmpty ? """
          export 'generated/imports/_vm.dart' 
            if (dart.library.html) 'generated/imports/_stubs.dart' 
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

