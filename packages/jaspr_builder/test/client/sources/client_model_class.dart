import 'dart:convert';

import '../../codec/sources/bundle.dart';
import '../../codec/sources/model_class.dart';

final clientModelClassSources = {
  'site|lib/component_model_class.dart': '''
    import 'package:jaspr/jaspr.dart';
    import 'model_class.dart';
    
    @client
    class Component extends StatelessComponent {
      Component(this.a, {required this.b, super.key});
      
      final String a;
      final ModelA b;
    
      @override
      Component build(BuildContext context) => text('');
    }
  ''',
  ...modelClassSources,
  ...codecBundleOutputs,
};

final clientModelClassModuleOutputs = {
  'site|lib/component_model_class.client.module.json': jsonEncode({
    'name': 'Component',
    'id': ['site', 'lib/component_model_class.dart'],
    'import': 'package:site/component_model_class.dart',
    'params': [
      {'name': 'a', 'isNamed': false, 'decoder': "p['a'] as String", 'encoder': 'c.a'},
      {
        'name': 'b',
        'isNamed': true,
        'decoder': "[[package:site/model_class.dart]].ModelA.fromRaw(p['b'] as Map<String, dynamic>)",
        'encoder': 'c.b.toRaw()',
      },
    ],
  }),
};
