import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:jaspr_builder/src/client/client_bundle_builder.dart';
import 'package:jaspr_builder/src/client/client_module_builder.dart';
import 'package:jaspr_builder/src/client/client_entrypoint_builder.dart';
import 'package:test/test.dart';

import 'sources/bundle.dart';
import 'sources/client_basic.dart';
import 'sources/client_invalid.dart';
import 'sources/client_model_class.dart';
import 'sources/client_model_extension.dart';
import 'sources/registry.dart';

void main() {
  group('client annotation', () {
    late TestReaderWriter reader;

    setUp(() async {
      reader = TestReaderWriter(rootPackage: 'models');
      await reader.testing.loadIsolateSources();
    });

    group('on basic component', () {
      test('generates json module', () async {
        await testBuilder(
          ClientModuleBuilder(BuilderOptions({})),
          clientBasicSources,
          outputs: {...clientBasicJsonOutputs, 'site|lib/component_basic.client.dart': isNotEmpty},
          readerWriter: reader,
        );
      });

      test('generates entrypoint', () async {
        await testBuilder(
          ClientModuleBuilder(BuilderOptions({})),
          clientBasicSources,
          outputs: {'site|lib/component_basic.client.json': isNotEmpty, ...clientBasicDartOutputs},
          readerWriter: reader,
        );
      });
    });

    group('on component using model class', () {
      test('generates json module', () async {
        await testBuilder(
          ClientModuleBuilder(BuilderOptions({})),
          clientModelClassSources,
          outputs: {...clientModelClassJsonOutputs, 'site|lib/component_model_class.client.dart': isNotEmpty},
          readerWriter: reader,
        );
      });

      test('generates entrypoint', () async {
        await testBuilder(
          ClientModuleBuilder(BuilderOptions({})),
          clientModelClassSources,
          outputs: {'site|lib/component_model_class.client.json': isNotEmpty, ...clientModelClassDartOutputs},
          readerWriter: reader,
        );
      });
    });

    group('on component using model extension', () {
      test('generates json module', () async {
        await testBuilder(
          ClientModuleBuilder(BuilderOptions({})),
          clientModelExtensionSources,
          outputs: {...clientModelExtensionJsonOutputs, 'site|lib/component_model_extension.client.dart': isNotEmpty},
          readerWriter: reader,
        );
      });

      test('generates entrypoint', () async {
        await testBuilder(
          ClientModuleBuilder(BuilderOptions({})),
          clientModelExtensionSources,
          outputs: {'site|lib/component_model_extension.client.json': isNotEmpty, ...clientModelExtensionDartOutputs},
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
            'ClientModuleBuilder on lib/component_basic.dart:\nClient components only support initializing formal constructor parameters. '
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
            'ClientModuleBuilder on lib/component_basic.dart:\n@client components only support parameters of primitive serializable types or types that define @decoder and @encoder methods. Failing parameter: [DateTime time] in Component.new()',
          ),
        );
      });
    });

    test('generates bundle', () async {
      await testBuilder(
        ClientsBundleBuilder(BuilderOptions({})),
        {...clientBasicJsonOutputs, ...clientModelClassJsonOutputs, ...clientModelExtensionJsonOutputs},
        outputs: clientBundleOutputs,
        readerWriter: reader,
      );
    });

    test('generates registry', () async {
      await testBuilder(
        ClientEntrypointBuilder(BuilderOptions({})),
        clientRegistrySources,
        outputs: clientRegistryOutputs,
        readerWriter: reader,
      );
    });
  });
}
