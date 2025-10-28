import 'bundle.dart';

final clientRegistrySources = {
  'site|pubspec.yaml': '''
    jaspr:
      mode: static
  ''',
  'site|lib/main.dart': '''
    import 'package:site/component_basic.dart';
    import 'package:site/component_model_class.dart';

    void main() {}
  ''',
  ...clientBundleOutputs,
};

final clientRegistryOutputs = {
  'site|web/main.clients.dart':
      '// dart format off\n'
      '// ignore_for_file: type=lint\n'
      '\n'
      '// GENERATED FILE, DO NOT MODIFY\n'
      '// Generated with jaspr_builder\n'
      '\n'
      'import \'package:jaspr/browser.dart\';\n'
      'import \'package:site/component_basic.client.dart\' deferred as prefix0;\n'
      'import \'package:site/component_model_class.client.dart\' deferred as prefix1;\n'
      '\n'
      'void main() {\n'
      '  registerClients({\n'
      '    \'component_basic\': loadClient(\n'
      '      prefix0.loadLibrary,\n'
      '      (p) => prefix0.getComponentForParams(p),\n'
      '    ),\n'
      '\n'
      '    \'component_model_class\': loadClient(\n'
      '      prefix1.loadLibrary,\n'
      '      (p) => prefix1.getComponentForParams(p),\n'
      '    ),\n'
      '  });\n'
      '}\n'
      '',
};
