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

final clientBasicJsonOutputs = {
  'site|lib/component_basic.client.json': jsonEncode({
    "name": "Component",
    "id": ["site", "lib/component_basic.dart"],
    "import": "package:site/component_basic.dart",
    "params": [
      {"name": "a", "isNamed": false, "decoder": "p.get<String>('a')", "encoder": "c.a"},
      {"name": "b", "isNamed": true, "decoder": "p.get<int>('b')", "encoder": "c.b"},
      {"name": "c", "isNamed": true, "decoder": "p.get<double?>('c')", "encoder": "c.c"},
      {"name": "d", "isNamed": true, "decoder": "p.get<bool>('d')", "encoder": "c.d"},
    ],
  }),
};

final clientBasicDartOutputs = {
  'site|lib/component_basic.client.dart':
      '// dart format off\n'
      '// ignore_for_file: type=lint\n'
      '\n'
      '// GENERATED FILE, DO NOT MODIFY\n'
      '// Generated with jaspr_builder\n'
      '\n'
      'import \'package:jaspr/browser.dart\';\n'
      'import \'package:site/component_basic.dart\' as prefix0;\n'
      '\n'
      'Component getComponentForParams(ClientParams p) {\n'
      '  return prefix0.Component(\n'
      '    p.get<String>(\'a\'),\n'
      '    b: p.get<int>(\'b\'),\n'
      '    c: p.get<double?>(\'c\'),\n'
      '    d: p.get<bool>(\'d\'),\n'
      '  );\n'
      '}\n'
      '',
};
