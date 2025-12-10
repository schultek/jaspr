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
      
      @override
      Component build(BuildContext context) => text('');
    }
  ''',
  ...modelClassSources,
  ...codecBundleOutputs,
};

final syncModelClassOutputs = {
  'site|lib/component.sync.dart':
      '// dart format off\n'
      '// ignore_for_file: type=lint\n'
      '\n'
      '// GENERATED FILE, DO NOT MODIFY\n'
      '// Generated with jaspr_builder\n'
      '\n'
      'import \'package:jaspr/jaspr.dart\';\n'
      'import \'package:site/component.dart\' as _component;\n'
      'import \'package:site/model_class.dart\' as _model_class;\n'
      '\n'
      'mixin ComponentStateSyncMixin on State<_component.Component>\n'
      '    implements SyncStateMixin<_component.Component, Map<String, dynamic>> {\n'
      '  _model_class.ModelA? get m;\n'
      '  set m(_model_class.ModelA? m);\n'
      '\n'
      '  _model_class.ModelA get m2;\n'
      '  set m2(_model_class.ModelA m2);\n'
      '\n'
      '  List<_model_class.ModelA> get m3;\n'
      '  set m3(List<_model_class.ModelA> m3);\n'
      '\n'
      '  List<_model_class.ModelA?> get m4;\n'
      '  set m4(List<_model_class.ModelA?> m4);\n'
      '\n'
      '  Map<String, _model_class.ModelA> get m5;\n'
      '  set m5(Map<String, _model_class.ModelA> m5);\n'
      '\n'
      '  Map<String, _model_class.ModelA?> get m6;\n'
      '  set m6(Map<String, _model_class.ModelA?> m6);\n'
      '\n'
      '  @override\n'
      '  void updateState(Map<String, dynamic> value) {\n'
      '    m = value[\'m\'] != null\n'
      '        ? _model_class.ModelA.fromRaw(value[\'m\'] as Map<String, dynamic>)\n'
      '        : null;\n'
      '    m2 = _model_class.ModelA.fromRaw(value[\'m2\'] as Map<String, dynamic>);\n'
      '    m3 = (value[\'m3\'] as List<Object?>)\n'
      '        .map((i) => _model_class.ModelA.fromRaw(i as Map<String, dynamic>))\n'
      '        .toList();\n'
      '    m4 = (value[\'m4\'] as List<Object?>)\n'
      '        .map(\n'
      '          (i) => i != null\n'
      '              ? _model_class.ModelA.fromRaw(i as Map<String, dynamic>)\n'
      '              : null,\n'
      '        )\n'
      '        .toList();\n'
      '    m5 = (value[\'m5\'] as Map<String, Object?>).map(\n'
      '      (k, v) =>\n'
      '          MapEntry(k, _model_class.ModelA.fromRaw(v as Map<String, dynamic>)),\n'
      '    );\n'
      '    m6 = (value[\'m6\'] as Map<String, Object?>).map(\n'
      '      (k, v) => MapEntry(\n'
      '        k,\n'
      '        v != null\n'
      '            ? _model_class.ModelA.fromRaw(v as Map<String, dynamic>)\n'
      '            : null,\n'
      '      ),\n'
      '    );\n'
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
      '}\n'
      '',
};
