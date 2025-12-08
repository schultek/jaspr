import '../../client/sources/bundle.dart';
import '../../styles/sources/bundle.dart';

final serverOptionsOtherSources = {
  ...clientBundleOutputs,
  ...stylesBundleOutputs,
  'site|lib/other.server.dart': '''
    import 'package:site/component_basic.dart';
    import 'package:site/component_model_class.dart';

    void main() {}
  ''',
  'site|pubspec.yaml': '''
    jaspr:
      mode: static
  ''',
};

final serverOptionsOtherOutputs = {
  'site|lib/other.server.options.dart':
      '// dart format off\n'
      '// ignore_for_file: type=lint\n'
      '\n'
      '// GENERATED FILE, DO NOT MODIFY\n'
      '// Generated with jaspr_builder\n'
      '\n'
      'import \'package:jaspr/server.dart\';\n'
      'import \'package:site/component_basic.dart\' as _component_basic;\n'
      'import \'package:site/component_model_class.dart\' as _component_model_class;\n'
      'import \'package:site/styles_global.dart\' as _styles_global;\n'
      '\n'
      '/// Default [ServerOptions] for use with your Jaspr project.\n'
      '///\n'
      '/// Use this to initialize Jaspr **before** calling [runApp].\n'
      '///\n'
      '/// Example:\n'
      '/// ```dart\n'
      '/// import \'other.server.options.dart\';\n'
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
      '  styles: () => [..._styles_global.styles, ..._styles_global.styles2],\n'
      ');\n'
      '\n'
      'Map<String, Object?> __component_basicComponent(_component_basic.Component c) =>\n'
      '    {\'a\': c.a, \'b\': c.b, \'c\': c.c, \'d\': c.d};\n'
      'Map<String, Object?> __component_model_classComponent(\n'
      '  _component_model_class.Component c,\n'
      ') => {\'a\': c.a, \'b\': c.b.toRaw()};\n'
      '',
};
