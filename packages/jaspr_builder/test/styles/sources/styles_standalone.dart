const stylesStandaloneServerSources = {
  'site|lib/main.server.dart': '''
    import 'main.dart';
    import 'globals.dart';
    
    void main() {}
  ''',
  'site|lib/main.client.dart': '''
    import 'main.dart';
    import 'globals.dart';
    
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
      'import \'package:site/colors/theme.dart\' as _theme;\n'
      'import \'package:site/components/button.dart\' as _button;\n'
      'import \'package:site/globals.dart\' as _globals;\n'
      'import \'package:site/main.dart\' as _main;\n'
      '\n'
      'void main() {\n'
      '  final List<StyleRule> styles = [\n'
      '    ..._globals.styles,\n'
      '    ..._globals.styles2,\n'
      '    ..._theme.colors,\n'
      '    ..._main.Main.styles,\n'
      '    ..._main.Main.styles2,\n'
      '    ..._button.Button.styles,\n'
      '  ];\n'
      '\n'
      '  stdout.write(jsonEncode({\'css\': styles.render()}));\n'
      '}\n',
};

const stylesStandaloneClientSources = {
  'site|lib/main.client.dart': '''
    import 'main.dart';
    import 'globals.dart';
    
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
      'import \'package:site/colors/theme.dart\' as _theme;\n'
      'import \'package:site/components/button.dart\' as _button;\n'
      'import \'package:site/globals.dart\' as _globals;\n'
      'import \'package:site/main.dart\' as _main;\n'
      '\n'
      'void main() {\n'
      '  final List<StyleRule> styles = [\n'
      '    ..._globals.styles,\n'
      '    ..._globals.styles2,\n'
      '    ..._theme.colors,\n'
      '    ..._main.Main.styles,\n'
      '    ..._main.Main.styles2,\n'
      '    ..._button.Button.styles,\n'
      '  ];\n'
      '\n'
      '  stdout.write(jsonEncode({\'css\': styles.render()}));\n'
      '}\n',
};
