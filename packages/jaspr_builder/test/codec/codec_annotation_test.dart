import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:jaspr_builder/src/codec/codec_bundle_builder.dart';
import 'package:jaspr_builder/src/codec/codec_module_builder.dart';
import 'package:test/test.dart';

import 'sources/bundle.dart';
import 'sources/model_class.dart';
import 'sources/model_extension.dart';

void main() {
  group('codec annotation', () {
    group('on model class', () {
      test('generates json module', () async {
        await testBuilder(
          CodecModuleBuilder(BuilderOptions({})),
          modelClassSources,
          outputs: modelClassOutputs,
          reader: await PackageAssetReader.currentIsolate(),
        );
      });
    });

    group('on extension type', () {
      test('generates json module', () async {
        await testBuilder(
          CodecModuleBuilder(BuilderOptions({})),
          modelExtensionSources,
          outputs: modelExtensionOutputs,
          reader: await PackageAssetReader.currentIsolate(),
        );
      });
    });

    test('generates bundle', () async {
      await testBuilder(
        CodecBundleBuilder(BuilderOptions({})),
        {...modelClassOutputs, ...modelExtensionOutputs},
        outputs: codecBundleOutputs,
        reader: await PackageAssetReader.currentIsolate(),
      );
    });
  });
}
