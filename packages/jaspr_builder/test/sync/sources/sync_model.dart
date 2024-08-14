final syncModelSources = {
  'site|lib/component.dart': '''
    import 'package:jaspr/jaspr.dart';
    import 'model.dart';
    import 'component.sync.dart';
    
    class Component extends StatefulComponent {
      State createState() => ComponentState();
    }
    
    class ComponentState extends State<Component> with ComponentStateSyncMixin {
      @sync
      Model? m;
      @sync
      late Model m2;
      @sync
      List<Model> m3 = [];
      @sync
      List<Model?> m4 = [];
      @sync
      Map<String, Model> m5 = {};
      @sync
      Map<String, Model?> m6 = {};
      
      Iterable<Component> build(BuildContext context) => [];
    }
  ''',
};
