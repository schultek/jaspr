import '../../client/sources/client_basic.dart';
import '../../client/sources/client_model_class.dart';
import '../../client/sources/client_model_extension.dart';
import '../../styles/sources/bundle.dart';

final optionsSources = {
  ...clientBasicJsonOutputs,
  ...clientModelClassJsonOutputs,
  ...clientModelExtensionJsonOutputs,
  ...stylesBundleOutputs,
  'site|pubspec.yaml': '''
    jaspr:
      mode: static
  ''',
};

final optionsOutputs = {
  'site|lib/jaspr_options.dart': '// GENERATED FILE, DO NOT MODIFY\n'
      '// Generated with jaspr_builder\n'
      '\n'
      'import \'package:jaspr/jaspr.dart\';\n'
      'import \'package:site/component_basic.dart\' as prefix0;\n'
      'import \'package:site/component_model_class.dart\' as prefix1;\n'
      'import \'package:site/component_model_extension.dart\' as prefix2;\n'
      'import \'package:site/model_extension.dart\' as prefix3;\n'
      'import \'package:site/styles_global.dart\' as prefix4;\n'
      '\n'
      '/// Default [JasprOptions] for use with your jaspr project.\n'
      '///\n'
      '/// Use this to initialize jaspr **before** calling [runApp].\n'
      '///\n'
      '/// Example:\n'
      '/// ```dart\n'
      '/// import \'jaspr_options.dart\';\n'
      '///\n'
      '/// void main() {\n'
      '///   Jaspr.initializeApp(\n'
      '///     options: defaultJasprOptions,\n'
      '///   );\n'
      '///\n'
      '///   runApp(...);\n'
      '/// }\n'
      '/// ```\n'
      'final defaultJasprOptions = JasprOptions(\n'
      '  clients: {\n'
      '    prefix0.Component: ClientTarget<prefix0.Component>(\'component_basic\', params: _prefix0Component),\n'
      '    prefix1.Component: ClientTarget<prefix1.Component>(\'component_model_class\', params: _prefix1Component),\n'
      '    prefix2.Component: ClientTarget<prefix2.Component>(\'component_model_extension\', params: _prefix2Component),\n'
      '  },\n'
      '  styles: () => [\n'
      '    ...prefix4.styles,\n'
      '    ...prefix4.styles2,\n'
      '  ],\n'
      ');\n'
      '\n'
      'Map<String, dynamic> _prefix0Component(prefix0.Component c) => {\'a\': c.a, \'b\': c.b, \'c\': c.c, \'d\': c.d};\n'
      'Map<String, dynamic> _prefix1Component(prefix1.Component c) => {\'a\': c.a, \'b\': c.b.toRaw()};\n'
      'Map<String, dynamic> _prefix2Component(prefix2.Component c) => {\'a\': c.a, \'b\': prefix3.ModelBCodec(c.b).toRaw()};\n'
      '',
};
