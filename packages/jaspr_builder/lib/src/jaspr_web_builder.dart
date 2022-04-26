import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as path;

import './generators/element_generator.dart';
import './utils.dart';

/// The main builder used for code generation
class JasprWebBuilder implements Builder {
  JasprWebBuilder(BuilderOptions options);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    var inputId = buildStep.inputId;
    var name = path.basename(inputId.path).split('.').first;

    try {
      var stubSource = generateStub(buildStep);
      await buildStep.writeAsString(
        AssetId(inputId.package, inputId.path.replaceFirst('.web.dart', '.stub.dart')),
        stubSource,
      );

      var baseSource = generateBase(name);
      await buildStep.writeAsString(
        AssetId(inputId.package, inputId.path.replaceFirst('.web.dart', '.dart')),
        baseSource,
      );
    } catch (e, st) {
      print('An unexpected error occurred.\n'
          'This is probably a bug in jaspr_web_builder.\n'
          'Please report this here: '
          'https://github.com/schultek/jaspr/issues\n\n'
          'The error was:\n$e\n\n$st');
      rethrow;
    }
  }

  @override
  Map<String, List<String>> get buildExtensions => const {
        '.web.dart': ['.stub.dart', '.dart']
      };

  String get generationHeader => "// GENERATED FILE, DO NOT MODIFY\n"
      "// Generated with jaspr_web_builder\n";

  final webSdks = ['dart:html', 'dart:js', 'dart:svg', 'dart:indexed_db'];

  Future<String> generateStub(BuildStep buildStep) async {
    //return DartFormatter(pageWidth: 120).format(generationHeader);

    var imports = <String>{};
    var output = StringBuffer();
    var toGenerate = <Element>[];
    var didGenerate = <Element>{};

    bool checkInSdk(Element e) {
      if (e.library == null || !e.library!.isInSdk || e.library!.isPrivate) {
        return false;
      }
      var source = e.librarySource?.uri.toString() ?? '';
      var isWebSdk = webSdks.contains(source);
      if (isWebSdk) {
        return false;
      }
      imports.add(source);
      return true;
    }

    bool canResolve(DartType t) => t.transitiveElements //
        .every((e) => checkInSdk(e) || didGenerate.contains(e) || toGenerate.contains(e));

    var lib = await buildStep.inputLibrary;

    toGenerate.addAll(lib.topLevelElements);

    for (var export in lib.exports) {
      List<String>? showNames;

      if (export.combinators.length == 1 && export.combinators.first is ShowElementCombinator) {
        var c = export.combinators.first as ShowElementCombinator;
        showNames = c.shownNames;
      }

      if (showNames == null) {
        throw UnsupportedError('Exports must have an explicit show combinator.');
      }

      for (var name in showNames) {
        var element = export.exportedLibrary!.exportNamespace.get(name)!;
        toGenerate.add(element);
      }
    }

    while (toGenerate.isNotEmpty) {
      var e = toGenerate.removeLast();
      didGenerate.add(e);

      var generator = ElementGenerator.from(e, canResolve);

      var transitives = generator.getTransitiveElements(recursive: e.library == lib);
      for (var e in transitives) {
        if (!checkInSdk(e) && !didGenerate.contains(e) && !toGenerate.contains(e)) {
          toGenerate.add(e);
        }
      }

      var source = generator.generate();
      if (source.isNotEmpty) {
        output.writeln(source + '\n');
      }
    }

    return DartFormatter(pageWidth: 120).format('$generationHeader'
        '// ignore_for_file: annotate_overrides, non_constant_identifier_names, unused_element, avoid_renaming_method_parameters\n\n'
        '${imports.map((i) => "import '$i';").join('\n')}'
        '$output');
  }

  Future<String> generateBase(String fileName) async {
    return "$generationHeader\n"
        "export '$fileName.stub.dart' "
        "if (dart.library.html) '$fileName.web.dart';";
  }
}
