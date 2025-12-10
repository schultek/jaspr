import 'dart:convert';

import '../../codec/sources/bundle.dart';
import '../../codec/sources/model_extension.dart';

final clientModelExtensionSources = {
  'site|lib/component_model_extension.dart': '''
    import 'package:jaspr/jaspr.dart';
    import 'model_type.dart';
    
    @client
    class Component extends StatelessComponent {
      Component(this.a, {required this.b, super.key});
      
      final String a;
      final ModelB b;
    
      @override
      Component build(BuildContext context) => text('');
    }
  ''',
  ...modelExtensionSources,
  ...codecBundleOutputs,
};

final clientModelExtensionModuleOutputs = {
  'site|lib/component_model_extension.client.module.json': jsonEncode({
    'name': 'Component',
    'id': ['site', 'lib/component_model_extension.dart'],
    'import': 'package:site/component_model_extension.dart',
    'params': [
      {'name': 'a', 'isNamed': false, 'decoder': "p['a'] as String", 'encoder': 'c.a'},
      {
        'name': 'b',
        'isNamed': true,
        'decoder': "[[package:site/model_extension.dart]].ModelBCodec.fromRaw(p['b'] as Map<String, dynamic>)",
        'encoder': '[[package:site/model_extension.dart]].ModelBCodec(c.b).toRaw()',
      },
    ],
  }),
};
