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
    group('on basic component', () {
      test('generates mixin', () async {
        await testBuilder(
          SyncMixinsBuilder(BuilderOptions({})),
          syncBasicSources,
          outputs: syncBasicOutputs,
          reader: await PackageAssetReader.currentIsolate(),
        );
      });
    });

    group('on multiple components', () {
      test('generates mixins', () async {
        await testBuilder(
          SyncMixinsBuilder(BuilderOptions({})),
          syncMultiSources,
          outputs: syncMultiOutputs,
          reader: await PackageAssetReader.currentIsolate(),
        );
      });
    });

    group('on component using model class', () {
      test('generates mixins', () async {
        await testBuilder(
          SyncMixinsBuilder(BuilderOptions({})),
          syncModelClassSources,
          outputs: syncModelClassOutputs,
          reader: await PackageAssetReader.currentIsolate(),
        );
      });
    });

    group('on component using model extension', () {
      test('generates mixins', () async {
        await testBuilder(
          SyncMixinsBuilder(BuilderOptions({})),
          syncModelExtensionSources,
          outputs: syncModelExtensionOutputs,
          reader: await PackageAssetReader.currentIsolate(),
        );
      });
    });

    group('on invalid component', () {
      test('parameter throws error', () async {
        String? errorLog;

        await testBuilder(
          SyncMixinsBuilder(BuilderOptions({})),
          syncInvalidSources,
          outputs: {},
          reader: await PackageAssetReader.currentIsolate(),
          onLog: (log) {
            if (log.level.name == 'SEVERE') {
              errorLog = log.message;
            }
          },
        );

        expect(
          errorLog,
          equals('Unsupported Map key type: Expected String, found int'),
        );
      });
    });
  });
}
