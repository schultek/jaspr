import '../../client/sources/client_basic.dart';
import '../../client/sources/client_model_class.dart';
import '../../styles/sources/styles_class.dart';
import '../../styles/sources/styles_global.dart';

final optionsSources = {
  ...clientBasicJsonOutputs,
  ...clientModelClassJsonOutputs,
  ...stylesGlobalOutputs,
  ...stylesClassOutputs,
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
      'import \'component_basic.dart\' as prefix0;\n'
      'import \'component_model.dart\' as prefix1;\n'
      'import \'styles.dart\' as prefix2;\n'
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
      '    prefix1.Component: ClientTarget<prefix1.Component>(\'component_model\', params: _prefix1Component),\n'
      '  },\n'
      '  styles: () => [\n'
      '    ...prefix2.Component.styles,\n'
      '    ...prefix2.Component.styles2,\n'
      '  ],\n'
      ');\n'
      '\n'
      'Map<String, dynamic> _prefix0Component(prefix0.Component c) => {\'a\': c.a, \'b\': c.b, \'c\': c.c, \'d\': c.d};\n'
      'Map<String, dynamic> _prefix1Component(prefix1.Component c) => {\'a\': c.a, \'b\': c.b.toRaw()};\n'
      '',
};
