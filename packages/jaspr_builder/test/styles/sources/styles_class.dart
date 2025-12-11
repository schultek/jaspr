import 'dart:convert';

const stylesClassSources = {
  'site|lib/styles_class.dart': '''
    import 'package:jaspr/dom.dart';
        
    class Component {
      @css
      static final styles = [
        css('.main').styles(width: 100.px),
      ];
      
      @css
      static List<StyleRule> get styles2 => [
        css('.main', [
          css('&').styles(width: 100.px),
        ]),
      ];
    }
  ''',
};

final stylesClassOutputs = {
  'site|lib/styles_class.styles.json': jsonEncode({
    'elements': ['Component.styles', 'Component.styles2'],
    'id': ['site', 'lib/styles_class.dart'],
  }),
};
