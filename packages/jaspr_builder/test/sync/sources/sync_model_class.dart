import '../../codec/sources/bundle.dart';
import '../../codec/sources/model_class.dart';

final syncModelClassSources = {
  'site|lib/component.dart': '''
    import 'package:jaspr/jaspr.dart';
    import 'model_class.dart';
    import 'component.sync.dart';
    
    class Component extends StatefulComponent {
      State createState() => ComponentState();
    }
    
    class ComponentState extends State<Component> with ComponentStateSyncMixin {
      @sync
      ModelA? m;
      @sync
      late ModelA m2;
      @sync
      List<ModelA> m3 = [];
      @sync
      List<ModelA?> m4 = [];
      @sync
      Map<String, ModelA> m5 = {};
      @sync
      Map<String, ModelA?> m6 = {};
      
      Iterable<Component> build(BuildContext context) => [];
    }
  ''',
  ...modelClassSources,
  ...codecBundleOutputs,
};

final syncModelClassOutputs = {
  'site|lib/component.sync.dart': '// GENERATED FILE, DO NOT MODIFY\n'
      '// Generated with jaspr_builder\n'
      '\n'
      'import \'package:jaspr/jaspr.dart\';\n'
      'import \'package:site/component.dart\' as prefix0;\n'
      'import \'package:site/model_class.dart\' as prefix1;\n'
      '\n'
      'mixin ComponentStateSyncMixin on State<prefix0.Component>\n'
      '    implements SyncStateMixin<prefix0.Component, Map<String, dynamic>> {\n'
      '  prefix1.ModelA? get m;\n'
      '  set m(prefix1.ModelA? m);\n'
      '\n'
      '  prefix1.ModelA get m2;\n'
      '  set m2(prefix1.ModelA m2);\n'
      '\n'
      '  List<prefix1.ModelA> get m3;\n'
      '  set m3(List<prefix1.ModelA> m3);\n'
      '\n'
      '  List<prefix1.ModelA?> get m4;\n'
      '  set m4(List<prefix1.ModelA?> m4);\n'
      '\n'
      '  Map<String, prefix1.ModelA> get m5;\n'
      '  set m5(Map<String, prefix1.ModelA> m5);\n'
      '\n'
      '  Map<String, prefix1.ModelA?> get m6;\n'
      '  set m6(Map<String, prefix1.ModelA?> m6);\n'
      '\n'
      '  @override\n'
      '  void updateState(Map<String, dynamic> value) {\n'
      '    m = value[\'m\'] != null ? prefix1.ModelA.fromRaw(value[\'m\']!) : null;\n'
      '    m2 = prefix1.ModelA.fromRaw(value[\'m2\']);\n'
      '    m3 = (value[\'m3\'] as List<dynamic>).map((i) => prefix1.ModelA.fromRaw(i)).toList();\n'
      '    m4 = (value[\'m4\'] as List<dynamic>).map((i) => i != null ? prefix1.ModelA.fromRaw(i!) : null).toList();\n'
      '    m5 = (value[\'m5\'] as Map<String, dynamic>).map((k, v) => MapEntry(k, prefix1.ModelA.fromRaw(v)));\n'
      '    m6 =\n'
      '        (value[\'m6\'] as Map<String, dynamic>).map((k, v) => MapEntry(k, v != null ? prefix1.ModelA.fromRaw(v!) : null));\n'
      '  }\n'
      '\n'
      '  @override\n'
      '  Map<String, dynamic> getState() {\n'
      '    return {\n'
      '      \'m\': m?.toRaw(),\n'
      '      \'m2\': m2.toRaw(),\n'
      '      \'m3\': m3.map((i) => i.toRaw()).toList(),\n'
      '      \'m4\': m4.map((i) => i?.toRaw()).toList(),\n'
      '      \'m5\': m5.map((k, v) => MapEntry(k, v.toRaw())),\n'
      '      \'m6\': m6.map((k, v) => MapEntry(k, v?.toRaw())),\n'
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
