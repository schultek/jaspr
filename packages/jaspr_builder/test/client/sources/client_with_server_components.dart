import 'dart:convert';

const clientWithServerComponentsSources = {
  'site|lib/client_with_sc.dart': '''
    import 'package:jaspr/jaspr.dart';
    
    @client
    class ClientWithSC extends StatelessComponent {
      ClientWithSC({required this.child, this.children = const [], required this.childrenMap = const {}, super.key});
      
      final Component child;
      final List<Component> children;
      final Map<String, Component> childrenMap;
    
      @override
      Component build(BuildContext context) => text('');
    }
  ''',
};

final clientWithServerComponentsJsonOutputs = {
  'site|lib/client_with_sc.client.json': jsonEncode({
    "name": "ClientWithSC",
    "id": ["site", "lib/client_with_sc.dart"],
    "import": "package:site/client_with_sc.dart",
    "params": [
      {"name": "child", "isNamed": true, "decoder": "p.mount(p.get<String>('child'))", "encoder": "c.child"},
      {
        "name": "children",
        "isNamed": true,
        "decoder": "p.get<List<dynamic>>('children').cast<String>().map((i) => p.mount(i)).toList()",
        "encoder": "c.children",
      },
      {
        "name": "childrenMap",
        "isNamed": true,
        "decoder": "p.get<Map<String, dynamic>>('childrenMap').cast<String, String>().map((k, v) => MapEntry(k, p.mount(v)))",
        "encoder": "c.childrenMap",
      },
    ],
  }),
};

final clientWithServerComponentsDartOutputs = {
  'site|lib/client_with_sc.client.dart':
      '// dart format off\n'
      '// ignore_for_file: type=lint\n'
      '\n'
      '// GENERATED FILE, DO NOT MODIFY\n'
      '// Generated with jaspr_builder\n'
      '\n'
      'import \'package:jaspr/browser.dart\';\n'
      'import \'package:site/client_with_sc.dart\' as prefix0;\n'
      '\n'
      'Component getComponentForParams(ClientParams p) {\n'
      '  return prefix0.ClientWithSC(\n'
      '    child: p.mount(p.get<String>(\'child\')),\n'
      '    children: p.get<List<dynamic>>(\'children\').cast<String>().map((i) => p.mount(i)).toList(),\n'
      '    childrenMap:\n'
      '        p.get<Map<String, dynamic>>(\'childrenMap\').cast<String, String>().map((k, v) => MapEntry(k, p.mount(v))),\n'
      '  );\n'
      '}\n'
      '',
};
