import 'dart:convert';

import '../../codec/sources/model_extension.dart';
import 'client_model.dart';

final clientModelExtensionSources = {
  ...clientModelSources,
  ...modelExtensionSources,
  ...modelExtensionOutputs,
};

final clientModelExtensionJsonOutputs = {
  'site|lib/component_model.client.json': jsonEncode({
    "name": "Component",
    "id": ["site", "lib/component_model.dart"],
    "params": [
      {"name": "a", "isNamed": false, "decoder": "p.get('a')", "encoder": "c.a", "imports": []},
      {
        "name": "b",
        "isNamed": true,
        "decoder": "ModelCodec.fromRaw(p.get('b'))",
        "encoder": "ModelCodec(c.b).toRaw()",
        "imports": ["package:site/model.dart"]
      },
    ]
  }),
};

final clientModelExtensionDartOutputs = {
  'site|web/component_model.client.dart': '// GENERATED FILE, DO NOT MODIFY\n'
      '// Generated with jaspr_builder\n'
      '\n'
      'import \'package:jaspr/browser.dart\';\n'
      'import \'package:site/component_model.dart\' as a;\n'
      'import \'package:site/model.dart\';\n'
      '\n'
      'void main() {\n'
      '  runAppWithParams(getComponentForParams);\n'
      '}\n'
      '\n'
      'Component getComponentForParams(ConfigParams p) {\n'
      '  return a.Component(p.get(\'a\'), b: ModelCodec.fromRaw(p.get(\'b\')));\n'
      '}\n',
};
