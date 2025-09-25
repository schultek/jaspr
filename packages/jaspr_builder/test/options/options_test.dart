import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:jaspr_builder/src/options/jaspr_options_builder.dart';
import 'package:test/test.dart';

import 'sources/options.dart';

void main() {
  group('jaspr options builder', () {
    late TestReaderWriter reader;

    setUp(() async {
      reader = TestReaderWriter(rootPackage: 'models');
      await reader.testing.loadIsolateSources();
    });

    test('generates options', () async {
      await testBuilder(
        JasprOptionsBuilder(BuilderOptions({})),
        optionsSources,
        outputs: optionsOutputs,
        readerWriter: reader,
      );
    });
  });
}
