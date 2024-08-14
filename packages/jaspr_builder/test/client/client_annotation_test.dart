import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:jaspr_builder/src/client/client_module_builder.dart';
import 'package:test/test.dart';

import 'sources/client_basic.dart';
import 'sources/client_model_class.dart';
import 'sources/client_model_extension.dart';

void main() {
  group('client annotation', () {
    group('on basic component', () {
      test('generates json module', () async {
        await testBuilder(
          ClientModuleBuilder(BuilderOptions({})),
          clientBasicSources,
          outputs: {
            ...clientBasicJsonOutputs,
            'site|web/component_basic.client.dart': isNotEmpty,
          },
          reader: await PackageAssetReader.currentIsolate(),
        );
      });

      test('generates web entrypoint', () async {
        await testBuilder(
          ClientModuleBuilder(BuilderOptions({})),
          clientBasicSources,
          outputs: {
            'site|lib/component_basic.client.json': isNotEmpty,
            ...clientBasicDartOutputs,
          },
          reader: await PackageAssetReader.currentIsolate(),
        );
      });
    });

    group('on component using model class', () {
      test('generates json module', () async {
        await testBuilder(
          ClientModuleBuilder(BuilderOptions({})),
          clientModelClassSources,
          outputs: {
            ...clientModelClassJsonOutputs,
            'site|web/component_model.client.dart': isNotEmpty,
          },
          reader: await PackageAssetReader.currentIsolate(),
        );
      });

      test('generates web entrypoint', () async {
        await testBuilder(
          ClientModuleBuilder(BuilderOptions({})),
          clientModelClassSources,
          outputs: {
            'site|lib/component_model.client.json': isNotEmpty,
            ...clientModelClassDartOutputs,
          },
          reader: await PackageAssetReader.currentIsolate(),
        );
      });
    });

    group('on component using model extension', () {
      test('generates json module', () async {
        await testBuilder(
          ClientModuleBuilder(BuilderOptions({})),
          clientModelExtensionSources,
          outputs: {
            ...clientModelExtensionJsonOutputs,
            'site|web/component_model.client.dart': isNotEmpty,
          },
          reader: await PackageAssetReader.currentIsolate(),
        );
      });

      test('generates web entrypoint', () async {
        await testBuilder(
          ClientModuleBuilder(BuilderOptions({})),
          clientModelExtensionSources,
          outputs: {
            'site|lib/component_model.client.json': isNotEmpty,
            ...clientModelExtensionDartOutputs,
          },
          reader: await PackageAssetReader.currentIsolate(),
        );
      });
    });
  });
}
