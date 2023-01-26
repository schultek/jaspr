import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';

import '../utils.dart';

class ImportsStubsBuilder implements Builder {
  ImportsStubsBuilder(BuilderOptions options);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    var imports = buildStep.findAssets(Glob('**/*.imports.json'));

    var json = await imports
        .asyncMap((id) async => jsonDecode(await buildStep.readAsString(id)))
        .expand((e) => e as Iterable)
        .toList();

    var webImports = <String, List<String>>{};
    var vmImports = <String, List<String>>{};

    var stubs = <String>{};

    for (var entry in json) {
      var url = entry['url'];
      var platform = entry['platform'];
      var show = entry['show'] as List;

      stubs.addAll(show.map((n) => 'dynamic $n;'));

      var types = show.where((n) => n.substring(0, 1).toLowerCase() != n.substring(0, 1));
      stubs.addAll(types.map((n) => 'typedef ${n}OrStubbed = dynamic;'));



      if (platform == 0) {
        (webImports[url] ??= []).addAll(show.cast());
      } else {
        (vmImports[url] ??= []).addAll(show.cast());
      }
    }

    await buildStep.writeAsString(
      AssetId(buildStep.inputId.package, 'lib/generated/imports/_vm.dart'),
      DartFormatter().format("""
        $generationHeader
        
        ${vmImports.entries.map((e) => "import '${e.key}' show ${e.value.where((v) => v.isType).join(', ')};").join('\n')}
        ${vmImports.entries.map((e) => "export '${e.key}' show ${e.value.join(', ')};").join('\n')}
        
        ${vmImports.values.expand((v) => v.where((e) => e.isType)).map((e) => 'typedef ${e}OrStubbed = $e;').join('\n')}
      """),
    );

    await buildStep.writeAsString(
      AssetId(buildStep.inputId.package, 'lib/generated/imports/_web.dart'),
      DartFormatter().format("""
        $generationHeader
        
        ${webImports.entries.map((e) => "import '${e.key}' show ${e.value.where((v) => v.isType).join(', ')};").join('\n')}
        ${webImports.entries.map((e) => "export '${e.key}' show ${e.value.join(', ')};").join('\n')}
        
        ${webImports.values.expand((v) => v.where((e) => e.isType)).map((e) => 'typedef ${e}OrStubbed = $e;').join('\n')}
      """),
    );

    await buildStep.writeAsString(
      AssetId(buildStep.inputId.package, 'lib/generated/imports/_stubs.dart'),
      DartFormatter().format("""
       $generationHeader
       // ignore_for_file: non_constant_identifier_names
       
       ${stubs.join('\n')}
      """),
    );
  }

  @override
  Map<String, List<String>> get buildExtensions => const {
        r'lib/$lib$': [
          'lib/generated/imports/_stubs.dart',
          'lib/generated/imports/_web.dart',
          'lib/generated/imports/_vm.dart',
        ]
      };
}
