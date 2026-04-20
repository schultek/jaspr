import 'dart:convert';

const stylesGlobalSources = {
  'site|lib/globals.dart': '''
    import 'package:jaspr/dom.dart';
    import 'colors/theme.dart';
        
    @css
    final styles = [
      css('body').styles(width: 100.vw),
    ];
    
    @css
    List<StyleRule> get styles2 => [
      css('body', [
        css('&').styles(height: 100.vh),
      ]),
    ];
  ''',
  'site|lib/colors/theme.dart': '''
    import 'package:jaspr/dom.dart';
        
    @css
    final colors = [
      css(':root').styles(color: Colors.red),
    ];
  ''',
};

final stylesGlobalOutputs = {
  'site|lib/globals.styles.json': jsonEncode({
    'elements': ['styles', 'styles2'],
    'id': ['site', 'lib/globals.dart'],
  }),
  'site|lib/colors/theme.styles.json': jsonEncode({
    'elements': ['colors'],
    'id': ['site', 'lib/colors/theme.dart'],
  }),
};
