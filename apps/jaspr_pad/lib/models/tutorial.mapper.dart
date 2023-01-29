// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element

part of 'tutorial.dart';

class TutorialDataMapper extends MapperBase<TutorialData> {
  static MapperContainer? _c;
  static MapperContainer container = _c ??
      ((_c = MapperContainer(
        mappers: {TutorialDataMapper()},
      ))
        ..linkAll({
          ProjectDataBaseMapper.container,
          TutorialStepConfigMapper.container,
          TutorialStepMapper.container,
        }));

  @override
  TutorialDataMapperElement createElement(MapperContainer container) {
    return TutorialDataMapperElement._(this, container);
  }

  @override
  String get id => 'TutorialData';

  static final fromMap = container.fromMap<TutorialData>;
  static final fromJson = container.fromJson<TutorialData>;
}

class TutorialDataMapperElement extends MapperElementBase<TutorialData> {
  TutorialDataMapperElement._(super.mapper, super.container);

  @override
  Function get decoder => decode;
  TutorialData decode(dynamic v) =>
      checkedType(v, (Map<String, dynamic> map) => fromMap(map));
  TutorialData fromMap(Map<String, dynamic> map) => TutorialData(
      container.$get(map, 'id'),
      container.$get(map, 'description'),
      container.$get(map, 'currentStep'),
      container.$get(map, 'configs'),
      container.$get(map, 'steps'));

  @override
  Function get encoder => encode;
  dynamic encode(TutorialData v) => toMap(v);
  Map<String, dynamic> toMap(TutorialData t) => {
        'id': container.$enc(t.id, 'id'),
        'description': container.$enc(t.description, 'description'),
        'currentStep': container.$enc(t.currentStep, 'currentStep'),
        'configs': container.$enc(t.configs, 'configs'),
        'steps': container.$enc(t.steps, 'steps'),
        'type': 'TutorialData'
      };

  @override
  String stringify(TutorialData self) =>
      'TutorialData(id: ${container.asString(self.id)}, description: ${container.asString(self.description)}, currentStep: ${container.asString(self.currentStep)}, configs: ${container.asString(self.configs)}, steps: ${container.asString(self.steps)})';
  @override
  int hash(TutorialData self) =>
      container.hash(self.id) ^
      container.hash(self.description) ^
      container.hash(self.currentStep) ^
      container.hash(self.configs) ^
      container.hash(self.steps);
  @override
  bool equals(TutorialData self, TutorialData other) =>
      container.isEqual(self.id, other.id) &&
      container.isEqual(self.description, other.description) &&
      container.isEqual(self.currentStep, other.currentStep) &&
      container.isEqual(self.configs, other.configs) &&
      container.isEqual(self.steps, other.steps);
}

mixin TutorialDataMappable {
  String toJson() => TutorialDataMapper.container.toJson(this as TutorialData);
  Map<String, dynamic> toMap() =>
      TutorialDataMapper.container.toMap(this as TutorialData);
  TutorialDataCopyWith<TutorialData, TutorialData, TutorialData> get copyWith =>
      _TutorialDataCopyWithImpl(this as TutorialData, $identity, $identity);
  @override
  String toString() => TutorialDataMapper.container.asString(this);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (runtimeType == other.runtimeType &&
          TutorialDataMapper.container.isEqual(this, other));
  @override
  int get hashCode => TutorialDataMapper.container.hash(this);
}

extension TutorialDataValueCopy<$R, $Out extends ProjectDataBase>
    on ObjectCopyWith<$R, TutorialData, $Out> {
  TutorialDataCopyWith<$R, TutorialData, $Out> get asTutorialData =>
      base.as((v, t, t2) => _TutorialDataCopyWithImpl(v, t, t2));
}

typedef TutorialDataCopyWithBound = ProjectDataBase;

abstract class TutorialDataCopyWith<$R, $In extends TutorialData,
    $Out extends ProjectDataBase> implements ObjectCopyWith<$R, $In, $Out> {
  TutorialDataCopyWith<$R2, $In, $Out2>
      chain<$R2, $Out2 extends ProjectDataBase>(
          Then<TutorialData, $Out2> t, Then<$Out2, $R2> t2);
  ListCopyWith<
      $R,
      TutorialStepConfig,
      TutorialStepConfigCopyWith<$R, TutorialStepConfig,
          TutorialStepConfig>> get configs;
  MapCopyWith<$R, String, TutorialStep,
      TutorialStepCopyWith<$R, TutorialStep, TutorialStep>> get steps;
  $R call(
      {String? id,
      String? description,
      int? currentStep,
      List<TutorialStepConfig>? configs,
      Map<String, TutorialStep>? steps});
}

class _TutorialDataCopyWithImpl<$R, $Out extends ProjectDataBase>
    extends CopyWithBase<$R, TutorialData, $Out>
    implements TutorialDataCopyWith<$R, TutorialData, $Out> {
  _TutorialDataCopyWithImpl(super.value, super.then, super.then2);
  @override
  TutorialDataCopyWith<$R2, TutorialData, $Out2>
      chain<$R2, $Out2 extends ProjectDataBase>(
              Then<TutorialData, $Out2> t, Then<$Out2, $R2> t2) =>
          _TutorialDataCopyWithImpl($value, t, t2);

  @override
  ListCopyWith<
      $R,
      TutorialStepConfig,
      TutorialStepConfigCopyWith<$R, TutorialStepConfig,
          TutorialStepConfig>> get configs => ListCopyWith(
      $value.configs,
      (v, t) => v.copyWith.chain<$R, TutorialStepConfig>($identity, t),
      (v) => call(configs: v));
  @override
  MapCopyWith<$R, String, TutorialStep,
          TutorialStepCopyWith<$R, TutorialStep, TutorialStep>>
      get steps => MapCopyWith(
          $value.steps,
          (v, t) => v.copyWith.chain<$R, TutorialStep>($identity, t),
          (v) => call(steps: v));
  @override
  $R call(
          {String? id,
          String? description,
          int? currentStep,
          List<TutorialStepConfig>? configs,
          Map<String, TutorialStep>? steps}) =>
      $then(TutorialData(
          id ?? $value.id,
          description ?? $value.description,
          currentStep ?? $value.currentStep,
          configs ?? $value.configs,
          steps ?? $value.steps));
}

class TutorialStepMapper extends MapperBase<TutorialStep> {
  static MapperContainer? _c;
  static MapperContainer container = _c ??
      ((_c = MapperContainer(
        mappers: {TutorialStepMapper()},
      ))
        ..linkAll(
            {ProjectDataBaseMapper.container, ProjectDataMapper.container}));

  @override
  TutorialStepMapperElement createElement(MapperContainer container) {
    return TutorialStepMapperElement._(this, container);
  }

  @override
  String get id => 'TutorialStep';

  static final fromMap = container.fromMap<TutorialStep>;
  static final fromJson = container.fromJson<TutorialStep>;
}

class TutorialStepMapperElement extends MapperElementBase<TutorialStep> {
  TutorialStepMapperElement._(super.mapper, super.container);

  @override
  Function get decoder => decode;
  TutorialStep decode(dynamic v) =>
      checkedType(v, (Map<String, dynamic> map) => fromMap(map));
  TutorialStep fromMap(Map<String, dynamic> map) => TutorialStep(
      container.$get(map, 'id'),
      container.$get(map, 'name'),
      container.$get(map, 'text'),
      container.$get(map, 'step'),
      container.$getOpt(map, 'solution'),
      container.$getOpt(map, 'showSolution') ?? false);

  @override
  Function get encoder => encode;
  dynamic encode(TutorialStep v) => toMap(v);
  Map<String, dynamic> toMap(TutorialStep t) => {
        'id': container.$enc(t.id, 'id'),
        'name': container.$enc(t.name, 'name'),
        'text': container.$enc(t.text, 'text'),
        'step': container.$enc(t.step, 'step'),
        'solution': container.$enc(t.solution, 'solution'),
        'showSolution': container.$enc(t.showSolution, 'showSolution'),
        'type': 'TutorialStep'
      };

  @override
  String stringify(TutorialStep self) =>
      'TutorialStep(id: ${container.asString(self.id)}, name: ${container.asString(self.name)}, text: ${container.asString(self.text)}, step: ${container.asString(self.step)}, solution: ${container.asString(self.solution)}, showSolution: ${container.asString(self.showSolution)})';
  @override
  int hash(TutorialStep self) =>
      container.hash(self.id) ^
      container.hash(self.name) ^
      container.hash(self.text) ^
      container.hash(self.step) ^
      container.hash(self.solution) ^
      container.hash(self.showSolution);
  @override
  bool equals(TutorialStep self, TutorialStep other) =>
      container.isEqual(self.id, other.id) &&
      container.isEqual(self.name, other.name) &&
      container.isEqual(self.text, other.text) &&
      container.isEqual(self.step, other.step) &&
      container.isEqual(self.solution, other.solution) &&
      container.isEqual(self.showSolution, other.showSolution);
}

mixin TutorialStepMappable {
  String toJson() => TutorialStepMapper.container.toJson(this as TutorialStep);
  Map<String, dynamic> toMap() =>
      TutorialStepMapper.container.toMap(this as TutorialStep);
  TutorialStepCopyWith<TutorialStep, TutorialStep, TutorialStep> get copyWith =>
      _TutorialStepCopyWithImpl(this as TutorialStep, $identity, $identity);
  @override
  String toString() => TutorialStepMapper.container.asString(this);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (runtimeType == other.runtimeType &&
          TutorialStepMapper.container.isEqual(this, other));
  @override
  int get hashCode => TutorialStepMapper.container.hash(this);
}

extension TutorialStepValueCopy<$R, $Out extends ProjectDataBase>
    on ObjectCopyWith<$R, TutorialStep, $Out> {
  TutorialStepCopyWith<$R, TutorialStep, $Out> get asTutorialStep =>
      base.as((v, t, t2) => _TutorialStepCopyWithImpl(v, t, t2));
}

typedef TutorialStepCopyWithBound = ProjectDataBase;

abstract class TutorialStepCopyWith<$R, $In extends TutorialStep,
    $Out extends ProjectDataBase> implements ObjectCopyWith<$R, $In, $Out> {
  TutorialStepCopyWith<$R2, $In, $Out2>
      chain<$R2, $Out2 extends ProjectDataBase>(
          Then<TutorialStep, $Out2> t, Then<$Out2, $R2> t2);
  ProjectDataCopyWith<$R, ProjectData, ProjectData> get step;
  ProjectDataCopyWith<$R, ProjectData, ProjectData>? get solution;
  $R call(
      {String? id,
      String? name,
      String? text,
      ProjectData? step,
      ProjectData? solution,
      bool? showSolution});
}

class _TutorialStepCopyWithImpl<$R, $Out extends ProjectDataBase>
    extends CopyWithBase<$R, TutorialStep, $Out>
    implements TutorialStepCopyWith<$R, TutorialStep, $Out> {
  _TutorialStepCopyWithImpl(super.value, super.then, super.then2);
  @override
  TutorialStepCopyWith<$R2, TutorialStep, $Out2>
      chain<$R2, $Out2 extends ProjectDataBase>(
              Then<TutorialStep, $Out2> t, Then<$Out2, $R2> t2) =>
          _TutorialStepCopyWithImpl($value, t, t2);

  @override
  ProjectDataCopyWith<$R, ProjectData, ProjectData> get step =>
      $value.step.copyWith.chain($identity, (v) => call(step: v));
  @override
  ProjectDataCopyWith<$R, ProjectData, ProjectData>? get solution =>
      $value.solution?.copyWith.chain($identity, (v) => call(solution: v));
  @override
  $R call(
          {String? id,
          String? name,
          String? text,
          ProjectData? step,
          Object? solution = $none,
          bool? showSolution}) =>
      $then(TutorialStep(
          id ?? $value.id,
          name ?? $value.name,
          text ?? $value.text,
          step ?? $value.step,
          or(solution, $value.solution),
          showSolution ?? $value.showSolution));
}

class TutorialResponseMapper extends MapperBase<TutorialResponse> {
  static MapperContainer container = MapperContainer(
    mappers: {TutorialResponseMapper()},
  )..linkAll({TutorialConfigMapper.container});

  @override
  TutorialResponseMapperElement createElement(MapperContainer container) {
    return TutorialResponseMapperElement._(this, container);
  }

  @override
  String get id => 'TutorialResponse';

  static final fromMap = container.fromMap<TutorialResponse>;
  static final fromJson = container.fromJson<TutorialResponse>;
}

class TutorialResponseMapperElement
    extends MapperElementBase<TutorialResponse> {
  TutorialResponseMapperElement._(super.mapper, super.container);

  @override
  Function get decoder => decode;
  TutorialResponse decode(dynamic v) =>
      checkedType(v, (Map<String, dynamic> map) => fromMap(map));
  TutorialResponse fromMap(Map<String, dynamic> map) => TutorialResponse(
      container.$getOpt(map, 'tutorial'), container.$getOpt(map, 'error'));

  @override
  Function get encoder => encode;
  dynamic encode(TutorialResponse v) => toMap(v);
  Map<String, dynamic> toMap(TutorialResponse t) => {
        'tutorial': container.$enc(t.tutorial, 'tutorial'),
        'error': container.$enc(t.error, 'error')
      };

  @override
  String stringify(TutorialResponse self) =>
      'TutorialResponse(tutorial: ${container.asString(self.tutorial)}, error: ${container.asString(self.error)})';
  @override
  int hash(TutorialResponse self) =>
      container.hash(self.tutorial) ^ container.hash(self.error);
  @override
  bool equals(TutorialResponse self, TutorialResponse other) =>
      container.isEqual(self.tutorial, other.tutorial) &&
      container.isEqual(self.error, other.error);
}

mixin TutorialResponseMappable {
  String toJson() =>
      TutorialResponseMapper.container.toJson(this as TutorialResponse);
  Map<String, dynamic> toMap() =>
      TutorialResponseMapper.container.toMap(this as TutorialResponse);
  TutorialResponseCopyWith<TutorialResponse, TutorialResponse, TutorialResponse>
      get copyWith => _TutorialResponseCopyWithImpl(
          this as TutorialResponse, $identity, $identity);
  @override
  String toString() => TutorialResponseMapper.container.asString(this);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (runtimeType == other.runtimeType &&
          TutorialResponseMapper.container.isEqual(this, other));
  @override
  int get hashCode => TutorialResponseMapper.container.hash(this);
}

extension TutorialResponseValueCopy<$R, $Out extends TutorialResponse>
    on ObjectCopyWith<$R, TutorialResponse, $Out> {
  TutorialResponseCopyWith<$R, TutorialResponse, $Out> get asTutorialResponse =>
      base.as((v, t, t2) => _TutorialResponseCopyWithImpl(v, t, t2));
}

typedef TutorialResponseCopyWithBound = TutorialResponse;

abstract class TutorialResponseCopyWith<$R, $In extends TutorialResponse,
    $Out extends TutorialResponse> implements ObjectCopyWith<$R, $In, $Out> {
  TutorialResponseCopyWith<$R2, $In, $Out2>
      chain<$R2, $Out2 extends TutorialResponse>(
          Then<TutorialResponse, $Out2> t, Then<$Out2, $R2> t2);
  TutorialConfigCopyWith<$R, TutorialConfig, TutorialConfig>? get tutorial;
  $R call({TutorialConfig? tutorial, String? error});
}

class _TutorialResponseCopyWithImpl<$R, $Out extends TutorialResponse>
    extends CopyWithBase<$R, TutorialResponse, $Out>
    implements TutorialResponseCopyWith<$R, TutorialResponse, $Out> {
  _TutorialResponseCopyWithImpl(super.value, super.then, super.then2);
  @override
  TutorialResponseCopyWith<$R2, TutorialResponse, $Out2>
      chain<$R2, $Out2 extends TutorialResponse>(
              Then<TutorialResponse, $Out2> t, Then<$Out2, $R2> t2) =>
          _TutorialResponseCopyWithImpl($value, t, t2);

  @override
  TutorialConfigCopyWith<$R, TutorialConfig, TutorialConfig>? get tutorial =>
      $value.tutorial?.copyWith.chain($identity, (v) => call(tutorial: v));
  @override
  $R call({Object? tutorial = $none, Object? error = $none}) => $then(
      TutorialResponse(or(tutorial, $value.tutorial), or(error, $value.error)));
}

class TutorialConfigMapper extends MapperBase<TutorialConfig> {
  static MapperContainer container = MapperContainer(
    mappers: {TutorialConfigMapper()},
  )..linkAll(
      {TutorialStepConfigMapper.container, TutorialStepMapper.container});

  @override
  TutorialConfigMapperElement createElement(MapperContainer container) {
    return TutorialConfigMapperElement._(this, container);
  }

  @override
  String get id => 'TutorialConfig';

  static final fromMap = container.fromMap<TutorialConfig>;
  static final fromJson = container.fromJson<TutorialConfig>;
}

class TutorialConfigMapperElement extends MapperElementBase<TutorialConfig> {
  TutorialConfigMapperElement._(super.mapper, super.container);

  @override
  Function get decoder => decode;
  TutorialConfig decode(dynamic v) =>
      checkedType(v, (Map<String, dynamic> map) => fromMap(map));
  TutorialConfig fromMap(Map<String, dynamic> map) => TutorialConfig(
      container.$get(map, 'id'),
      container.$get(map, 'name'),
      container.$get(map, 'steps'),
      container.$get(map, 'initialStep'));

  @override
  Function get encoder => encode;
  dynamic encode(TutorialConfig v) => toMap(v);
  Map<String, dynamic> toMap(TutorialConfig t) => {
        'id': container.$enc(t.id, 'id'),
        'name': container.$enc(t.name, 'name'),
        'steps': container.$enc(t.steps, 'steps'),
        'initialStep': container.$enc(t.initialStep, 'initialStep')
      };

  @override
  String stringify(TutorialConfig self) =>
      'TutorialConfig(id: ${container.asString(self.id)}, name: ${container.asString(self.name)}, steps: ${container.asString(self.steps)}, initialStep: ${container.asString(self.initialStep)})';
  @override
  int hash(TutorialConfig self) =>
      container.hash(self.id) ^
      container.hash(self.name) ^
      container.hash(self.steps) ^
      container.hash(self.initialStep);
  @override
  bool equals(TutorialConfig self, TutorialConfig other) =>
      container.isEqual(self.id, other.id) &&
      container.isEqual(self.name, other.name) &&
      container.isEqual(self.steps, other.steps) &&
      container.isEqual(self.initialStep, other.initialStep);
}

mixin TutorialConfigMappable {
  String toJson() =>
      TutorialConfigMapper.container.toJson(this as TutorialConfig);
  Map<String, dynamic> toMap() =>
      TutorialConfigMapper.container.toMap(this as TutorialConfig);
  TutorialConfigCopyWith<TutorialConfig, TutorialConfig, TutorialConfig>
      get copyWith => _TutorialConfigCopyWithImpl(
          this as TutorialConfig, $identity, $identity);
  @override
  String toString() => TutorialConfigMapper.container.asString(this);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (runtimeType == other.runtimeType &&
          TutorialConfigMapper.container.isEqual(this, other));
  @override
  int get hashCode => TutorialConfigMapper.container.hash(this);
}

extension TutorialConfigValueCopy<$R, $Out extends TutorialConfig>
    on ObjectCopyWith<$R, TutorialConfig, $Out> {
  TutorialConfigCopyWith<$R, TutorialConfig, $Out> get asTutorialConfig =>
      base.as((v, t, t2) => _TutorialConfigCopyWithImpl(v, t, t2));
}

typedef TutorialConfigCopyWithBound = TutorialConfig;

abstract class TutorialConfigCopyWith<$R, $In extends TutorialConfig,
    $Out extends TutorialConfig> implements ObjectCopyWith<$R, $In, $Out> {
  TutorialConfigCopyWith<$R2, $In, $Out2>
      chain<$R2, $Out2 extends TutorialConfig>(
          Then<TutorialConfig, $Out2> t, Then<$Out2, $R2> t2);
  ListCopyWith<
      $R,
      TutorialStepConfig,
      TutorialStepConfigCopyWith<$R, TutorialStepConfig,
          TutorialStepConfig>> get steps;
  TutorialStepCopyWith<$R, TutorialStep, TutorialStep> get initialStep;
  $R call(
      {String? id,
      String? name,
      List<TutorialStepConfig>? steps,
      TutorialStep? initialStep});
}

class _TutorialConfigCopyWithImpl<$R, $Out extends TutorialConfig>
    extends CopyWithBase<$R, TutorialConfig, $Out>
    implements TutorialConfigCopyWith<$R, TutorialConfig, $Out> {
  _TutorialConfigCopyWithImpl(super.value, super.then, super.then2);
  @override
  TutorialConfigCopyWith<$R2, TutorialConfig, $Out2>
      chain<$R2, $Out2 extends TutorialConfig>(
              Then<TutorialConfig, $Out2> t, Then<$Out2, $R2> t2) =>
          _TutorialConfigCopyWithImpl($value, t, t2);

  @override
  ListCopyWith<
      $R,
      TutorialStepConfig,
      TutorialStepConfigCopyWith<$R, TutorialStepConfig,
          TutorialStepConfig>> get steps => ListCopyWith(
      $value.steps,
      (v, t) => v.copyWith.chain<$R, TutorialStepConfig>($identity, t),
      (v) => call(steps: v));
  @override
  TutorialStepCopyWith<$R, TutorialStep, TutorialStep> get initialStep =>
      $value.initialStep.copyWith.chain($identity, (v) => call(initialStep: v));
  @override
  $R call(
          {String? id,
          String? name,
          List<TutorialStepConfig>? steps,
          TutorialStep? initialStep}) =>
      $then(TutorialConfig(id ?? $value.id, name ?? $value.name,
          steps ?? $value.steps, initialStep ?? $value.initialStep));
}

class TutorialStepConfigMapper extends MapperBase<TutorialStepConfig> {
  static MapperContainer container = MapperContainer(
    mappers: {TutorialStepConfigMapper()},
  );

  @override
  TutorialStepConfigMapperElement createElement(MapperContainer container) {
    return TutorialStepConfigMapperElement._(this, container);
  }

  @override
  String get id => 'TutorialStepConfig';

  static final fromMap = container.fromMap<TutorialStepConfig>;
  static final fromJson = container.fromJson<TutorialStepConfig>;
}

class TutorialStepConfigMapperElement
    extends MapperElementBase<TutorialStepConfig> {
  TutorialStepConfigMapperElement._(super.mapper, super.container);

  @override
  Function get decoder => decode;
  TutorialStepConfig decode(dynamic v) =>
      checkedType(v, (Map<String, dynamic> map) => fromMap(map));
  TutorialStepConfig fromMap(Map<String, dynamic> map) => TutorialStepConfig(
      container.$get(map, 'id'), container.$get(map, 'name'));

  @override
  Function get encoder => encode;
  dynamic encode(TutorialStepConfig v) => toMap(v);
  Map<String, dynamic> toMap(TutorialStepConfig t) => {
        'id': container.$enc(t.id, 'id'),
        'name': container.$enc(t.name, 'name')
      };

  @override
  String stringify(TutorialStepConfig self) =>
      'TutorialStepConfig(id: ${container.asString(self.id)}, name: ${container.asString(self.name)})';
  @override
  int hash(TutorialStepConfig self) =>
      container.hash(self.id) ^ container.hash(self.name);
  @override
  bool equals(TutorialStepConfig self, TutorialStepConfig other) =>
      container.isEqual(self.id, other.id) &&
      container.isEqual(self.name, other.name);
}

mixin TutorialStepConfigMappable {
  String toJson() =>
      TutorialStepConfigMapper.container.toJson(this as TutorialStepConfig);
  Map<String, dynamic> toMap() =>
      TutorialStepConfigMapper.container.toMap(this as TutorialStepConfig);
  TutorialStepConfigCopyWith<TutorialStepConfig, TutorialStepConfig,
          TutorialStepConfig>
      get copyWith => _TutorialStepConfigCopyWithImpl(
          this as TutorialStepConfig, $identity, $identity);
  @override
  String toString() => TutorialStepConfigMapper.container.asString(this);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (runtimeType == other.runtimeType &&
          TutorialStepConfigMapper.container.isEqual(this, other));
  @override
  int get hashCode => TutorialStepConfigMapper.container.hash(this);
}

extension TutorialStepConfigValueCopy<$R, $Out extends TutorialStepConfig>
    on ObjectCopyWith<$R, TutorialStepConfig, $Out> {
  TutorialStepConfigCopyWith<$R, TutorialStepConfig, $Out>
      get asTutorialStepConfig =>
          base.as((v, t, t2) => _TutorialStepConfigCopyWithImpl(v, t, t2));
}

typedef TutorialStepConfigCopyWithBound = TutorialStepConfig;

abstract class TutorialStepConfigCopyWith<$R, $In extends TutorialStepConfig,
    $Out extends TutorialStepConfig> implements ObjectCopyWith<$R, $In, $Out> {
  TutorialStepConfigCopyWith<$R2, $In, $Out2>
      chain<$R2, $Out2 extends TutorialStepConfig>(
          Then<TutorialStepConfig, $Out2> t, Then<$Out2, $R2> t2);
  $R call({String? id, String? name});
}

class _TutorialStepConfigCopyWithImpl<$R, $Out extends TutorialStepConfig>
    extends CopyWithBase<$R, TutorialStepConfig, $Out>
    implements TutorialStepConfigCopyWith<$R, TutorialStepConfig, $Out> {
  _TutorialStepConfigCopyWithImpl(super.value, super.then, super.then2);
  @override
  TutorialStepConfigCopyWith<$R2, TutorialStepConfig, $Out2>
      chain<$R2, $Out2 extends TutorialStepConfig>(
              Then<TutorialStepConfig, $Out2> t, Then<$Out2, $R2> t2) =>
          _TutorialStepConfigCopyWithImpl($value, t, t2);

  @override
  $R call({String? id, String? name}) =>
      $then(TutorialStepConfig(id ?? $value.id, name ?? $value.name));
}
