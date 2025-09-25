const clientInvalidConstructorSources = {
  'site|lib/component_basic.dart': '''
    import 'package:jaspr/jaspr.dart';
    
    @client
    class Component extends StatelessComponent {
      Component(String a) : a = a;
      
      final String a;
    
      @override
      Component build(BuildContext context) => text('');
    }
  ''',
};

const clientInvalidParamSources = {
  'site|lib/component_basic.dart': '''
    import 'package:jaspr/jaspr.dart';
    
    @client
    class Component extends StatelessComponent {
      Component(this.time);
      
      final DateTime time;
    
      @override
      Component build(BuildContext context) => text('');
    }
  ''',
};
