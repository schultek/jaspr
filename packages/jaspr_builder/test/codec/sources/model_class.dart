import 'dart:convert';

const modelClassSources = {
  'site|lib/model_class.dart': '''
    import 'package:jaspr/jaspr.dart';
        
    class Model {
      Model(this.a, {this.b = 18, this.c, required this.d});
      
      final String a;
      final int b;
      final double? c;
      final bool d;
      
      @decoder
      factory Model.fromRaw(Map<String, dynamic> raw) {
        return Model(model['a'], b: model['b'], c: model['c'], d: model['d']);
      }
      
      @encoder
      Map<String, dynamic> toRaw() {
        return {'a': a, 'b': b, 'c': c, 'd': d};
      }
    }
  ''',
};

final modelClassOutputs = {
  'site|lib/model_class.codec.json': jsonEncode({
    "id": ["site", "lib/model_class.dart"],
    "elements": [
      {"name": "Model", "decoder": "fromRaw", "encoder": "toRaw", "import": "package:site/model_class.dart"}
    ]
  }),
};
