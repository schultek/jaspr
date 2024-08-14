import 'dart:convert';

const stylesGlobalSources = {
  'site|lib/styles.dart': '''
    import 'package:jaspr/jaspr.dart';
        
    @css
    final styles = [
      css('.main').box(width: 100.px),
    ];
    
    @css
    List<StyleRule> get styles2 => [
      css('.main', [
        css('&').box(width: 100.px),
      ]),
    ];
  ''',
};

final stylesGlobalOutputs = {
  'site|lib/styles.styles.json': jsonEncode({
    "elements": ["styles", "styles2"],
    "id": ["site", "lib/styles.dart"]
  }),
};
