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
  'site|lib/jaspr_options.dart': '// dart format off\n'
      '// ignore_for_file: type=lint\n'
      '\n'
      '// GENERATED FILE, DO NOT MODIFY\n'
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
      '    prefix0.Component: ClientTarget<prefix0.Component>(\n'
      '      \'component_basic\',\n'
      '      params: _prefix0Component,\n'
      '    ),\n'
      '\n'
      '    prefix1.Component: ClientTarget<prefix1.Component>(\n'
      '      \'component_model_class\',\n'
      '      params: _prefix1Component,\n'
      '    ),\n'
      '\n'
      '    prefix2.Component: ClientTarget<prefix2.Component>(\n'
      '      \'component_model_extension\',\n'
      '      params: _prefix2Component,\n'
      '    ),\n'
      '  },\n'
      '  styles: () => [...prefix4.styles, ...prefix4.styles2],\n'
      ');\n'
      '\n'
      'Map<String, dynamic> _prefix0Component(prefix0.Component c) => {\n'
      '  \'a\': c.a,\n'
      '  \'b\': c.b,\n'
      '  \'c\': c.c,\n'
      '  \'d\': c.d,\n'
      '};\n'
      'Map<String, dynamic> _prefix1Component(prefix1.Component c) => {\n'
      '  \'a\': c.a,\n'
      '  \'b\': c.b.toRaw(),\n'
      '};\n'
      'Map<String, dynamic> _prefix2Component(prefix2.Component c) => {\n'
      '  \'a\': c.a,\n'
      '  \'b\': prefix3.ModelBCodec(c.b).toRaw(),\n'
      '};\n'
      '',
};
