import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:jaspr_builder/src/options/client_options_builder.dart';
import 'package:test/test.dart';

import 'sources/client_options.dart';
import 'sources/client_options_other.dart';

void main() {
  group('jaspr options builder', () {
    late TestReaderWriter reader;

    setUp(() async {
      reader = TestReaderWriter(rootPackage: 'models');
      await reader.testing.loadIsolateSources();
    });

    test('generates options', () async {
      await testBuilder(
        ClientOptionsBuilder(BuilderOptions({})),
        clientOptionsSources,
        outputs: clientOptionsOutputs,
        readerWriter: reader,
      );
    });

    test('generates options with alternate entrypoint', () async {
      await testBuilder(
        ClientOptionsBuilder(BuilderOptions({})),
        clientOptionsOtherSources,
        outputs: clientOptionsOtherOutputs,
        readerWriter: reader,
      );
    });
  });
}
