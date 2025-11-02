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
      'import \'package:site/component.dart\' as prefix0;\n'
      'import \'package:site/model_extension.dart\' as prefix1;\n'
      'import \'package:site/model_type.dart\' as prefix2;\n'
      '\n'
      'mixin ComponentStateSyncMixin on State<prefix0.Component>\n'
      '    implements SyncStateMixin<prefix0.Component, Map<String, dynamic>> {\n'
      '  prefix2.ModelB? get m;\n'
      '  set m(prefix2.ModelB? m);\n'
      '\n'
      '  prefix2.ModelB get m2;\n'
      '  set m2(prefix2.ModelB m2);\n'
      '\n'
      '  List<prefix2.ModelB> get m3;\n'
      '  set m3(List<prefix2.ModelB> m3);\n'
      '\n'
      '  List<prefix2.ModelB?> get m4;\n'
      '  set m4(List<prefix2.ModelB?> m4);\n'
      '\n'
      '  Map<String, prefix2.ModelB> get m5;\n'
      '  set m5(Map<String, prefix2.ModelB> m5);\n'
      '\n'
      '  Map<String, prefix2.ModelB?> get m6;\n'
      '  set m6(Map<String, prefix2.ModelB?> m6);\n'
      '\n'
      '  @override\n'
      '  void updateState(Map<String, dynamic> value) {\n'
      '    m = (value[\'m\'] as Map<String, dynamic>) != null\n'
      '        ? prefix1.ModelBCodec.fromRaw((value[\'m\'] as Map<String, dynamic>)!)\n'
      '        : null;\n'
      '    m2 = prefix1.ModelBCodec.fromRaw((value[\'m2\'] as Map<String, dynamic>));\n'
      '    m3 = (value[\'m3\'] as List<dynamic>)\n'
      '        .cast<Map<String, dynamic>>()\n'
      '        .map((i) => prefix1.ModelBCodec.fromRaw(i))\n'
      '        .toList();\n'
      '    m4 = (value[\'m4\'] as List<dynamic>)\n'
      '        .cast<Map<String, dynamic>>()\n'
      '        .map((i) => i != null ? prefix1.ModelBCodec.fromRaw(i!) : null)\n'
      '        .toList();\n'
      '    m5 = (value[\'m5\'] as Map<String, dynamic>)\n'
      '        .cast<String, Map<String, dynamic>>()\n'
      '        .map((k, v) => MapEntry(k, prefix1.ModelBCodec.fromRaw(v)));\n'
      '    m6 = (value[\'m6\'] as Map<String, dynamic>)\n'
      '        .cast<String, Map<String, dynamic>>()\n'
      '        .map(\n'
      '          (k, v) =>\n'
      '              MapEntry(k, v != null ? prefix1.ModelBCodec.fromRaw(v!) : null),\n'
      '        );\n'
      '  }\n'
      '\n'
      '  @override\n'
      '  Map<String, dynamic> getState() {\n'
      '    return {\n'
      '      \'m\': m != null ? prefix1.ModelBCodec(m!).toRaw() : null,\n'
      '      \'m2\': prefix1.ModelBCodec(m2).toRaw(),\n'
      '      \'m3\': m3.map((i) => prefix1.ModelBCodec(i).toRaw()).toList(),\n'
      '      \'m4\': m4\n'
      '          .map((i) => i != null ? prefix1.ModelBCodec(i!).toRaw() : null)\n'
      '          .toList(),\n'
      '      \'m5\': m5.map((k, v) => MapEntry(k, prefix1.ModelBCodec(v).toRaw())),\n'
      '      \'m6\': m6.map(\n'
      '        (k, v) =>\n'
      '            MapEntry(k, v != null ? prefix1.ModelBCodec(v!).toRaw() : null),\n'
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
