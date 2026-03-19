const stylesStandaloneServerSources = {
  'site|lib/main.server.dart': '''
    import 'styles_class.dart';
    import 'styles_global.dart';
    
    void main() {}
  ''',
  'site|lib/main.client.dart': '''
    import 'styles_class.dart';
    import 'styles_global.dart';
    
    void main() {}
  ''',
  'site|pubspec.yaml': '''
    jaspr:
      mode: server
      styles: standalone
  ''',
};

const stylesStandaloneServerOutputs = {
  'site|lib/main.server.styles.dart':
      '// dart format off\n'
      '// ignore_for_file: type=lint\n'
      '\n'
      '// GENERATED FILE, DO NOT MODIFY\n'
      '// Generated with jaspr_builder\n'
      '\n'
      'import \'dart:io\';\n'
      'import \'dart:convert\';\n'
      '\n'
      'import \'package:jaspr/src/dom/styles/rules.dart\'\n'
      '    show StyleRule, StyleRulesRender;\n'
      'import \'package:site/styles_class.dart\' as _styles_class;\n'
      'import \'package:site/styles_global.dart\' as _styles_global;\n'
      '\n'
      'void main() {\n'
      '  final List<StyleRule> styles = [\n'
      '    ..._styles_class.Component.styles,\n'
      '    ..._styles_class.Component.styles2,\n'
      '    ..._styles_global.styles,\n'
      '    ..._styles_global.styles2,\n'
      '  ];\n'
      '\n'
      '  stdout.write(jsonEncode({\'css\': styles.render()}));\n'
      '}\n',
};

const stylesStandaloneClientSources = {
  'site|lib/main.client.dart': '''
    import 'styles_class.dart';
    import 'styles_global.dart';
    
    void main() {}
  ''',
  'site|pubspec.yaml': '''
    jaspr:
      mode: client
  ''',
};

const stylesStandaloneClientOutputs = {
  'site|lib/main.client.styles.dart':
      '// dart format off\n'
      '// ignore_for_file: type=lint\n'
      '\n'
      '// GENERATED FILE, DO NOT MODIFY\n'
      '// Generated with jaspr_builder\n'
      '\n'
      'import \'dart:io\';\n'
      'import \'dart:convert\';\n'
      '\n'
      'import \'package:jaspr/src/dom/styles/rules.dart\'\n'
      '    show StyleRule, StyleRulesRender;\n'
      'import \'package:site/styles_class.dart\' as _styles_class;\n'
      'import \'package:site/styles_global.dart\' as _styles_global;\n'
      '\n'
      'void main() {\n'
      '  final List<StyleRule> styles = [\n'
      '    ..._styles_class.Component.styles,\n'
      '    ..._styles_class.Component.styles2,\n'
      '    ..._styles_global.styles,\n'
      '    ..._styles_global.styles2,\n'
      '  ];\n'
      '\n'
      '  stdout.write(jsonEncode({\'css\': styles.render()}));\n'
      '}\n',
};
