import '../../client/sources/bundle.dart';
import '../../styles/sources/bundle.dart';

final serverOptionsStandaloneSources = {
  ...clientBundleOutputs,
  ...stylesBundleOutputs,
  'site|lib/entry.server.dart': '''
    import 'package:site/component_basic.dart';
    import 'package:site/component_model_class.dart';

    void main() {}
  ''',
  'site|pubspec.yaml': '''
    jaspr:
      mode: static
      styles: standalone
  ''',
};

final serverOptionsStandaloneOutputs = {
  'site|lib/entry.server.options.dart':
      '// dart format off\n'
      '// ignore_for_file: type=lint\n'
      '\n'
      '// GENERATED FILE, DO NOT MODIFY\n'
      '// Generated with jaspr_builder\n'
      '\n'
      'import \'package:jaspr/server.dart\';\n'
      'import \'package:site/component_basic.dart\' as _component_basic;\n'
      'import \'package:site/component_model_class.dart\' as _component_model_class;\n'
      '\n'
      '/// Default [ServerOptions] for use with your Jaspr project.\n'
      '///\n'
      '/// Use this to initialize Jaspr **before** calling [runApp].\n'
      '///\n'
      '/// Example:\n'
      '/// ```dart\n'
      '/// import \'entry.server.options.dart\';\n'
      '///\n'
      '/// void main() {\n'
      '///   Jaspr.initializeApp(\n'
      '///     options: defaultServerOptions,\n'
      '///   );\n'
      '///\n'
      '///   runApp(...);\n'
      '/// }\n'
      '/// ```\n'
      'ServerOptions get defaultServerOptions => ServerOptions(\n'
      '  clients: {\n'
      '    _component_basic.Component: ClientTarget<_component_basic.Component>(\n'
      '      \'component_basic\',\n'
      '      params: __component_basicComponent,\n'
      '    ),\n'
      '    _component_model_class.Component:\n'
      '        ClientTarget<_component_model_class.Component>(\n'
      '          \'component_model_class\',\n'
      '          params: __component_model_classComponent,\n'
      '        ),\n'
      '  },\n'
      '  stylesId: \'entry.css\',\n'
      ');\n'
      '\n'
      'Map<String, Object?> __component_basicComponent(_component_basic.Component c) =>\n'
      '    {\'a\': c.a, \'b\': c.b, \'c\': c.c, \'d\': c.d};\n'
      'Map<String, Object?> __component_model_classComponent(\n'
      '  _component_model_class.Component c,\n'
      ') => {\'a\': c.a, \'b\': c.b.toRaw()};\n'
      '',
};
