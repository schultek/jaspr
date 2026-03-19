import 'dart:convert';

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

final stylesStandaloneServerOutputs = {
  'site|lib/main.server.css.json': jsonEncode({
    'mode': 'server',
    'styles': [
      {
        'elements': ['Component.styles', 'Component.styles2'],
        'id': ['site', 'lib/styles_class.dart'],
      },
      {
        'elements': ['styles', 'styles2'],
        'id': ['site', 'lib/styles_global.dart'],
      },
    ],
  }),
  'site|web/main.css':
      '.main {\n'
      '  width: 100px;\n'
      '}\n'
      '.main {\n'
      '  height: 100px;\n'
      '}\n'
      'body {\n'
      '  width: 100vw;\n'
      '}\n'
      'body {\n'
      '  height: 100vh;\n'
      '}',
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

final stylesStandaloneClientOutputs = {
  'site|lib/main.client.css.json': jsonEncode({
    'mode': 'client',
    'styles': [
      {
        'elements': ['Component.styles', 'Component.styles2'],
        'id': ['site', 'lib/styles_class.dart'],
      },
      {
        'elements': ['styles', 'styles2'],
        'id': ['site', 'lib/styles_global.dart'],
      },
    ],
  }),
  'site|web/main.css':
      '.main {\n'
      '  width: 100px;\n'
      '}\n'
      '.main {\n'
      '  height: 100px;\n'
      '}\n'
      'body {\n'
      '  width: 100vw;\n'
      '}\n'
      'body {\n'
      '  height: 100vh;\n'
      '}',
};
