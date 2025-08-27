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
      Iterable<Component> build(BuildContext context) => [];
    }
  ''',
  ...modelExtensionSources,
  ...codecBundleOutputs,
};

final clientModelExtensionJsonOutputs = {
  'site|lib/component_model_extension.client.json': jsonEncode({
    "name": "Component",
    "id": ["site", "lib/component_model_extension.dart"],
    "import": "package:site/component_model_extension.dart",
    "params": [
      {"name": "a", "isNamed": false, "decoder": "p['a']", "encoder": "c.a"},
      {
        "name": "b",
        "isNamed": true,
        "decoder": "[[package:site/model_extension.dart]].ModelBCodec.fromRaw(p['b'])",
        "encoder": "[[package:site/model_extension.dart]].ModelBCodec(c.b).toRaw()",
      },
    ]
  }),
};

final clientModelExtensionDartOutputs = {
  'site|lib/component_model_extension.client.dart': '// dart format off\n'
      '// ignore_for_file: type=lint\n'
      '\n'
      '// GENERATED FILE, DO NOT MODIFY\n'
      '// Generated with jaspr_builder\n'
      '\n'
      'import \'package:jaspr/browser.dart\';\n'
      'import \'package:site/component_model_extension.dart\' as prefix0;\n'
      'import \'package:site/model_extension.dart\' as prefix1;\n'
      '\n'
      'Component getComponentForParams(Map<String, dynamic> p) {\n'
      '  return prefix0.Component(p[\'a\'], b: prefix1.ModelBCodec.fromRaw(p[\'b\']));\n'
      '}\n'
      '',
};
