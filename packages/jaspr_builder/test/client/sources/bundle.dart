import 'dart:convert';

final clientBundleOutputs = {
  'site|lib/clients.bundle.json': jsonEncode([
    {
      "name": "Component",
      "id": ["site", "lib/component_basic.dart"],
      "import": "package:site/component_basic.dart",
      "params": [
        {"name": "a", "isNamed": false, "decoder": "p['a']", "encoder": "c.a"},
        {"name": "b", "isNamed": true, "decoder": "p['b']", "encoder": "c.b"},
        {"name": "c", "isNamed": true, "decoder": "p['c']", "encoder": "c.c"},
        {"name": "d", "isNamed": true, "decoder": "p['d']", "encoder": "c.d"},
      ],
    },
    {
      "name": "Component",
      "id": ["site", "lib/component_model_class.dart"],
      "import": "package:site/component_model_class.dart",
      "params": [
        {"name": "a", "isNamed": false, "decoder": "p['a']", "encoder": "c.a"},
        {
          "name": "b",
          "isNamed": true,
          "decoder": "[[package:site/model_class.dart]].ModelA.fromRaw(p['b'])",
          "encoder": "c.b.toRaw()",
        },
      ],
    },
    {
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
      ],
    },
  ]),
};
