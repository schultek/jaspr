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
      
      @sync
      List<double> c = [];
      
      @sync
      Map<String, Object> d = {};
    
      Iterable<Component> build(BuildContext context) => [];
    }
  ''',
};

final syncBasicOutputs = {
  'site|lib/component.sync.dart': '// dart format off\n'
      '// ignore_for_file: type=lint\n'
      '\n'
      '// GENERATED FILE, DO NOT MODIFY\n'
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
      '  List<double> get c;\n'
      '  set c(List<double> c);\n'
      '\n'
      '  Map<String, Object> get d;\n'
      '  set d(Map<String, Object> d);\n'
      '\n'
      '  @override\n'
      '  void updateState(Map<String, dynamic> value) {\n'
      '    a = value[\'a\'];\n'
      '    b = value[\'b\'];\n'
      '    c = (value[\'c\'] as List<dynamic>).cast<double>();\n'
      '    d = (value[\'d\'] as Map<String, dynamic>).cast<String, Object>();\n'
      '  }\n'
      '\n'
      '  @override\n'
      '  Map<String, dynamic> getState() {\n'
      '    return {\'a\': a, \'b\': b, \'c\': c, \'d\': d};\n'
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
