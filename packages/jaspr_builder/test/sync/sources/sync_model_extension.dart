import '../../codec/sources/model_extension.dart';

final syncModelExtensionSources = {
  'site|lib/component.dart': '''
    import 'package:jaspr/jaspr.dart';
    import 'model_type.dart';
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
  ...modelExtensionSources,
  ...modelExtensionOutputs,
};

final syncModelExtensionOutputs = {
  'site|lib/component.sync.dart': '// GENERATED FILE, DO NOT MODIFY\n'
      '// Generated with jaspr_builder\n'
      '\n'
      'import \'package:jaspr/jaspr.dart\';\n'
      'import \'package:site/component.dart\' as prefix0;\n'
      'import \'package:site/model_extension.dart\' as prefix1;\n'
      'import \'package:site/model_type.dart\' as prefix2;\n'
      '\n'
      'mixin ComponentStateSyncMixin on State<prefix0.Component>\n'
      '    implements SyncStateMixin<prefix0.Component, Map<String, dynamic>> {\n'
      '  prefix2.Model? get m;\n'
      '  set m(prefix2.Model? m);\n'
      '\n'
      '  prefix2.Model get m2;\n'
      '  set m2(prefix2.Model m2);\n'
      '\n'
      '  List<prefix2.Model> get m3;\n'
      '  set m3(List<prefix2.Model> m3);\n'
      '\n'
      '  List<prefix2.Model?> get m4;\n'
      '  set m4(List<prefix2.Model?> m4);\n'
      '\n'
      '  Map<String, prefix2.Model> get m5;\n'
      '  set m5(Map<String, prefix2.Model> m5);\n'
      '\n'
      '  Map<String, prefix2.Model?> get m6;\n'
      '  set m6(Map<String, prefix2.Model?> m6);\n'
      '\n'
      '  @override\n'
      '  void updateState(Map<String, dynamic> value) {\n'
      '    m = value[\'m\'] != null ? prefix1.ModelCodec.fromRaw(value[\'m\']!) : null;\n'
      '    m2 = prefix1.ModelCodec.fromRaw(value[\'m2\']);\n'
      '    m3 = (value[\'m3\'] as List<dynamic>).map((i) => prefix1.ModelCodec.fromRaw(i)).toList();\n'
      '    m4 = (value[\'m4\'] as List<dynamic>).map((i) => i != null ? prefix1.ModelCodec.fromRaw(i!) : null).toList();\n'
      '    m5 = (value[\'m5\'] as Map<String, dynamic>).map((k, v) => MapEntry(k, prefix1.ModelCodec.fromRaw(v)));\n'
      '    m6 = (value[\'m6\'] as Map<String, dynamic>)\n'
      '        .map((k, v) => MapEntry(k, v != null ? prefix1.ModelCodec.fromRaw(v!) : null));\n'
      '  }\n'
      '\n'
      '  @override\n'
      '  Map<String, dynamic> getState() {\n'
      '    return {\n'
      '      \'m\': m != null ? prefix1.ModelCodec(m!).toRaw() : null,\n'
      '      \'m2\': prefix1.ModelCodec(m2).toRaw(),\n'
      '      \'m3\': m3.map((i) => prefix1.ModelCodec(i).toRaw()).toList(),\n'
      '      \'m4\': m4.map((i) => i != null ? prefix1.ModelCodec(i!).toRaw() : null).toList(),\n'
      '      \'m5\': m5.map((k, v) => MapEntry(k, prefix1.ModelCodec(v).toRaw())),\n'
      '      \'m6\': m6.map((k, v) => MapEntry(k, v != null ? prefix1.ModelCodec(v!).toRaw() : null)),\n'
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
