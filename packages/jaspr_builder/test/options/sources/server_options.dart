import '../../client/sources/bundle.dart';
import '../../styles/sources/bundle.dart';

final serverOptionsSources = {
  ...clientBundleOutputs,
  ...stylesBundleOutputs,
  'site|lib/main.client.dart': '''
    void main() {}
  ''',
  'site|lib/main.server.dart': '''
    import 'package:site/component_basic.dart';
    // import 'package:site/component_model_class.dart';
    import 'package:site/component_model_extension.dart';

    void main() {}
  ''',
  'site|pubspec.yaml': '''
    jaspr:
      mode: static
  ''',
};

final serverOptionsOutputs = {
  'site|lib/main.server.options.dart':
      '// dart format off\n'
      '// ignore_for_file: type=lint\n'
      '\n'
      '// GENERATED FILE, DO NOT MODIFY\n'
      '// Generated with jaspr_builder\n'
      '\n'
      'import \'package:jaspr/server.dart\';\n'
      'import \'package:site/component_basic.dart\' as _component_basic;\n'
      'import \'package:site/component_model_extension.dart\'\n'
      '    as _component_model_extension;\n'
      'import \'package:site/model_extension.dart\' as _model_extension;\n'
      'import \'package:site/styles_global.dart\' as _styles_global;\n'
      '\n'
      '/// Default [ServerOptions] for use with your Jaspr project.\n'
      '///\n'
      '/// Use this to initialize Jaspr **before** calling [runApp].\n'
      '///\n'
      '/// Example:\n'
      '/// ```dart\n'
      '/// import \'main.server.options.dart\';\n'
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
      '  clientId: \'main.client.dart.js\',\n'
      '  clients: {\n'
      '    _component_basic.Component: ClientTarget<_component_basic.Component>(\n'
      '      \'component_basic\',\n'
      '      params: __component_basicComponent,\n'
      '    ),\n'
      '    _component_model_extension.Component:\n'
      '        ClientTarget<_component_model_extension.Component>(\n'
      '          \'component_model_extension\',\n'
      '          params: __component_model_extensionComponent,\n'
      '        ),\n'
      '  },\n'
      '  styles: () => [..._styles_global.styles, ..._styles_global.styles2],\n'
      ');\n'
      '\n'
      'Map<String, Object?> __component_basicComponent(_component_basic.Component c) =>\n'
      '    {\'a\': c.a, \'b\': c.b, \'c\': c.c, \'d\': c.d};\n'
      'Map<String, Object?> __component_model_extensionComponent(\n'
      '  _component_model_extension.Component c,\n'
      ') => {\'a\': c.a, \'b\': _model_extension.ModelBCodec(c.b).toRaw()};\n'
      '',
};
