import 'dart:async';

import 'package:build/build.dart';
import 'package:path/path.dart' as path;

/// The main builder used for code generation
class JasprWebBuilder implements Builder {
  JasprWebBuilder(BuilderOptions options);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    var inputId = buildStep.inputId;
    var name = path.basenameWithoutExtension(inputId.path);

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

  Future<String> generateStub(BuildStep buildStep) async {
    return '$generationHeader\n';
  }

  Future<String> generateBase(String fileName) async {
    return "$generationHeader\n"
        "export '$fileName.stub.dart' "
        "if (dart.library.html) '$fileName.web.dart';";
  }
}
