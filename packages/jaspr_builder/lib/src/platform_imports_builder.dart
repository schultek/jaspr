import 'dart:async';
import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:dart_style/dart_style.dart';
import 'package:jaspr/jaspr.dart';
import 'package:path/path.dart' as path;
import 'package:source_gen/source_gen.dart';
import 'package:glob/glob.dart';

import 'utils.dart';

class ImportEntry {
  String url;
  List<String> show;
  final int platform;

  ImportEntry(this.url, this.show, this.platform);

  Map<String, dynamic> toJson() {
    return {'url': url, 'show': show, 'platform': platform};
  }
}

var importChecker = TypeChecker.fromRuntime(Import);

class PlatformImportsBuilder implements Builder {
  PlatformImportsBuilder(BuilderOptions options);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    try {
      if (await buildStep.resolver.isLibrary(buildStep.inputId)) {
        var lib = await buildStep.resolver.libraryFor(buildStep.inputId, allowSyntaxErrors: true);

        var outputId = buildStep.inputId.changeExtension('.import.json');
        var partId = buildStep.inputId.changeExtension('.import.dart');

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
        '.dart': ['.import.json']
      };
}

class PlatformImportPartsBuilder implements Builder {
  PlatformImportPartsBuilder(BuilderOptions options);

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
        '.import.json': ['.import.dart']
      };
}


class PlatformStubsBuilder implements Builder {
  PlatformStubsBuilder(BuilderOptions options);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    var imports = buildStep.findAssets(Glob('**/*.import.json'));

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


extension TypeStub on String {

  bool get isType {
    var n = substring(0, 1);
    return n.toLowerCase() != n;
  }

}