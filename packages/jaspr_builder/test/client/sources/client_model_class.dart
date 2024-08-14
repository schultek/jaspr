import 'dart:convert';

import '../../codec/sources/model_class.dart';
import 'client_model.dart';

final clientModelClassSources = {
  ...clientModelSources,
  ...modelClassSources,
  ...modelClassOutputs,
};

final clientModelClassJsonOutputs = {
  'site|lib/component_model.client.json': jsonEncode({
    "name": "Component",
    "id": ["site", "lib/component_model.dart"],
    "params": [
      {"name": "a", "isNamed": false, "decoder": "p.get(\'a\')", "encoder": "c.a", "imports": []},
      {
        "name": "b",
        "isNamed": true,
        "decoder": "Model.fromRaw(p.get(\'b\'))",
        "encoder": "c.b.toRaw()",
        "imports": ["package:site/model.dart"]
      },
    ]
  }),
};

final clientModelClassDartOutputs = {
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
      '  return a.Component(p.get(\'a\'), b: Model.fromRaw(p.get(\'b\')));\n'
      '}\n',
};
