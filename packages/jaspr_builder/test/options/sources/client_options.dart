import '../../client/sources/bundle.dart';

final clientOptionsSources = {
  ...clientBundleOutputs,
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

final clientOptionsOutputs = {
  'site|lib/main.client.options.dart':
      '// dart format off\n'
      '// ignore_for_file: type=lint\n'
      '\n'
      '// GENERATED FILE, DO NOT MODIFY\n'
      '// Generated with jaspr_builder\n'
      '\n'
      'import \'package:jaspr/client.dart\';\n'
      '\n'
      'import \'package:site/component_basic.dart\' deferred as _component_basic;\n'
      'import \'package:site/component_model_extension.dart\'\n'
      '    deferred as _component_model_extension;\n'
      'import \'package:site/model_extension.dart\' as _model_extension;\n'
      '\n'
      '/// Default [ClientOptions] for use with your Jaspr project.\n'
      '///\n'
      '/// Use this to initialize Jaspr **before** calling [runApp].\n'
      '///\n'
      '/// Example:\n'
      '/// ```dart\n'
      '/// import \'main.client.options.dart\';\n'
      '///\n'
      '/// void main() {\n'
      '///   Jaspr.initializeApp(\n'
      '///     options: defaultClientOptions,\n'
      '///   );\n'
      '///\n'
      '///   runApp(...);\n'
      '/// }\n'
      '/// ```\n'
      'ClientOptions get defaultClientOptions => ClientOptions(\n'
      '  clients: {\n'
      '    \'component_basic\': ClientLoader(\n'
      '      (p) => _component_basic.Component(\n'
      '        p[\'a\'] as String,\n'
      '        b: p[\'b\'] as int,\n'
      '        c: p[\'c\'] as double?,\n'
      '        d: p[\'d\'] as bool,\n'
      '      ),\n'
      '      loader: _component_basic.loadLibrary,\n'
      '    ),\n'
      '    \'component_model_extension\': ClientLoader(\n'
      '      (p) => _component_model_extension.Component(\n'
      '        p[\'a\'] as String,\n'
      '        b: _model_extension.ModelBCodec.fromRaw(p[\'b\'] as Map<String, dynamic>),\n'
      '      ),\n'
      '      loader: _component_model_extension.loadLibrary,\n'
      '    ),\n'
      '  },\n'
      ');\n'
      '',
};
