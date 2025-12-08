import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:jaspr_builder/src/imports/analyzing_builder.dart';
import 'package:jaspr_builder/src/imports/imports_builder.dart';
import 'package:jaspr_builder/src/imports/stubs_builder.dart';
import 'package:test/test.dart';

import 'sources/imports.dart';

void main() {
  group('import annotation', () {
    late TestReaderWriter reader;

    setUp(() async {
      reader = TestReaderWriter(rootPackage: 'models');
      await reader.testing.loadIsolateSources();
    });

    test('generates json module', () async {
      await testBuilder(
        ImportsModuleBuilder(BuilderOptions({})),
        importsSources,
        outputs: importsModuleOutput,
        readerWriter: reader,
      );
    });

    test('generates dart output', () async {
      await testBuilder(
        ImportsOutputBuilder(BuilderOptions({})),
        {...importsSources, ...importsModuleOutput},
        outputs: importsOutput,
        readerWriter: reader,
      );
    });

    test('generates stubs', () async {
      await testBuilder(
        ImportsStubsBuilder(BuilderOptions({})),
        {...importsSources, ...importsModuleOutput},
        outputs: importsStubsOutput,
        readerWriter: reader,
      );
    });

    test('throws on conflicting names', () async {
      final result = await testBuilder(
        ImportsStubsBuilder(BuilderOptions({})),
        {
          ...importsSources,
          ...conflictingImportsSources,
          ...importsModuleOutput,
          ...conflictingImportsModuleOutput,
        },
        readerWriter: reader,
      );

      expect(result.succeeded, isFalse);
      expect(result.errors, hasLength(1));
      expect(
        result.errors.first,
        equals(
          'Exception: Cannot import Document from package:jaspr/client.dart, because it is also imported from dart:html. '
          'Names imported via @Import must be unique for each platform across the project.',
        ),
      );
    });
  });
}
