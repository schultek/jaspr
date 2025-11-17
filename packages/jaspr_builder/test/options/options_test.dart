import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:jaspr_builder/src/server/server_options_builder.dart';
import 'package:test/test.dart';

import 'sources/alternate_target_options.dart';
import 'sources/default_options.dart';

void main() {
  group('jaspr options builder', () {
    late TestReaderWriter reader;

    setUp(() async {
      reader = TestReaderWriter(rootPackage: 'models');
      await reader.testing.loadIsolateSources();
    });

    test('generates options', () async {
      await testBuilder(
        ServerOptionsBuilder(BuilderOptions({})),
        optionsSources,
        outputs: optionsOutputs,
        readerWriter: reader,
      );
    });

    test('generates options with alternate target', () async {
      await testBuilder(
        ServerOptionsBuilder(BuilderOptions({})),
        alternateTargetOptionsSources,
        outputs: alternateTargetOptionsOutputs,
        readerWriter: reader,
      );
    });
  });
}
