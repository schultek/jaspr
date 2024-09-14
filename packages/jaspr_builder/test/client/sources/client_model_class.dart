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
      Iterable<Component> build(BuildContext context) => [];
    }
  ''',
  ...modelClassSources,
  ...codecBundleOutputs,
};

final clientModelClassJsonOutputs = {
  'site|lib/component_model_class.client.json': jsonEncode({
    "name": "Component",
    "id": "component_model_class",
    "import": "package:site/component_model_class.dart",
    "params": [
      {"name": "a", "isNamed": false, "decoder": "p['a']", "encoder": "c.a"},
      {
        "name": "b",
        "isNamed": true,
        "decoder": "[[package:site/model_class.dart]].ModelA.fromRaw(p['b'])",
        "encoder": "c.b.toRaw()",
      },
    ]
  }),
};

final clientModelClassDartOutputs = {
  'site|web/component_model_class.client.dart': '// GENERATED FILE, DO NOT MODIFY\n'
      '// Generated with jaspr_builder\n'
      '\n'
      'import \'package:jaspr/browser.dart\';\n'
      'import \'package:site/component_model_class.dart\' as prefix0;\n'
      'import \'package:site/model_class.dart\' as prefix1;\n'
      '\n'
      'void main() {\n'
      '  runAppWithParams(getComponentForParams);\n'
      '}\n'
      '\n'
      'Component getComponentForParams(Map<String, dynamic> p) {\n'
      '  return prefix0.Component(p[\'a\'], b: prefix1.ModelA.fromRaw(p[\'b\']));\n'
      '}\n',
};
