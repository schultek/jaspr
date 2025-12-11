import 'dart:convert';

final codecBundleOutputs = {
  'site|lib/codec.bundle.json': jsonEncode([
    {
      'name': 'ModelA',
      'decoder': 'fromRaw',
      'encoder': 'toRaw',
      'rawType': 'Map<String, dynamic>',
      'import': 'package:site/model_class.dart',
    },
    {
      'name': 'ModelB',
      'extension': 'ModelBCodec',
      'decoder': 'fromRaw',
      'encoder': 'toRaw',
      'rawType': 'Map<String, dynamic>',
      'import': 'package:site/model_extension.dart',
      'typeImport': 'package:site/model_type.dart',
    },
  ]),
};
