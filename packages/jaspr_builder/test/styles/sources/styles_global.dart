import 'dart:convert';

const stylesGlobalSources = {
  'site|lib/styles_global.dart': '''
    import 'package:jaspr/dom.dart';
        
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
};

final stylesGlobalOutputs = {
  'site|lib/styles_global.styles.json': jsonEncode({
    'elements': ['styles', 'styles2'],
    'id': ['site', 'lib/styles_global.dart'],
  }),
};
