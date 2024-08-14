final clientModelSources = {
  'site|lib/component_model.dart': '''
    import 'package:jaspr/jaspr.dart';
    import 'model.dart';
    
    @client
    class Component extends StatelessComponent {
      Component(this.a, {required this.b, super.key});
      
      final String a;
      final Model b;
    
      @override
      Iterable<Component> build(BuildContext context) => [];
    }
  ''',
};
