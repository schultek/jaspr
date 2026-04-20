import 'dart:convert';

const stylesClassSources = {
  'site|lib/main.dart': '''
    import 'package:jaspr/dom.dart';
    import 'components/button.dart';
        
    class Main {
      @css
      static final styles = [
        css('.main').styles(width: 100.px),
      ];
      
      @css
      static List<StyleRule> get styles2 => [
        css('.main', [
          css('&').styles(height: 100.px),
        ]),
      ];
    }
  ''',
  'site|lib/components/button.dart': '''
    import 'package:jaspr/dom.dart';
        
    class Button {
      @css
      static final styles = [
        css('button').styles(color: Colors.red),
      ];
    }
  ''',
};

final stylesClassOutputs = {
  'site|lib/main.styles.json': jsonEncode({
    'elements': ['Main.styles', 'Main.styles2'],
    'id': ['site', 'lib/main.dart'],
  }),
  'site|lib/components/button.styles.json': jsonEncode({
    'elements': ['Button.styles'],
    'id': ['site', 'lib/components/button.dart'],
  }),
};
