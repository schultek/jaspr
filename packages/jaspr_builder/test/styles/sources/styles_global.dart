import 'dart:convert';

const stylesGlobalSources = {
  'site|lib/styles_global.dart': '''
    import 'package:jaspr/dom.dart';
        
    @css
    final styles = [
      css('.main').styles(width: 100.px),
    ];
    
    @css
    List<StyleRule> get styles2 => [
      css('.main', [
        css('&').styles(width: 100.px),
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
