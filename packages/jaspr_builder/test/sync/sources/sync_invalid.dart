final syncInvalidSources = {
  'site|lib/component.dart': '''
    import 'package:jaspr/jaspr.dart';
    import 'component.sync.dart';
    
    class Component extends StatefulComponent {
      State createState() => ComponentState();
    }
    
    class ComponentState extends State<Component> with ComponentStateSyncMixin {
      @sync
      Map<int, int> a = {};
    
      Iterable<Component> build(BuildContext context) => [];
    }
  ''',
};
