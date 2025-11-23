import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:jaspr_builder/src/sync/sync_mixins_builder.dart';
import 'package:test/test.dart';

import 'sources/sync_basic.dart';
import 'sources/sync_invalid.dart';
import 'sources/sync_model_class.dart';
import 'sources/sync_model_extension.dart';
import 'sources/sync_multi.dart';

void main() {
  group('sync annotation', () {
    late TestReaderWriter reader;

    setUp(() async {
      reader = TestReaderWriter(rootPackage: 'site');
      await reader.testing.loadIsolateSources();
    });

    group('on basic component', () {
      test('generates mixin', () async {
        await testBuilder(
          SyncMixinsBuilder(BuilderOptions({})),
          syncBasicSources,
          outputs: syncBasicOutputs,
          readerWriter: reader,
        );
      });
    });

    group('on multiple components', () {
      test('generates mixins', () async {
        await testBuilder(
          SyncMixinsBuilder(BuilderOptions({})),
          syncMultiSources,
          outputs: syncMultiOutputs,
          readerWriter: reader,
        );
      });
    });

    group('on component using model class', () {
      test('generates mixins', () async {
        await testBuilder(
          SyncMixinsBuilder(BuilderOptions({})),
          syncModelClassSources,
          outputs: syncModelClassOutputs,
          readerWriter: reader,
        );
      });
    });

    group('on component using model extension', () {
      test('generates mixins', () async {
        await testBuilder(
          SyncMixinsBuilder(BuilderOptions({})),
          syncModelExtensionSources,
          outputs: syncModelExtensionOutputs,
          readerWriter: reader,
        );
      });
    });

    group('on invalid', () {
      test('map parameter throws error', () async {
        String? errorLog;

        await testBuilder(
          SyncMixinsBuilder(BuilderOptions({})),
          syncInvalidMapSources,
          outputs: {},
          readerWriter: reader,
          onLog: (log) {
            if (log.level.name == 'SEVERE') {
              errorLog = log.message;
            }
          },
        );

        expect(
          errorLog,
          equals(
            'SyncMixinsBuilder on lib/component.dart:\nFields annotated with @sync must have a primitive serializable type or a type that defines @decoder and @encoder methods. Failing field: [Map<int, int> a] in ComponentState',
          ),
        );
      });

      test('type parameter throws error', () async {
        String? errorLog;

        await testBuilder(
          SyncMixinsBuilder(BuilderOptions({})),
          syncInvalidTypeSources,
          outputs: {},
          readerWriter: reader,
          onLog: (log) {
            if (log.level.name == 'SEVERE') {
              errorLog = log.message;
            }
          },
        );

        expect(
          errorLog,
          equals(
            'SyncMixinsBuilder on lib/component.dart:\nFields annotated with @sync must have a primitive serializable type or a type that defines @decoder and @encoder methods. Failing field: [DateTime time] in ComponentState',
          ),
        );
      });
    });
  });
}
