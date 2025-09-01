// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'tutorial.dart';

class TutorialDataMapper extends SubClassMapperBase<TutorialData> {
  TutorialDataMapper._();

  static TutorialDataMapper? _instance;
  static TutorialDataMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TutorialDataMapper._());
      ProjectDataBaseMapper.ensureInitialized().addSubMapper(_instance!);
      TutorialStepConfigMapper.ensureInitialized();
      TutorialStepMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'TutorialData';

  static String _$id(TutorialData v) => v.id;
  static const Field<TutorialData, String> _f$id = Field('id', _$id);
  static String _$description(TutorialData v) => v.description;
  static const Field<TutorialData, String> _f$description = Field(
    'description',
    _$description,
  );
  static int _$currentStep(TutorialData v) => v.currentStep;
  static const Field<TutorialData, int> _f$currentStep = Field(
    'currentStep',
    _$currentStep,
  );
  static List<TutorialStepConfig> _$configs(TutorialData v) => v.configs;
  static const Field<TutorialData, List<TutorialStepConfig>> _f$configs = Field(
    'configs',
    _$configs,
  );
  static Map<String, TutorialStep> _$steps(TutorialData v) => v.steps;
  static const Field<TutorialData, Map<String, TutorialStep>> _f$steps = Field(
    'steps',
    _$steps,
  );
  static String _$currentStepId(TutorialData v) => v.currentStepId;
  static const Field<TutorialData, String> _f$currentStepId = Field(
    'currentStepId',
    _$currentStepId,
    mode: FieldMode.member,
  );
  static TutorialStep _$step(TutorialData v) => v.step;
  static const Field<TutorialData, TutorialStep> _f$step = Field(
    'step',
    _$step,
    mode: FieldMode.member,
  );
  static String? _$cssFile(TutorialData v) => v.cssFile;
  static const Field<TutorialData, String> _f$cssFile = Field(
    'cssFile',
    _$cssFile,
    mode: FieldMode.member,
  );
  static Map<String, String> _$dartFiles(TutorialData v) => v.dartFiles;
  static const Field<TutorialData, Map<String, String>> _f$dartFiles = Field(
    'dartFiles',
    _$dartFiles,
    mode: FieldMode.member,
  );
  static Map<String, String> _$allDartFiles(TutorialData v) => v.allDartFiles;
  static const Field<TutorialData, Map<String, String>> _f$allDartFiles = Field(
    'allDartFiles',
    _$allDartFiles,
    mode: FieldMode.member,
  );
  static List<String> _$fileNames(TutorialData v) => v.fileNames;
  static const Field<TutorialData, List<String>> _f$fileNames = Field(
    'fileNames',
    _$fileNames,
    mode: FieldMode.member,
  );
  static String? _$htmlFile(TutorialData v) => v.htmlFile;
  static const Field<TutorialData, String> _f$htmlFile = Field(
    'htmlFile',
    _$htmlFile,
    mode: FieldMode.member,
  );
  static String _$mainDartFile(TutorialData v) => v.mainDartFile;
  static const Field<TutorialData, String> _f$mainDartFile = Field(
    'mainDartFile',
    _$mainDartFile,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<TutorialData> fields = const {
    #id: _f$id,
    #description: _f$description,
    #currentStep: _f$currentStep,
    #configs: _f$configs,
    #steps: _f$steps,
    #currentStepId: _f$currentStepId,
    #step: _f$step,
    #cssFile: _f$cssFile,
    #dartFiles: _f$dartFiles,
    #allDartFiles: _f$allDartFiles,
    #fileNames: _f$fileNames,
    #htmlFile: _f$htmlFile,
    #mainDartFile: _f$mainDartFile,
  };

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'TutorialData';
  @override
  late final ClassMapperBase superMapper = ProjectDataBaseMapper.ensureInitialized();

  static TutorialData _instantiate(DecodingData data) {
    return TutorialData(
      data.dec(_f$id),
      data.dec(_f$description),
      data.dec(_f$currentStep),
      data.dec(_f$configs),
      data.dec(_f$steps),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static TutorialData fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TutorialData>(map);
  }

  static TutorialData fromJson(String json) {
    return ensureInitialized().decodeJson<TutorialData>(json);
  }
}

mixin TutorialDataMappable {
  String toJson() {
    return TutorialDataMapper.ensureInitialized().encodeJson<TutorialData>(
      this as TutorialData,
    );
  }

  Map<String, dynamic> toMap() {
    return TutorialDataMapper.ensureInitialized().encodeMap<TutorialData>(
      this as TutorialData,
    );
  }

  TutorialDataCopyWith<TutorialData, TutorialData, TutorialData> get copyWith =>
      _TutorialDataCopyWithImpl<TutorialData, TutorialData>(
        this as TutorialData,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return TutorialDataMapper.ensureInitialized().stringifyValue(
      this as TutorialData,
    );
  }

  @override
  bool operator ==(Object other) {
    return TutorialDataMapper.ensureInitialized().equalsValue(
      this as TutorialData,
      other,
    );
  }

  @override
  int get hashCode {
    return TutorialDataMapper.ensureInitialized().hashValue(
      this as TutorialData,
    );
  }
}

extension TutorialDataValueCopy<$R, $Out> on ObjectCopyWith<$R, TutorialData, $Out> {
  TutorialDataCopyWith<$R, TutorialData, $Out> get $asTutorialData =>
      $base.as((v, t, t2) => _TutorialDataCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class TutorialDataCopyWith<$R, $In extends TutorialData, $Out> implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, TutorialStepConfig, TutorialStepConfigCopyWith<$R, TutorialStepConfig, TutorialStepConfig>>
      get configs;
  MapCopyWith<$R, String, TutorialStep, TutorialStepCopyWith<$R, TutorialStep, TutorialStep>> get steps;
  $R call({
    covariant String? id,
    covariant String? description,
    int? currentStep,
    List<TutorialStepConfig>? configs,
    Map<String, TutorialStep>? steps,
  });
  TutorialDataCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _TutorialDataCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, TutorialData, $Out>
    implements TutorialDataCopyWith<$R, TutorialData, $Out> {
  _TutorialDataCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<TutorialData> $mapper = TutorialDataMapper.ensureInitialized();
  @override
  ListCopyWith<$R, TutorialStepConfig, TutorialStepConfigCopyWith<$R, TutorialStepConfig, TutorialStepConfig>>
      get configs => ListCopyWith(
            $value.configs,
            (v, t) => v.copyWith.$chain(t),
            (v) => call(configs: v),
          );
  @override
  MapCopyWith<$R, String, TutorialStep, TutorialStepCopyWith<$R, TutorialStep, TutorialStep>> get steps => MapCopyWith(
        $value.steps,
        (v, t) => v.copyWith.$chain(t),
        (v) => call(steps: v),
      );
  @override
  $R call({
    String? id,
    String? description,
    int? currentStep,
    List<TutorialStepConfig>? configs,
    Map<String, TutorialStep>? steps,
  }) =>
      $apply(
        FieldCopyWithData({
          if (id != null) #id: id,
          if (description != null) #description: description,
          if (currentStep != null) #currentStep: currentStep,
          if (configs != null) #configs: configs,
          if (steps != null) #steps: steps,
        }),
      );
  @override
  TutorialData $make(CopyWithData data) => TutorialData(
        data.get(#id, or: $value.id),
        data.get(#description, or: $value.description),
        data.get(#currentStep, or: $value.currentStep),
        data.get(#configs, or: $value.configs),
        data.get(#steps, or: $value.steps),
      );

  @override
  TutorialDataCopyWith<$R2, TutorialData, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) =>
      _TutorialDataCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class TutorialStepConfigMapper extends ClassMapperBase<TutorialStepConfig> {
  TutorialStepConfigMapper._();

  static TutorialStepConfigMapper? _instance;
  static TutorialStepConfigMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TutorialStepConfigMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'TutorialStepConfig';

  static String _$id(TutorialStepConfig v) => v.id;
  static const Field<TutorialStepConfig, String> _f$id = Field('id', _$id);
  static String _$name(TutorialStepConfig v) => v.name;
  static const Field<TutorialStepConfig, String> _f$name = Field(
    'name',
    _$name,
  );

  @override
  final MappableFields<TutorialStepConfig> fields = const {
    #id: _f$id,
    #name: _f$name,
  };

  static TutorialStepConfig _instantiate(DecodingData data) {
    return TutorialStepConfig(data.dec(_f$id), data.dec(_f$name));
  }

  @override
  final Function instantiate = _instantiate;

  static TutorialStepConfig fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TutorialStepConfig>(map);
  }

  static TutorialStepConfig fromJson(String json) {
    return ensureInitialized().decodeJson<TutorialStepConfig>(json);
  }
}

mixin TutorialStepConfigMappable {
  String toJson() {
    return TutorialStepConfigMapper.ensureInitialized().encodeJson<TutorialStepConfig>(this as TutorialStepConfig);
  }

  Map<String, dynamic> toMap() {
    return TutorialStepConfigMapper.ensureInitialized().encodeMap<TutorialStepConfig>(this as TutorialStepConfig);
  }

  TutorialStepConfigCopyWith<TutorialStepConfig, TutorialStepConfig, TutorialStepConfig> get copyWith =>
      _TutorialStepConfigCopyWithImpl<TutorialStepConfig, TutorialStepConfig>(
        this as TutorialStepConfig,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return TutorialStepConfigMapper.ensureInitialized().stringifyValue(
      this as TutorialStepConfig,
    );
  }

  @override
  bool operator ==(Object other) {
    return TutorialStepConfigMapper.ensureInitialized().equalsValue(
      this as TutorialStepConfig,
      other,
    );
  }

  @override
  int get hashCode {
    return TutorialStepConfigMapper.ensureInitialized().hashValue(
      this as TutorialStepConfig,
    );
  }
}

extension TutorialStepConfigValueCopy<$R, $Out> on ObjectCopyWith<$R, TutorialStepConfig, $Out> {
  TutorialStepConfigCopyWith<$R, TutorialStepConfig, $Out> get $asTutorialStepConfig => $base.as(
        (v, t, t2) => _TutorialStepConfigCopyWithImpl<$R, $Out>(v, t, t2),
      );
}

abstract class TutorialStepConfigCopyWith<$R, $In extends TutorialStepConfig, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? id, String? name});
  TutorialStepConfigCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _TutorialStepConfigCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, TutorialStepConfig, $Out>
    implements TutorialStepConfigCopyWith<$R, TutorialStepConfig, $Out> {
  _TutorialStepConfigCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<TutorialStepConfig> $mapper = TutorialStepConfigMapper.ensureInitialized();
  @override
  $R call({String? id, String? name}) => $apply(
        FieldCopyWithData({if (id != null) #id: id, if (name != null) #name: name}),
      );
  @override
  TutorialStepConfig $make(CopyWithData data) => TutorialStepConfig(
        data.get(#id, or: $value.id),
        data.get(#name, or: $value.name),
      );

  @override
  TutorialStepConfigCopyWith<$R2, TutorialStepConfig, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) =>
      _TutorialStepConfigCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class TutorialStepMapper extends SubClassMapperBase<TutorialStep> {
  TutorialStepMapper._();

  static TutorialStepMapper? _instance;
  static TutorialStepMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TutorialStepMapper._());
      ProjectDataBaseMapper.ensureInitialized().addSubMapper(_instance!);
      ProjectDataMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'TutorialStep';

  static String _$id(TutorialStep v) => v.id;
  static const Field<TutorialStep, String> _f$id = Field('id', _$id);
  static String _$name(TutorialStep v) => v.name;
  static const Field<TutorialStep, String> _f$name = Field('name', _$name);
  static String _$text(TutorialStep v) => v.text;
  static const Field<TutorialStep, String> _f$text = Field('text', _$text);
  static ProjectData _$step(TutorialStep v) => v.step;
  static const Field<TutorialStep, ProjectData> _f$step = Field('step', _$step);
  static ProjectData? _$solution(TutorialStep v) => v.solution;
  static const Field<TutorialStep, ProjectData> _f$solution = Field(
    'solution',
    _$solution,
  );
  static bool _$showSolution(TutorialStep v) => v.showSolution;
  static const Field<TutorialStep, bool> _f$showSolution = Field(
    'showSolution',
    _$showSolution,
    opt: true,
    def: false,
  );
  static ProjectData _$data(TutorialStep v) => v.data;
  static const Field<TutorialStep, ProjectData> _f$data = Field(
    'data',
    _$data,
    mode: FieldMode.member,
  );
  static Map<String, String> _$allDartFiles(TutorialStep v) => v.allDartFiles;
  static const Field<TutorialStep, Map<String, String>> _f$allDartFiles = Field(
    'allDartFiles',
    _$allDartFiles,
    mode: FieldMode.member,
  );
  static String? _$cssFile(TutorialStep v) => v.cssFile;
  static const Field<TutorialStep, String> _f$cssFile = Field(
    'cssFile',
    _$cssFile,
    mode: FieldMode.member,
  );
  static Map<String, String> _$dartFiles(TutorialStep v) => v.dartFiles;
  static const Field<TutorialStep, Map<String, String>> _f$dartFiles = Field(
    'dartFiles',
    _$dartFiles,
    mode: FieldMode.member,
  );
  static String? _$description(TutorialStep v) => v.description;
  static const Field<TutorialStep, String> _f$description = Field(
    'description',
    _$description,
    mode: FieldMode.member,
  );
  static List<String> _$fileNames(TutorialStep v) => v.fileNames;
  static const Field<TutorialStep, List<String>> _f$fileNames = Field(
    'fileNames',
    _$fileNames,
    mode: FieldMode.member,
  );
  static String? _$htmlFile(TutorialStep v) => v.htmlFile;
  static const Field<TutorialStep, String> _f$htmlFile = Field(
    'htmlFile',
    _$htmlFile,
    mode: FieldMode.member,
  );
  static String _$mainDartFile(TutorialStep v) => v.mainDartFile;
  static const Field<TutorialStep, String> _f$mainDartFile = Field(
    'mainDartFile',
    _$mainDartFile,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<TutorialStep> fields = const {
    #id: _f$id,
    #name: _f$name,
    #text: _f$text,
    #step: _f$step,
    #solution: _f$solution,
    #showSolution: _f$showSolution,
    #data: _f$data,
    #allDartFiles: _f$allDartFiles,
    #cssFile: _f$cssFile,
    #dartFiles: _f$dartFiles,
    #description: _f$description,
    #fileNames: _f$fileNames,
    #htmlFile: _f$htmlFile,
    #mainDartFile: _f$mainDartFile,
  };

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'TutorialStep';
  @override
  late final ClassMapperBase superMapper = ProjectDataBaseMapper.ensureInitialized();

  static TutorialStep _instantiate(DecodingData data) {
    return TutorialStep(
      data.dec(_f$id),
      data.dec(_f$name),
      data.dec(_f$text),
      data.dec(_f$step),
      data.dec(_f$solution),
      data.dec(_f$showSolution),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static TutorialStep fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TutorialStep>(map);
  }

  static TutorialStep fromJson(String json) {
    return ensureInitialized().decodeJson<TutorialStep>(json);
  }
}

mixin TutorialStepMappable {
  String toJson() {
    return TutorialStepMapper.ensureInitialized().encodeJson<TutorialStep>(
      this as TutorialStep,
    );
  }

  Map<String, dynamic> toMap() {
    return TutorialStepMapper.ensureInitialized().encodeMap<TutorialStep>(
      this as TutorialStep,
    );
  }

  TutorialStepCopyWith<TutorialStep, TutorialStep, TutorialStep> get copyWith =>
      _TutorialStepCopyWithImpl<TutorialStep, TutorialStep>(
        this as TutorialStep,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return TutorialStepMapper.ensureInitialized().stringifyValue(
      this as TutorialStep,
    );
  }

  @override
  bool operator ==(Object other) {
    return TutorialStepMapper.ensureInitialized().equalsValue(
      this as TutorialStep,
      other,
    );
  }

  @override
  int get hashCode {
    return TutorialStepMapper.ensureInitialized().hashValue(
      this as TutorialStep,
    );
  }
}

extension TutorialStepValueCopy<$R, $Out> on ObjectCopyWith<$R, TutorialStep, $Out> {
  TutorialStepCopyWith<$R, TutorialStep, $Out> get $asTutorialStep =>
      $base.as((v, t, t2) => _TutorialStepCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class TutorialStepCopyWith<$R, $In extends TutorialStep, $Out> implements ClassCopyWith<$R, $In, $Out> {
  ProjectDataCopyWith<$R, ProjectData, ProjectData> get step;
  ProjectDataCopyWith<$R, ProjectData, ProjectData>? get solution;
  $R call({
    covariant String? id,
    String? name,
    String? text,
    ProjectData? step,
    ProjectData? solution,
    bool? showSolution,
  });
  TutorialStepCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _TutorialStepCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, TutorialStep, $Out>
    implements TutorialStepCopyWith<$R, TutorialStep, $Out> {
  _TutorialStepCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<TutorialStep> $mapper = TutorialStepMapper.ensureInitialized();
  @override
  ProjectDataCopyWith<$R, ProjectData, ProjectData> get step => $value.step.copyWith.$chain((v) => call(step: v));
  @override
  ProjectDataCopyWith<$R, ProjectData, ProjectData>? get solution =>
      $value.solution?.copyWith.$chain((v) => call(solution: v));
  @override
  $R call({
    String? id,
    String? name,
    String? text,
    ProjectData? step,
    Object? solution = $none,
    bool? showSolution,
  }) =>
      $apply(
        FieldCopyWithData({
          if (id != null) #id: id,
          if (name != null) #name: name,
          if (text != null) #text: text,
          if (step != null) #step: step,
          if (solution != $none) #solution: solution,
          if (showSolution != null) #showSolution: showSolution,
        }),
      );
  @override
  TutorialStep $make(CopyWithData data) => TutorialStep(
        data.get(#id, or: $value.id),
        data.get(#name, or: $value.name),
        data.get(#text, or: $value.text),
        data.get(#step, or: $value.step),
        data.get(#solution, or: $value.solution),
        data.get(#showSolution, or: $value.showSolution),
      );

  @override
  TutorialStepCopyWith<$R2, TutorialStep, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) =>
      _TutorialStepCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class TutorialResponseMapper extends ClassMapperBase<TutorialResponse> {
  TutorialResponseMapper._();

  static TutorialResponseMapper? _instance;
  static TutorialResponseMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TutorialResponseMapper._());
      TutorialConfigMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'TutorialResponse';

  static TutorialConfig? _$tutorial(TutorialResponse v) => v.tutorial;
  static const Field<TutorialResponse, TutorialConfig> _f$tutorial = Field(
    'tutorial',
    _$tutorial,
  );
  static String? _$error(TutorialResponse v) => v.error;
  static const Field<TutorialResponse, String> _f$error = Field(
    'error',
    _$error,
  );

  @override
  final MappableFields<TutorialResponse> fields = const {
    #tutorial: _f$tutorial,
    #error: _f$error,
  };

  static TutorialResponse _instantiate(DecodingData data) {
    return TutorialResponse(data.dec(_f$tutorial), data.dec(_f$error));
  }

  @override
  final Function instantiate = _instantiate;

  static TutorialResponse fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TutorialResponse>(map);
  }

  static TutorialResponse fromJson(String json) {
    return ensureInitialized().decodeJson<TutorialResponse>(json);
  }
}

mixin TutorialResponseMappable {
  String toJson() {
    return TutorialResponseMapper.ensureInitialized().encodeJson<TutorialResponse>(this as TutorialResponse);
  }

  Map<String, dynamic> toMap() {
    return TutorialResponseMapper.ensureInitialized().encodeMap<TutorialResponse>(this as TutorialResponse);
  }

  TutorialResponseCopyWith<TutorialResponse, TutorialResponse, TutorialResponse> get copyWith =>
      _TutorialResponseCopyWithImpl<TutorialResponse, TutorialResponse>(
        this as TutorialResponse,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return TutorialResponseMapper.ensureInitialized().stringifyValue(
      this as TutorialResponse,
    );
  }

  @override
  bool operator ==(Object other) {
    return TutorialResponseMapper.ensureInitialized().equalsValue(
      this as TutorialResponse,
      other,
    );
  }

  @override
  int get hashCode {
    return TutorialResponseMapper.ensureInitialized().hashValue(
      this as TutorialResponse,
    );
  }
}

extension TutorialResponseValueCopy<$R, $Out> on ObjectCopyWith<$R, TutorialResponse, $Out> {
  TutorialResponseCopyWith<$R, TutorialResponse, $Out> get $asTutorialResponse =>
      $base.as((v, t, t2) => _TutorialResponseCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class TutorialResponseCopyWith<$R, $In extends TutorialResponse, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  TutorialConfigCopyWith<$R, TutorialConfig, TutorialConfig>? get tutorial;
  $R call({TutorialConfig? tutorial, String? error});
  TutorialResponseCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _TutorialResponseCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, TutorialResponse, $Out>
    implements TutorialResponseCopyWith<$R, TutorialResponse, $Out> {
  _TutorialResponseCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<TutorialResponse> $mapper = TutorialResponseMapper.ensureInitialized();
  @override
  TutorialConfigCopyWith<$R, TutorialConfig, TutorialConfig>? get tutorial =>
      $value.tutorial?.copyWith.$chain((v) => call(tutorial: v));
  @override
  $R call({Object? tutorial = $none, Object? error = $none}) => $apply(
        FieldCopyWithData({
          if (tutorial != $none) #tutorial: tutorial,
          if (error != $none) #error: error,
        }),
      );
  @override
  TutorialResponse $make(CopyWithData data) => TutorialResponse(
        data.get(#tutorial, or: $value.tutorial),
        data.get(#error, or: $value.error),
      );

  @override
  TutorialResponseCopyWith<$R2, TutorialResponse, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) =>
      _TutorialResponseCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class TutorialConfigMapper extends ClassMapperBase<TutorialConfig> {
  TutorialConfigMapper._();

  static TutorialConfigMapper? _instance;
  static TutorialConfigMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TutorialConfigMapper._());
      TutorialStepConfigMapper.ensureInitialized();
      TutorialStepMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'TutorialConfig';

  static String _$id(TutorialConfig v) => v.id;
  static const Field<TutorialConfig, String> _f$id = Field('id', _$id);
  static String _$name(TutorialConfig v) => v.name;
  static const Field<TutorialConfig, String> _f$name = Field('name', _$name);
  static List<TutorialStepConfig> _$steps(TutorialConfig v) => v.steps;
  static const Field<TutorialConfig, List<TutorialStepConfig>> _f$steps = Field(
    'steps',
    _$steps,
  );
  static TutorialStep _$initialStep(TutorialConfig v) => v.initialStep;
  static const Field<TutorialConfig, TutorialStep> _f$initialStep = Field(
    'initialStep',
    _$initialStep,
  );

  @override
  final MappableFields<TutorialConfig> fields = const {
    #id: _f$id,
    #name: _f$name,
    #steps: _f$steps,
    #initialStep: _f$initialStep,
  };

  static TutorialConfig _instantiate(DecodingData data) {
    return TutorialConfig(
      data.dec(_f$id),
      data.dec(_f$name),
      data.dec(_f$steps),
      data.dec(_f$initialStep),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static TutorialConfig fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TutorialConfig>(map);
  }

  static TutorialConfig fromJson(String json) {
    return ensureInitialized().decodeJson<TutorialConfig>(json);
  }
}

mixin TutorialConfigMappable {
  String toJson() {
    return TutorialConfigMapper.ensureInitialized().encodeJson<TutorialConfig>(
      this as TutorialConfig,
    );
  }

  Map<String, dynamic> toMap() {
    return TutorialConfigMapper.ensureInitialized().encodeMap<TutorialConfig>(
      this as TutorialConfig,
    );
  }

  TutorialConfigCopyWith<TutorialConfig, TutorialConfig, TutorialConfig> get copyWith =>
      _TutorialConfigCopyWithImpl<TutorialConfig, TutorialConfig>(
        this as TutorialConfig,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return TutorialConfigMapper.ensureInitialized().stringifyValue(
      this as TutorialConfig,
    );
  }

  @override
  bool operator ==(Object other) {
    return TutorialConfigMapper.ensureInitialized().equalsValue(
      this as TutorialConfig,
      other,
    );
  }

  @override
  int get hashCode {
    return TutorialConfigMapper.ensureInitialized().hashValue(
      this as TutorialConfig,
    );
  }
}

extension TutorialConfigValueCopy<$R, $Out> on ObjectCopyWith<$R, TutorialConfig, $Out> {
  TutorialConfigCopyWith<$R, TutorialConfig, $Out> get $asTutorialConfig =>
      $base.as((v, t, t2) => _TutorialConfigCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class TutorialConfigCopyWith<$R, $In extends TutorialConfig, $Out> implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, TutorialStepConfig, TutorialStepConfigCopyWith<$R, TutorialStepConfig, TutorialStepConfig>>
      get steps;
  TutorialStepCopyWith<$R, TutorialStep, TutorialStep> get initialStep;
  $R call({
    String? id,
    String? name,
    List<TutorialStepConfig>? steps,
    TutorialStep? initialStep,
  });
  TutorialConfigCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _TutorialConfigCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, TutorialConfig, $Out>
    implements TutorialConfigCopyWith<$R, TutorialConfig, $Out> {
  _TutorialConfigCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<TutorialConfig> $mapper = TutorialConfigMapper.ensureInitialized();
  @override
  ListCopyWith<$R, TutorialStepConfig, TutorialStepConfigCopyWith<$R, TutorialStepConfig, TutorialStepConfig>>
      get steps => ListCopyWith(
            $value.steps,
            (v, t) => v.copyWith.$chain(t),
            (v) => call(steps: v),
          );
  @override
  TutorialStepCopyWith<$R, TutorialStep, TutorialStep> get initialStep =>
      $value.initialStep.copyWith.$chain((v) => call(initialStep: v));
  @override
  $R call({
    String? id,
    String? name,
    List<TutorialStepConfig>? steps,
    TutorialStep? initialStep,
  }) =>
      $apply(
        FieldCopyWithData({
          if (id != null) #id: id,
          if (name != null) #name: name,
          if (steps != null) #steps: steps,
          if (initialStep != null) #initialStep: initialStep,
        }),
      );
  @override
  TutorialConfig $make(CopyWithData data) => TutorialConfig(
        data.get(#id, or: $value.id),
        data.get(#name, or: $value.name),
        data.get(#steps, or: $value.steps),
        data.get(#initialStep, or: $value.initialStep),
      );

  @override
  TutorialConfigCopyWith<$R2, TutorialConfig, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) =>
      _TutorialConfigCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
