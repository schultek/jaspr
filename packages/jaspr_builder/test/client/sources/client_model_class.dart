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

final clientModelClassJsonOutputs = {
  'site|lib/component_model_class.client.json': jsonEncode({
    "name": "Component",
    "id": ["site", "lib/component_model_class.dart"],
    "import": "package:site/component_model_class.dart",
    "params": [
      {"name": "a", "isNamed": false, "decoder": "p.get<String>('a')", "encoder": "c.a"},
      {
        "name": "b",
        "isNamed": true,
        "decoder": "[[package:site/model_class.dart]].ModelA.fromRaw(p.get<Map<String, dynamic>>('b'))",
        "encoder": "c.b.toRaw()",
      },
    ],
  }),
};

final clientModelClassDartOutputs = {
  'site|lib/component_model_class.client.dart':
      '// dart format off\n'
      '// ignore_for_file: type=lint\n'
      '\n'
      '// GENERATED FILE, DO NOT MODIFY\n'
      '// Generated with jaspr_builder\n'
      '\n'
      'import \'package:jaspr/browser.dart\';\n'
      'import \'package:site/component_model_class.dart\' as prefix0;\n'
      'import \'package:site/model_class.dart\' as prefix1;\n'
      '\n'
      'Component getComponentForParams(ClientParams p) {\n'
      '  return prefix0.Component(\n'
      '    p.get<String>(\'a\'),\n'
      '    b: prefix1.ModelA.fromRaw(p.get<Map<String, dynamic>>(\'b\')),\n'
      '  );\n'
      '}\n',
};
