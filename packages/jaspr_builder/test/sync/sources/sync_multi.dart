final syncMultiSources = {
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
    
    class Component2 extends StatefulComponent {
      State createState() => Component2State();
    }
    
    class Component2State extends State<Component2> with Component2StateSyncMixin {
      @sync
      int c = 0;
      
      @sync
      String? d;
    
      Iterable<Component> build(BuildContext context) => [];
    }
  ''',
};

final syncMultiOutputs = {
  'site|lib/component.sync.dart': '// GENERATED FILE, DO NOT MODIFY\n'
      '// Generated with jaspr_builder\n'
      '\n'
      'import \'package:jaspr/jaspr.dart\';\n'
      'import \'package:site/component.dart\' as prefix0;\n'
      '\n'
      'mixin ComponentStateSyncMixin on State<prefix0.Component>\n'
      '    implements SyncStateMixin<prefix0.Component, Map<String, dynamic>> {\n'
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
      '}\n'
      '\n'
      'mixin Component2StateSyncMixin on State<prefix0.Component2>\n'
      '    implements SyncStateMixin<prefix0.Component2, Map<String, dynamic>> {\n'
      '  int get c;\n'
      '  set c(int c);\n'
      '\n'
      '  String? get d;\n'
      '  set d(String? d);\n'
      '\n'
      '  @override\n'
      '  void updateState(Map<String, dynamic> value) {\n'
      '    c = value[\'c\'];\n'
      '    d = value[\'d\'];\n'
      '  }\n'
      '\n'
      '  @override\n'
      '  Map<String, dynamic> getState() {\n'
      '    return {\n'
      '      \'c\': c,\n'
      '      \'d\': d,\n'
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
