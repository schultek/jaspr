import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;

import '../utils.dart';

final path = p.posix;

class ImportsStubsBuilder implements Builder {
  ImportsStubsBuilder(BuilderOptions options);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    var imports = buildStep.findAssets(Glob('**/*.imports.json'));

    var webImports = <String, Set<String>>{};
    var vmImports = <String, Set<String>>{};

    var stubs = <String>{};

    await for (var id in imports) {
      var entries = jsonDecode(await buildStep.readAsString(id)) as Iterable;
      for (var entry in entries) {
        var url = entry['url'];
        var platform = entry['platform'];
        var show = entry['show'] as List;

        stubs.addAll(show.map((n) => 'dynamic $n;'));

        var types = show.where((n) => n.substring(0, 1).toLowerCase() != n.substring(0, 1));
        stubs.addAll(types.map((n) => 'typedef ${n}OrStubbed = dynamic;'));

        var uri = Uri.parse(url);
        if (uri.scheme.isEmpty && path.isRelative(uri.path)) {
          var absUrl = path.join(path.dirname(id.path), url);
          url = path.relative(absUrl, from: 'lib/generated/imports/_.dart');
        }

        if (platform == 0) {
          (webImports[url] ??= {}).addAll(show.cast());
        } else {
          (vmImports[url] ??= {}).addAll(show.cast());
        }
      }
    }

    if (vmImports.isNotEmpty) {
      await buildStep.writeAsString(
        AssetId(buildStep.inputId.package, 'lib/generated/imports/_vm.dart'),
        DartFormatter(
          languageVersion: DartFormatter.latestShortStyleLanguageVersion,
          pageWidth: 120,
        ).format("""
          $generationHeader
          // ignore_for_file: directives_ordering, deprecated_member_use
          
          ${vmImports.entries.where((e) => e.value.any((v) => v.isType)).map((e) => "import '${e.key}' show ${e.value.where((v) => v.isType).join(', ')};").join('\n')}
          ${vmImports.entries.map((e) => "export '${e.key}' show ${e.value.join(', ')};").join('\n')}
          
          ${vmImports.values.expand((v) => v.where((e) => e.isType)).map((e) => 'typedef ${e}OrStubbed = $e;').join('\n')}
        """),
      );
    }

    if (webImports.isNotEmpty) {
      await buildStep.writeAsString(
        AssetId(buildStep.inputId.package, 'lib/generated/imports/_web.dart'),
        DartFormatter(
          languageVersion: DartFormatter.latestShortStyleLanguageVersion,
          pageWidth: 120,
        ).format("""
          $generationHeader
          // ignore_for_file: directives_ordering, deprecated_member_use
          
          ${webImports.entries.where((e) => e.value.any((v) => v.isType)).map((e) => "import '${e.key}' show ${e.value.where((v) => v.isType).join(', ')};").join('\n')}
          ${webImports.entries.map((e) => "export '${e.key}' show ${e.value.join(', ')};").join('\n')}
          
          ${webImports.values.expand((v) => v.where((e) => e.isType)).map((e) => 'typedef ${e}OrStubbed = $e;').join('\n')}
        """),
      );
    }

    if (stubs.isNotEmpty) {
      await buildStep.writeAsString(
        AssetId(buildStep.inputId.package, 'lib/generated/imports/_stubs.dart'),
        DartFormatter(
          languageVersion: DartFormatter.latestShortStyleLanguageVersion,
          pageWidth: 120,
        ).format("""
         $generationHeader
         // ignore_for_file: directives_ordering, non_constant_identifier_names
         
         ${stubs.join('\n')}
        """),
      );
    }
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
