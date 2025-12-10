import '../../codec/sources/bundle.dart';
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
      ModelB? m;
      @sync
      late ModelB m2;
      @sync
      List<ModelB> m3 = [];
      @sync
      List<ModelB?> m4 = [];
      @sync
      Map<String, ModelB> m5 = {};
      @sync
      Map<String, ModelB?> m6 = {};

      @override
      Component build(BuildContext context) => text('');
    }
  ''',
  ...modelExtensionSources,
  ...codecBundleOutputs,
};

final syncModelExtensionOutputs = {
  'site|lib/component.sync.dart':
      '// dart format off\n'
      '// ignore_for_file: type=lint\n'
      '\n'
      '// GENERATED FILE, DO NOT MODIFY\n'
      '// Generated with jaspr_builder\n'
      '\n'
      'import \'package:jaspr/jaspr.dart\';\n'
      'import \'package:site/component.dart\' as _component;\n'
      'import \'package:site/model_extension.dart\' as _model_extension;\n'
      'import \'package:site/model_type.dart\' as _model_type;\n'
      '\n'
      'mixin ComponentStateSyncMixin on State<_component.Component>\n'
      '    implements SyncStateMixin<_component.Component, Map<String, dynamic>> {\n'
      '  _model_type.ModelB? get m;\n'
      '  set m(_model_type.ModelB? m);\n'
      '\n'
      '  _model_type.ModelB get m2;\n'
      '  set m2(_model_type.ModelB m2);\n'
      '\n'
      '  List<_model_type.ModelB> get m3;\n'
      '  set m3(List<_model_type.ModelB> m3);\n'
      '\n'
      '  List<_model_type.ModelB?> get m4;\n'
      '  set m4(List<_model_type.ModelB?> m4);\n'
      '\n'
      '  Map<String, _model_type.ModelB> get m5;\n'
      '  set m5(Map<String, _model_type.ModelB> m5);\n'
      '\n'
      '  Map<String, _model_type.ModelB?> get m6;\n'
      '  set m6(Map<String, _model_type.ModelB?> m6);\n'
      '\n'
      '  @override\n'
      '  void updateState(Map<String, dynamic> value) {\n'
      '    m = value[\'m\'] != null\n'
      '        ? _model_extension.ModelBCodec.fromRaw(\n'
      '            value[\'m\'] as Map<String, dynamic>,\n'
      '          )\n'
      '        : null;\n'
      '    m2 = _model_extension.ModelBCodec.fromRaw(\n'
      '      value[\'m2\'] as Map<String, dynamic>,\n'
      '    );\n'
      '    m3 = (value[\'m3\'] as List<Object?>)\n'
      '        .map(\n'
      '          (i) =>\n'
      '              _model_extension.ModelBCodec.fromRaw(i as Map<String, dynamic>),\n'
      '        )\n'
      '        .toList();\n'
      '    m4 = (value[\'m4\'] as List<Object?>)\n'
      '        .map(\n'
      '          (i) => i != null\n'
      '              ? _model_extension.ModelBCodec.fromRaw(i as Map<String, dynamic>)\n'
      '              : null,\n'
      '        )\n'
      '        .toList();\n'
      '    m5 = (value[\'m5\'] as Map<String, Object?>).map(\n'
      '      (k, v) => MapEntry(\n'
      '        k,\n'
      '        _model_extension.ModelBCodec.fromRaw(v as Map<String, dynamic>),\n'
      '      ),\n'
      '    );\n'
      '    m6 = (value[\'m6\'] as Map<String, Object?>).map(\n'
      '      (k, v) => MapEntry(\n'
      '        k,\n'
      '        v != null\n'
      '            ? _model_extension.ModelBCodec.fromRaw(v as Map<String, dynamic>)\n'
      '            : null,\n'
      '      ),\n'
      '    );\n'
      '  }\n'
      '\n'
      '  @override\n'
      '  Map<String, dynamic> getState() {\n'
      '    return {\n'
      '      \'m\': m != null ? _model_extension.ModelBCodec(m!).toRaw() : null,\n'
      '      \'m2\': _model_extension.ModelBCodec(m2).toRaw(),\n'
      '      \'m3\': m3.map((i) => _model_extension.ModelBCodec(i).toRaw()).toList(),\n'
      '      \'m4\': m4\n'
      '          .map(\n'
      '            (i) => i != null ? _model_extension.ModelBCodec(i!).toRaw() : null,\n'
      '          )\n'
      '          .toList(),\n'
      '      \'m5\': m5.map(\n'
      '        (k, v) => MapEntry(k, _model_extension.ModelBCodec(v).toRaw()),\n'
      '      ),\n'
      '      \'m6\': m6.map(\n'
      '        (k, v) => MapEntry(\n'
      '          k,\n'
      '          v != null ? _model_extension.ModelBCodec(v!).toRaw() : null,\n'
      '        ),\n'
      '      ),\n'
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
