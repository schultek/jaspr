import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:jaspr_builder/src/codec/codec_bundle_builder.dart';
import 'package:jaspr_builder/src/codec/codec_module_builder.dart';
import 'package:test/test.dart';

import '../test_helper.dart';
import 'sources/bundle.dart';
import 'sources/model_class.dart';
import 'sources/model_enum.dart';
import 'sources/model_extension.dart';
import 'sources/model_with_mount.dart';

void main() {
  group('codec annotation', () {
    late TestReaderWriter reader;

    setUp(() async {
      reader = await createTestReaderWriter();
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

    group('on enum', () {
      test('generates json module', () async {
        await testBuilder(
          CodecModuleBuilder(BuilderOptions({})),
          modelEnumSources,
          outputs: modelEnumOutputs,
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

    group('on model with mount parameter', () {
      test('generates json module with hasMount and mountParam', () async {
        await testBuilder(
          CodecModuleBuilder(BuilderOptions({})),
          modelWithMountSources,
          outputs: modelWithMountOutputs,
          readerWriter: reader,
        );
      });

      test('invalid mount parameter throws error', () async {
        final errorLogs = <String>[];

        await testBuilder(
          CodecModuleBuilder(BuilderOptions({})),
          modelWithInvalidMountSources,
          outputs: {},
          readerWriter: reader,
          onLog: (log) {
            if (log.level.name == 'SEVERE') {
              errorLogs.add(log.message);
            }
          },
        );

        expect(
          errorLogs,
          contains(
            'CodecModuleBuilder on lib/model_invalid_mount.dart:\n'
            'The second parameter of @decoder must be a function matching "ComponentMount". Failing element: ModelInvalidMount.fromRaw() in library /site/lib/model_invalid_mount.dart.',
          ),
        );
      });

      test('mount parameter with incompatible return type throws error', () async {
        final errorLogs = <String>[];

        await testBuilder(
          CodecModuleBuilder(BuilderOptions({})),
          modelWithIncompatibleReturnMountSources,
          outputs: {},
          readerWriter: reader,
          onLog: (log) {
            if (log.level.name == 'SEVERE') {
              errorLogs.add(log.message);
            }
          },
        );

        expect(
          errorLogs,
          contains(
            'CodecModuleBuilder on lib/model_incompatible_return_mount.dart:\n'
            'The second parameter of @decoder must be a function matching "ComponentMount". Failing element: ModelIncompatibleReturnMount.fromRaw() in library /site/lib/model_incompatible_return_mount.dart.',
          ),
        );
      });

      test('mount parameter with incompatible parameter type throws error', () async {
        final errorLogs = <String>[];

        await testBuilder(
          CodecModuleBuilder(BuilderOptions({})),
          modelWithIncompatibleParamMountSources,
          outputs: {},
          readerWriter: reader,
          onLog: (log) {
            if (log.level.name == 'SEVERE') {
              errorLogs.add(log.message);
            }
          },
        );

        expect(
          errorLogs,
          contains(
            'CodecModuleBuilder on lib/model_incompatible_param_mount.dart:\n'
            'The second parameter of @decoder must be a function matching "ComponentMount". Failing element: ModelIncompatibleParamMount.fromRaw() in library /site/lib/model_incompatible_param_mount.dart.',
          ),
        );
      });
    });

    test('generates bundle', () async {
      await testBuilder(
        CodecBundleBuilder(BuilderOptions({})),
        {...modelClassOutputs, ...modelEnumOutputs, ...modelExtensionOutputs},
        outputs: codecBundleOutputs,
      );
    });
  });
}
