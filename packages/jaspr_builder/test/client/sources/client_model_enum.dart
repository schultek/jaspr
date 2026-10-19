import 'dart:convert';

import '../../codec/sources/bundle.dart';
import '../../codec/sources/model_enum.dart';

final clientModelEnumSources = {
  'site|lib/component_model_enum.dart': '''
    import 'package:jaspr/jaspr.dart';
    import 'model_enum.dart';

    @client
    class Component extends StatelessComponent {
      Component({required this.c, this.d, super.key});

      final ModelC c;
      final ModelC? d;

      @override
      Component build(BuildContext context) => text('');
    }
  ''',
  ...modelEnumSources,
  ...codecBundleOutputs,
};

final clientModelEnumModuleData = {
  'name': 'Component',
  'id': ['site', 'lib/component_model_enum.dart'],
  'import': 'package:site/component_model_enum.dart',
  'params': [
    {
      'name': 'c',
      'isNamed': true,
      'decoder': "[[package:site/model_enum.dart]].ModelC.fromRaw(p.get<String>('c'))",
      'encoder': 'c.c.toRaw()',
    },
    {
      'name': 'd',
      'isNamed': true,
      'decoder':
          "switch (p.get<String?>('d')) { final v? => [[package:site/model_enum.dart]].ModelC.fromRaw(v), _ => null }",
      'encoder': 'c.d?.toRaw()',
    },
  ],
};

final clientModelEnumModuleOutputs = {
  'site|lib/component_model_enum.client.module.json': jsonEncode(clientModelEnumModuleData),
};
