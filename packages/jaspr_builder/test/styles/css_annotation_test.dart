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
    group('on global elements', () {
      test('generates json module', () async {
        await testBuilder(
          StylesModuleBuilder(BuilderOptions({})),
          stylesGlobalSources,
          outputs: stylesGlobalOutputs,
          reader: await PackageAssetReader.currentIsolate(),
        );
      });
    });

    group('on class elements', () {
      test('generates json module', () async {
        await testBuilder(
          StylesModuleBuilder(BuilderOptions({})),
          stylesClassSources,
          outputs: stylesClassOutputs,
          reader: await PackageAssetReader.currentIsolate(),
        );
      });
    });

    test('generates bundle', () async {
      await testBuilder(
        StylesBundleBuilder(BuilderOptions({})),
        {
          ...stylesClassOutputs,
          ...stylesGlobalOutputs,
        },
        outputs: stylesBundleOutputs,
        reader: await PackageAssetReader.currentIsolate(),
      );
    });
  });
}
