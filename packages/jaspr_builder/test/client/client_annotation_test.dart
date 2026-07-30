import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:jaspr_builder/src/client/client_bundle_builder.dart';
import 'package:jaspr_builder/src/client/client_module_builder.dart';
import 'package:test/test.dart';

import 'sources/bundle.dart';
import 'sources/client_basic.dart';
import 'sources/client_invalid.dart';
import 'sources/client_model_class.dart';
import 'sources/client_model_extension.dart';
import 'sources/client_with_server_components.dart';

void main() {
  group('client annotation', () {
    late TestReaderWriter reader;

    setUp(() async {
      reader = TestReaderWriter(rootPackage: 'site');
      await reader.testing.loadIsolateSources();
    });

    group('on basic component', () {
      test('generates json module', () async {
        await testBuilder(
          ClientModuleBuilder(BuilderOptions({})),
          clientBasicSources,
          outputs: {...clientBasicModuleOutputs},
          readerWriter: reader,
        );
      });
    });

    group('on component using model class', () {
      test('generates json module', () async {
        await testBuilder(
          ClientModuleBuilder(BuilderOptions({})),
          clientModelClassSources,
          outputs: {...clientModelClassModuleOutputs},
          readerWriter: reader,
        );
      });
    });

    group('on component using model extension', () {
      test('generates json module', () async {
        await testBuilder(
          ClientModuleBuilder(BuilderOptions({})),
          clientModelExtensionSources,
          outputs: {...clientModelExtensionModuleOutputs},
          readerWriter: reader,
        );
      });
    });

    group('on invalid component', () {
      test('constructor throws error', () async {
        String? errorLog;

        await testBuilder(
          ClientModuleBuilder(BuilderOptions({})),
          clientInvalidConstructorSources,
          outputs: {},
          onLog: (log) {
            if (log.level.name == 'SEVERE') {
              errorLog = log.message;
            }
          },
          readerWriter: reader,
        );

        expect(
          errorLog,
          equals(
            'ClientModuleBuilder on lib/component_basic.dart:\nClient components only support initializing formal constructor parameters.\n'
            'Failing element: Component.new(String a)',
          ),
        );
      });

      test('param throws error', () async {
        String? errorLog;

        await testBuilder(
          ClientModuleBuilder(BuilderOptions({})),
          clientInvalidParamSources,
          outputs: {},
          onLog: (log) {
            if (log.level.name == 'SEVERE') {
              errorLog = log.message;
            }
          },
          readerWriter: reader,
        );

        expect(
          errorLog,
          equals(
            'ClientModuleBuilder on lib/component_basic.dart:\n@client components only support parameters of primitive serializable types, Components or types that define @decoder and @encoder methods.\n'
            'Failing parameter: [DateTime time] in Component.new()',
          ),
        );
      });
    });

    group('on component with server components as params', () {
      test('generates json module', () async {
        await testBuilder(
          ClientModuleBuilder(BuilderOptions({})),
          clientWithServerComponentsSources,
          outputs: {...clientWithServerComponentsModuleOutputs},
          readerWriter: reader,
        );
      });
    });

    test('generates bundle', () async {
      await testBuilder(
        ClientsBundleBuilder(BuilderOptions({})),
        {
          ...clientBasicModuleOutputs,
          ...clientModelClassModuleOutputs,
          ...clientModelExtensionModuleOutputs,
          ...clientWithServerComponentsModuleOutputs,
        },
        outputs: clientBundleOutputs,
        readerWriter: reader,
      );
    });
  });
}
