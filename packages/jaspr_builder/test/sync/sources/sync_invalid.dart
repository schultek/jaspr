import '../../client/sources/client_model_with_mount.dart';
import '../../codec/sources/model_with_mount.dart';

final syncInvalidTypeSources = {
  'site|lib/component.dart': '''
    import 'package:jaspr/jaspr.dart';
    import 'component.sync.dart';
    
    class Component extends StatefulComponent {
      State createState() => ComponentState();
    }
    
    class ComponentState extends State<Component> with ComponentStateSyncMixin {
      @sync
      DateTime time;
    
      @override
      Component build(BuildContext context) => text('');
    }
  ''',
};

final syncInvalidMapSources = {
  'site|lib/component.dart': '''
    import 'package:jaspr/jaspr.dart';
    import 'component.sync.dart';
    
    class Component extends StatefulComponent {
      State createState() => ComponentState();
    }
    
    class ComponentState extends State<Component> with ComponentStateSyncMixin {
      @sync
      Map<int, int> a = {};
    
      @override
      Component build(BuildContext context) => text('');
    }
  ''',
};

final syncInvalidMountSources = {
  'site|lib/component.dart': '''
    import 'package:jaspr/jaspr.dart';
    import 'model_with_mount.dart';
    import 'component.sync.dart';
    
    class Component extends StatefulComponent {
      State createState() => ComponentState();
    }
    
    class ComponentState extends State<Component> with ComponentStateSyncMixin {
      @sync
      ModelWithMountPositional model;
    
      @override
      Component build(BuildContext context) => text('');
    }
  ''',
  ...modelWithMountSources,
  ...clientModelWithMountBundleOutputs,
};
