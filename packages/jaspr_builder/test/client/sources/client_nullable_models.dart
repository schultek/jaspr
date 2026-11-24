import 'dart:convert';

import '../../codec/sources/bundle.dart';
import '../../codec/sources/model_class.dart';
import '../../codec/sources/model_extension.dart';

final clientNullableModelsSources = {
  'site|lib/nullable_models.dart': '''
    import 'package:jaspr/jaspr.dart';
    import 'model_class.dart';
    import 'model_type.dart';

    @client
    class NullableModels extends StatelessComponent {
      const NullableModels({this.model, this.extensionModel, this.models, this.extensionModels, super.key});

      final ModelA? model;
      final ModelB? extensionModel;
      final List<ModelA?>? models;
      final Map<String, ModelB?>? extensionModels;

      @override
      Component build(BuildContext context) => text('');
    }
  ''',
  ...modelClassSources,
  ...modelExtensionSources,
  ...codecBundleOutputs,
};

final clientNullableModelsModuleData = {
  'name': 'NullableModels',
  'id': ['site', 'lib/nullable_models.dart'],
  'import': 'package:site/nullable_models.dart',
  'params': [
    {
      'name': 'model',
      'isNamed': true,
      'decoder': "switch (p.get<Map<String, dynamic>?>('model')) { final v? => [[package:site/model_class.dart]].ModelA.fromRaw(v), _ => null }",
      'encoder': 'c.model?.toRaw()',
    },
    {
      'name': 'extensionModel',
      'isNamed': true,
      'decoder': "switch (p.get<Map<String, dynamic>?>('extensionModel')) { final v? => [[package:site/model_extension.dart]].ModelBCodec.fromRaw(v), _ => null }",
      'encoder': 'c.extensionModel != null ? [[package:site/model_extension.dart]].ModelBCodec(c.extensionModel!).toRaw() : null',
    },
    {
      'name': 'models',
      'isNamed': true,
      'decoder': "p.get<List<Object?>?>('models')?.cast<Map<String, dynamic>?>().map((i) => switch (i) { final v? => [[package:site/model_class.dart]].ModelA.fromRaw(v), _ => null }).toList()",
      'encoder': 'c.models?.map((i) => i?.toRaw()).toList()',
    },
    {
      'name': 'extensionModels',
      'isNamed': true,
      'decoder': "p.get<Map<String, Object?>?>('extensionModels')?.cast<String, Map<String, dynamic>?>().map((k, v) => MapEntry(k, switch (v) { final v? => [[package:site/model_extension.dart]].ModelBCodec.fromRaw(v), _ => null }))",
      'encoder': 'c.extensionModels?.map((k, v) => MapEntry(k, v != null ? [[package:site/model_extension.dart]].ModelBCodec(v!).toRaw() : null))',
    },
  ],
};

final clientNullableModelsModuleOutputs = {
  'site|lib/nullable_models.client.module.json': jsonEncode(clientNullableModelsModuleData),
};
