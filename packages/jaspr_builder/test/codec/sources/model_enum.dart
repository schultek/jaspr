import 'dart:convert';

const modelEnumSources = {
  'site|lib/model_enum.dart': '''
    import 'package:jaspr/jaspr.dart';

    enum ModelC {
      a,
      b;

      @decoder
      static ModelC fromRaw(String raw) => ModelC.values.byName(raw);

      @encoder
      String toRaw() => name;
    }
  ''',
};

final modelEnumOutputs = {
  'site|lib/model_enum.codec.json': jsonEncode({
    'elements': [
      {
        'name': 'ModelC',
        'decoder': 'fromRaw',
        'encoder': 'toRaw',
        'rawType': 'String',
        'import': 'package:site/model_enum.dart',
      },
    ],
  }),
};
