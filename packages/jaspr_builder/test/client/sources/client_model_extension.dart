import 'dart:convert';

import '../../codec/sources/model_extension.dart';

final clientModelExtensionSources = {
  'site|lib/component_model_extension.dart': '''
    import 'package:jaspr/jaspr.dart';
    import 'model_type.dart';
    
    @client
    class Component extends StatelessComponent {
      Component(this.a, {required this.b, super.key});
      
      final String a;
      final Model b;
    
      @override
      Iterable<Component> build(BuildContext context) => [];
    }
  ''',
  ...modelExtensionSources,
  ...modelExtensionOutputs,
};

final clientModelExtensionJsonOutputs = {
  'site|lib/component_model_extension.client.json': jsonEncode({
    "name": "Component",
    "id": ["site", "lib/component_model_extension.dart"],
    "params": [
      {"name": "a", "isNamed": false, "decoder": "p.get('a')", "encoder": "c.a"},
      {
        "name": "b",
        "isNamed": true,
        "decoder": "[[package:site/model_extension.dart]].ModelCodec.fromRaw(p.get('b'))",
        "encoder": "[[package:site/model_extension.dart]].ModelCodec(c.b).toRaw()",
      },
    ]
  }),
};

final clientModelExtensionDartOutputs = {
  'site|web/component_model_extension.client.dart': '// GENERATED FILE, DO NOT MODIFY\n'
      '// Generated with jaspr_builder\n'
      '\n'
      'import \'package:jaspr/browser.dart\';\n'
      'import \'package:site/component_model_extension.dart\' as prefix0;\n'
      'import \'package:site/model_extension.dart\' as prefix1;\n'
      '\n'
      'void main() {\n'
      '  runAppWithParams(getComponentForParams);\n'
      '}\n'
      '\n'
      'Component getComponentForParams(ConfigParams p) {\n'
      '  return prefix0.Component(p.get(\'a\'), b: prefix1.ModelCodec.fromRaw(p.get(\'b\')));\n'
      '}\n',
};
