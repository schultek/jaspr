import 'dart:convert';

const modelClassSources = {
  'site|lib/model_class.dart': '''
    import 'package:jaspr/jaspr.dart';
        
    class ModelA {
      ModelA(this.a, {this.b = 18, this.c, required this.d});
      
      final String a;
      final int b;
      final double? c;
      final bool d;
      
      @decoder
      factory ModelA.fromRaw(Map<String, dynamic> model) {
        return ModelA(model['a'], b: model['b'], c: model['c'], d: model['d']);
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
    'elements': [
      {
        'name': 'ModelA',
        'decoder': 'fromRaw',
        'encoder': 'toRaw',
        'rawType': 'Map<String, dynamic>',
        'import': 'package:site/model_class.dart',
      },
    ],
  }),
};
