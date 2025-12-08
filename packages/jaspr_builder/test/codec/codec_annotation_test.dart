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
    late TestReaderWriter reader;

    setUp(() async {
      reader = TestReaderWriter(rootPackage: 'site');
      await reader.testing.loadIsolateSources();
    });

    group('on model class', () {
      test('generates json module', () async {
        await testBuilder(
          CodecModuleBuilder(BuilderOptions({})),
          modelClassSources,
          outputs: modelClassOutputs,
          readerWriter: reader,
        );
      });
    });

    group('on extension type', () {
      test('generates json module', () async {
        await testBuilder(
          CodecModuleBuilder(BuilderOptions({})),
          modelExtensionSources,
          outputs: modelExtensionOutputs,
          readerWriter: reader,
        );
      });
    });

    test('generates bundle', () async {
      await testBuilder(
        CodecBundleBuilder(BuilderOptions({})),
        {...modelClassOutputs, ...modelExtensionOutputs},
        outputs: codecBundleOutputs,
        readerWriter: reader,
      );
    });
  });
}
