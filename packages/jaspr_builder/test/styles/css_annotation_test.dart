import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:jaspr_builder/src/styles/styles_bundle_builder.dart';
import 'package:jaspr_builder/src/styles/styles_module_builder.dart';
import 'package:test/test.dart';

import 'sources/bundle.dart';
import 'sources/styles_class.dart';
import 'sources/styles_global.dart';

void main() {
  group('css annotation', () {
    late TestReaderWriter reader;

    setUp(() async {
      reader = TestReaderWriter(rootPackage: 'models');
      await reader.testing.loadIsolateSources();
    });

    group('on global elements', () {
      test('generates json module', () async {
        await testBuilder(
          StylesModuleBuilder(BuilderOptions({})),
          stylesGlobalSources,
          outputs: stylesGlobalOutputs,
          readerWriter: reader,
        );
      });
    });

    group('on class elements', () {
      test('generates json module', () async {
        await testBuilder(
          StylesModuleBuilder(BuilderOptions({})),
          stylesClassSources,
          outputs: stylesClassOutputs,
          readerWriter: reader,
        );
      });
    });

    test('generates bundle', () async {
      await testBuilder(
        StylesBundleBuilder(BuilderOptions({})),
        {...stylesClassOutputs, ...stylesGlobalOutputs},
        outputs: stylesBundleOutputs,
        readerWriter: reader,
      );
    });
  });
}
