import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:glob/glob.dart';

import 'codec_module_builder.dart';

/// Builds bundle for all codec modules.
class CodecBundleBuilder implements Builder {
  CodecBundleBuilder(BuilderOptions options);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    try {
      await generateCodecBundle(buildStep);
    } on SyntaxErrorInAssetException {
      rethrow;
    } catch (e, st) {
      print(
        'An unexpected error occurred.\n'
        'This is probably a bug in jaspr_builder.\n'
        'Please report this here: '
        'https://github.com/schultek/jaspr/issues\n\n'
        'The error was:\n$e\n\n$st',
      );
      rethrow;
    }
  }

  @override
  Map<String, List<String>> get buildExtensions => const {
    r'lib/$lib$': ['lib/codec.bundle.json'],
  };

  Future<void> generateCodecBundle(BuildStep buildStep) async {
    final modules = buildStep
        .findAssets(Glob('lib/**.codec.json'))
        .asyncMap((id) => buildStep.readAsString(id))
        .map((c) => CodecModule.deserialize(jsonDecode(c) as Map<String, Object?>));
    final bundle = <Map<String, Object?>>[
      await for (final module in modules)
        for (final element in module.elements) element.serialize(),
    ];

    if (bundle.isEmpty) return;

    final outputId = AssetId(buildStep.inputId.package, 'lib/codec.bundle.json');
    await buildStep.writeAsString(outputId, jsonEncode(bundle));
  }
}
