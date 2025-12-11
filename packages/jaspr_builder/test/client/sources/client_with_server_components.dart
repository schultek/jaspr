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

final clientWithServerComponentsModuleData = {
  'name': 'ClientWithSC',
  'id': ['site', 'lib/client_with_sc.dart'],
  'import': 'package:site/client_with_sc.dart',
  'params': [
    {'name': 'child', 'isNamed': true, 'decoder': "p.mount(p.get<String>('child'))", 'encoder': 'c.child'},
    {
      'name': 'children',
      'isNamed': true,
      'decoder': "p.get<List<Object?>>('children').cast<String>().map((i) => p.mount(i)).toList()",
      'encoder': 'c.children',
    },
    {
      'name': 'childrenMap',
      'isNamed': true,
      'decoder':
          "p.get<Map<String, Object?>>('childrenMap').cast<String, String>().map((k, v) => MapEntry(k, p.mount(v)))",
      'encoder': 'c.childrenMap',
    },
  ],
};

final clientWithServerComponentsModuleOutputs = {
  'site|lib/client_with_sc.client.module.json': jsonEncode(clientWithServerComponentsModuleData),
};
