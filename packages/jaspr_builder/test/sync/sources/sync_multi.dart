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
    
      Component build(BuildContext context) => text('');
    }
    
    class Component2 extends StatefulComponent {
      State createState() => Component2State();
    }
    
    class Component2State extends State<Component2> with Component2StateSyncMixin {
      @sync
      int c = 0;
      
      @sync
      String? d;
    
      Component build(BuildContext context) => text('');
    }
  ''',
};

final syncMultiOutputs = {
  'site|lib/component.sync.dart':
      '// dart format off\n'
      '// ignore_for_file: type=lint\n'
      '\n'
      '// GENERATED FILE, DO NOT MODIFY\n'
      '// Generated with jaspr_builder\n'
      '\n'
      'import \'package:jaspr/jaspr.dart\';\n'
      'import \'package:site/component.dart\' as _component;\n'
      '\n'
      'mixin ComponentStateSyncMixin on State<_component.Component>\n'
      '    implements SyncStateMixin<_component.Component, Map<String, dynamic>> {\n'
      '  int get a;\n'
      '  set a(int a);\n'
      '\n'
      '  String? get b;\n'
      '  set b(String? b);\n'
      '\n'
      '  @override\n'
      '  void updateState(Map<String, dynamic> value) {\n'
      '    a = value[\'a\'] as int;\n'
      '    b = value[\'b\'] as String?;\n'
      '  }\n'
      '\n'
      '  @override\n'
      '  Map<String, dynamic> getState() {\n'
      '    return {\'a\': a, \'b\': b};\n'
      '  }\n'
      '\n'
      '  @override\n'
      '  void initState() {\n'
      '    super.initState();\n'
      '    SyncStateMixin.initSyncState(this);\n'
      '  }\n'
      '}\n'
      '\n'
      'mixin Component2StateSyncMixin on State<_component.Component2>\n'
      '    implements SyncStateMixin<_component.Component2, Map<String, dynamic>> {\n'
      '  int get c;\n'
      '  set c(int c);\n'
      '\n'
      '  String? get d;\n'
      '  set d(String? d);\n'
      '\n'
      '  @override\n'
      '  void updateState(Map<String, dynamic> value) {\n'
      '    c = value[\'c\'] as int;\n'
      '    d = value[\'d\'] as String?;\n'
      '  }\n'
      '\n'
      '  @override\n'
      '  Map<String, dynamic> getState() {\n'
      '    return {\'c\': c, \'d\': d};\n'
      '  }\n'
      '\n'
      '  @override\n'
      '  void initState() {\n'
      '    super.initState();\n'
      '    SyncStateMixin.initSyncState(this);\n'
      '  }\n'
      '}\n'
      '',
};
