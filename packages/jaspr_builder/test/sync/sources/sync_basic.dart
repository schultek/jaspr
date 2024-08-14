final syncBasicSources = {
  'site|lib/component.dart': '''
    import 'package:jaspr/jaspr.dart';
    import 'component.sync.dart';
    
    class Component extends StatefulComponent {
      State createState() => ComponentState();
    }
    
    class ComponentState extends State<Component> with ComponentStateSyncMixin {
      @sync
      int a = 0;
      
      @sync
      String? b;
    
      Iterable<Component> build(BuildContext context) => [];
    }
  ''',
};

final syncBasicOutputs = {
  'site|lib/component.sync.dart': '// GENERATED FILE, DO NOT MODIFY\n'
      '// Generated with jaspr_builder\n'
      '\n'
      'import \'package:jaspr/jaspr.dart\';\n'
      'import \'package:site/component.dart\';\n'
      '\n'
      'mixin ComponentStateSyncMixin on State<Component> implements SyncStateMixin<Component, Map<String, dynamic>> {\n'
      '  int get a;\n'
      '  set a(int a);\n'
      '\n'
      '  String? get b;\n'
      '  set b(String? b);\n'
      '\n'
      '  @override\n'
      '  void updateState(Map<String, dynamic> value) {\n'
      '    a = value[\'a\'];\n'
      '    b = value[\'b\'];\n'
      '  }\n'
      '\n'
      '  @override\n'
      '  Map<String, dynamic> getState() {\n'
      '    return {\n'
      '      \'a\': a,\n'
      '      \'b\': b,\n'
      '    };\n'
      '  }\n'
      '\n'
      '  @override\n'
      '  void initState() {\n'
      '    super.initState();\n'
      '    SyncStateMixin.initSyncState(this);\n'
      '  }\n'
      '}\n',
};
