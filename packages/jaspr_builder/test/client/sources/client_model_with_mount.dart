import 'dart:convert';

import '../../codec/sources/model_with_mount.dart';

final clientModelWithMountBundleOutputs = {
  'site|lib/codec.bundle.json': jsonEncode([
    {
      'name': 'ModelWithMountPositional',
      'decoder': 'fromRaw',
      'encoder': 'toRaw',
      'rawType': 'Map<String, dynamic>',
      'import': 'package:site/model_with_mount.dart',
      'hasMount': true,
    },
    {
      'name': 'ModelWithMountNamed',
      'decoder': 'fromRaw',
      'encoder': 'toRaw',
      'rawType': 'Map<String, dynamic>',
      'import': 'package:site/model_with_mount.dart',
      'hasMount': true,
      'mountParam': 'mount',
    },
  ]),
};

final clientModelWithMountSources = {
  'site|lib/component_model_with_mount.dart': '''
    import 'package:jaspr/jaspr.dart';
    import 'model_with_mount.dart';
    
    @client
    class ComponentWithMount extends StatelessComponent {
      ComponentWithMount(this.a, {required this.b, this.c, this.d = const [], this.e = const {}, super.key});
      
      final ModelWithMountPositional a;
      final ModelWithMountNamed b;
      final ModelWithMountPositional? c;
      final List<ModelWithMountPositional> d;
      final Map<String, ModelWithMountNamed> e;
    
      @override
      Component build(BuildContext context) => text('');
    }
  ''',
  ...modelWithMountSources,
  ...clientModelWithMountBundleOutputs,
};

final clientModelWithMountModuleData = {
  'name': 'ComponentWithMount',
  'id': ['site', 'lib/component_model_with_mount.dart'],
  'import': 'package:site/component_model_with_mount.dart',
  'params': [
    {
      'name': 'a',
      'isNamed': false,
      'decoder': "[[package:site/model_with_mount.dart]].ModelWithMountPositional.fromRaw(p.get<Map<String, dynamic>>('a'), p.mount)",
      'encoder': 'c.a.toRaw()',
    },
    {
      'name': 'b',
      'isNamed': true,
      'decoder': "[[package:site/model_with_mount.dart]].ModelWithMountNamed.fromRaw(p.get<Map<String, dynamic>>('b'), mount: p.mount)",
      'encoder': 'c.b.toRaw()',
    },
    {
      'name': 'c',
      'isNamed': true,
      'decoder': "switch (p.get<Map<String, dynamic>?>('c')) { final v? => [[package:site/model_with_mount.dart]].ModelWithMountPositional.fromRaw(v, p.mount), _ => null }",
      'encoder': 'c.c?.toRaw()',
    },
    {
      'name': 'd',
      'isNamed': true,
      'decoder': "p.get<List<Object?>>('d').cast<Map<String, dynamic>>().map((i) => [[package:site/model_with_mount.dart]].ModelWithMountPositional.fromRaw(i, p.mount)).toList()",
      'encoder': 'c.d.map((i) => i.toRaw()).toList()',
    },
    {
      'name': 'e',
      'isNamed': true,
      'decoder': "p.get<Map<String, Object?>>('e').cast<String, Map<String, dynamic>>().map((k, v) => MapEntry(k, [[package:site/model_with_mount.dart]].ModelWithMountNamed.fromRaw(v, mount: p.mount)))",
      'encoder': 'c.e.map((k, v) => MapEntry(k, v.toRaw()))',
    },
  ],
};

final clientModelWithMountModuleOutputs = {
  'site|lib/component_model_with_mount.client.module.json': jsonEncode(clientModelWithMountModuleData),
};
