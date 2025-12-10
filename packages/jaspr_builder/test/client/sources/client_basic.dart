import 'dart:convert';

const clientBasicSources = {
  'site|lib/component_basic.dart': '''
    import 'package:jaspr/jaspr.dart';
    
    @client
    class Component extends StatelessComponent {
      Component(this.a, {this.b = 18, this.c, required this.d, super.key});
      
      final String a;
      final int b;
      final double? c;
      final bool d;
    
      @override
      Component build(BuildContext context) => text('');
    }
  ''',
};

final clientBasicModuleOutputs = {
  'site|lib/component_basic.client.module.json': jsonEncode({
    'name': 'Component',
    'id': ['site', 'lib/component_basic.dart'],
    'import': 'package:site/component_basic.dart',
    'params': [
      {'name': 'a', 'isNamed': false, 'decoder': "p['a'] as String", 'encoder': 'c.a'},
      {'name': 'b', 'isNamed': true, 'decoder': "p['b'] as int", 'encoder': 'c.b'},
      {'name': 'c', 'isNamed': true, 'decoder': "p['c'] as double?", 'encoder': 'c.c'},
      {'name': 'd', 'isNamed': true, 'decoder': "p['d'] as bool", 'encoder': 'c.d'},
    ],
  }),
};
