import '../../client/sources/bundle.dart';

final clientOptionsOtherSources = {
  ...clientBundleOutputs,
  'site|lib/other.client.dart': '''
    void main() {}
  ''',
  'site|pubspec.yaml': '''
    jaspr:
      mode: static
  ''',
};

final clientOptionsOtherOutputs = {
  'site|lib/other.client.g.dart':
      '// dart format off\n'
      '// ignore_for_file: type=lint\n'
      '\n'
      '// GENERATED FILE, DO NOT MODIFY\n'
      '// Generated with jaspr_builder\n'
      '\n'
      'import \'package:jaspr/client.dart\';\n'
      'import \'package:site/component_basic.dart\' deferred as \$component_basic;\n'
      'import \'package:site/component_model_class.dart\'\n'
      '    deferred as \$component_model_class;\n'
      'import \'package:site/component_model_extension.dart\'\n'
      '    deferred as \$component_model_extension;\n'
      'import \'package:site/model_class.dart\' deferred as \$model_class;\n'
      'import \'package:site/model_extension.dart\' deferred as \$model_extension;\n'
      '\n'
      '/// Default [ClientOptions] for use with your Jaspr project.\n'
      '///\n'
      '/// Pass this to [ClientApp].\n'
      '///\n'
      '/// Example:\n'
      '/// ```dart\n'
      '/// import \'other.client.g.dart\';\n'
      '///\n'
      '/// void main() {\n'
      '///   runApp(ClientApp(\n'
      '///     options: defaultClientOptions,\n'
      '///   ));\n'
      '/// }\n'
      '/// ```\n'
      'ClientOptions get defaultClientOptions => ClientOptions(\n'
      '  clients: {\n'
      '    \'component_basic\': ClientLoader(\n'
      '      (p) =>\n'
      '          \$component_basic.Component(p[\'a\'], b: p[\'b\'], c: p[\'c\'], d: p[\'d\']),\n'
      '      loader: \$component_basic.loadLibrary,\n'
      '    ),\n'
      '    \'component_model_class\': ClientLoader(\n'
      '      (p) => \$component_model_class.Component(\n'
      '        p[\'a\'],\n'
      '        b: \$model_class.ModelA.fromRaw(p[\'b\']),\n'
      '      ),\n'
      '      loader: \$component_model_class.loadLibrary,\n'
      '    ),\n'
      '    \'component_model_extension\': ClientLoader(\n'
      '      (p) => \$component_model_extension.Component(\n'
      '        p[\'a\'],\n'
      '        b: \$model_extension.ModelBCodec.fromRaw(p[\'b\']),\n'
      '      ),\n'
      '      loader: \$component_model_extension.loadLibrary,\n'
      '    ),\n'
      '  },\n'
      ');\n'
      '',
};
