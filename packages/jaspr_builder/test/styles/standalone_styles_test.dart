import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:jaspr_builder/src/styles/styles_standalone_builder.dart';
import 'package:test/test.dart';

import 'sources/bundle.dart';
import 'sources/styles_class.dart';
import 'sources/styles_global.dart';
import 'sources/styles_standalone.dart';

void main() {
  group('standalone styles', () {
    late TestReaderWriter reader;

    setUp(() async {
      reader = TestReaderWriter(rootPackage: 'site');
    });

    test('generates standalone runner for server entrypoint', () async {
      await testBuilder(
        StylesStandaloneBuilder(BuilderOptions({})),
        {
          ...stylesClassSources,
          ...stylesGlobalSources,
          ...stylesBundleOutputs,
          ...stylesStandaloneServerSources,
        },
        outputs: stylesStandaloneServerOutputs,
        readerWriter: reader,
      );
    });

    test('generates standalone runner for client entrypoint', () async {
      await testBuilder(
        StylesStandaloneBuilder(BuilderOptions({})),
        {
          ...stylesClassSources,
          ...stylesGlobalSources,
          ...stylesBundleOutputs,
          ...stylesStandaloneClientSources,
        },
        outputs: stylesStandaloneClientOutputs,
        readerWriter: reader,
      );
    });
  });
}
