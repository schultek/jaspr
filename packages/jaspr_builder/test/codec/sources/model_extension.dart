import 'dart:convert';

const modelExtensionSources = {
  'site|lib/model_type.dart': '''
    import 'package:jaspr/jaspr.dart';
        
    class Model {
      Model(this.a, {this.b = 18, this.c, required this.d});
      
      final String a;
      final int b;
      final double? c;
      final bool d;
    }
  ''',
  'site|lib/model_extension.dart': '''
    import 'package:jaspr/jaspr.dart';
    import 'model_type.dart';
        
    extension type ModelCodec._(Model model) implements Model {  
      @decoder
      factory ModelCodec.fromRaw(Map<String, dynamic> raw) {
        return ModelCodec._(Model(model['a'], b: model['b'], c: model['c'], d: model['d']));
      }
      
      @encoder
      Map<String, dynamic> toRaw() {
        return {'a': a, 'b': b, 'c': c, 'd': d};
      }
    }
  ''',
};

final modelExtensionOutputs = {
  'site|lib/model_extension.codec.json': jsonEncode({
    "id": ["site", "lib/model_extension.dart"],
    "elements": [
      {
        "name": "Model",
        "extension": "ModelCodec",
        "decoder": "fromRaw",
        "encoder": "toRaw",
        "import": "package:site/model_extension.dart",
        "typeImport": "package:site/model_type.dart",
      }
    ]
  }),
};
