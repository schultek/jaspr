// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element

part of 'sample.dart';

class SampleMapper extends ClassMapperBase<Sample> {
  SampleMapper._();

  static SampleMapper? _instance;
  static SampleMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SampleMapper._());
    }
    return _instance!;
  }

  static T _guard<T>(T Function(MapperContainer) fn) {
    ensureInitialized();
    return fn(MapperContainer.globals);
  }

  @override
  final String id = 'Sample';

  static String _$id(Sample v) => v.id;
  static const Field<Sample, String> _f$id = Field('id', _$id);
  static String _$description(Sample v) => v.description;
  static const Field<Sample, String> _f$description = Field('description', _$description);
  static int? _$index(Sample v) => v.index;
  static const Field<Sample, int> _f$index = Field('index', _$index);

  @override
  final Map<Symbol, Field<Sample, dynamic>> fields = const {
    #id: _f$id,
    #description: _f$description,
    #index: _f$index,
  };

  static Sample _instantiate(DecodingData data) {
    return Sample(data.dec(_f$id), data.dec(_f$description), data.dec(_f$index));
  }

  @override
  final Function instantiate = _instantiate;

  static Sample fromMap(Map<String, dynamic> map) {
    return _guard((c) => c.fromMap<Sample>(map));
  }

  static Sample fromJson(String json) {
    return _guard((c) => c.fromJson<Sample>(json));
  }
}

mixin SampleMappable {
  String toJson() {
    return SampleMapper._guard((c) => c.toJson(this as Sample));
  }

  Map<String, dynamic> toMap() {
    return SampleMapper._guard((c) => c.toMap(this as Sample));
  }

  SampleCopyWith<Sample, Sample, Sample> get copyWith => _SampleCopyWithImpl(this as Sample, $identity, $identity);
  @override
  String toString() {
    return SampleMapper._guard((c) => c.asString(this));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (runtimeType == other.runtimeType && SampleMapper._guard((c) => c.isEqual(this, other)));
  }

  @override
  int get hashCode {
    return SampleMapper._guard((c) => c.hash(this));
  }
}

extension SampleValueCopy<$R, $Out> on ObjectCopyWith<$R, Sample, $Out> {
  SampleCopyWith<$R, Sample, $Out> get $asSample => $base.as((v, t, t2) => _SampleCopyWithImpl(v, t, t2));
}

abstract class SampleCopyWith<$R, $In extends Sample, $Out> implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? id, String? description, int? index});
  SampleCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _SampleCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Sample, $Out>
    implements SampleCopyWith<$R, Sample, $Out> {
  _SampleCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Sample> $mapper = SampleMapper.ensureInitialized();
  @override
  $R call({String? id, String? description, Object? index = $none}) => $apply(FieldCopyWithData({
        if (id != null) #id: id,
        if (description != null) #description: description,
        if (index != $none) #index: index
      }));
  @override
  Sample $make(CopyWithData data) => Sample(
      data.get(#id, or: $value.id), data.get(#description, or: $value.description), data.get(#index, or: $value.index));

  @override
  SampleCopyWith<$R2, Sample, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) => _SampleCopyWithImpl($value, $cast, t);
}

class SampleResponseMapper extends ClassMapperBase<SampleResponse> {
  SampleResponseMapper._();

  static SampleResponseMapper? _instance;
  static SampleResponseMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SampleResponseMapper._());
      ProjectDataMapper.ensureInitialized();
    }
    return _instance!;
  }

  static T _guard<T>(T Function(MapperContainer) fn) {
    ensureInitialized();
    return fn(MapperContainer.globals);
  }

  @override
  final String id = 'SampleResponse';

  static ProjectData? _$project(SampleResponse v) => v.project;
  static const Field<SampleResponse, ProjectData> _f$project = Field('project', _$project);
  static String? _$error(SampleResponse v) => v.error;
  static const Field<SampleResponse, String> _f$error = Field('error', _$error);

  @override
  final Map<Symbol, Field<SampleResponse, dynamic>> fields = const {
    #project: _f$project,
    #error: _f$error,
  };

  static SampleResponse _instantiate(DecodingData data) {
    return SampleResponse(data.dec(_f$project), data.dec(_f$error));
  }

  @override
  final Function instantiate = _instantiate;

  static SampleResponse fromMap(Map<String, dynamic> map) {
    return _guard((c) => c.fromMap<SampleResponse>(map));
  }

  static SampleResponse fromJson(String json) {
    return _guard((c) => c.fromJson<SampleResponse>(json));
  }
}

mixin SampleResponseMappable {
  String toJson() {
    return SampleResponseMapper._guard((c) => c.toJson(this as SampleResponse));
  }

  Map<String, dynamic> toMap() {
    return SampleResponseMapper._guard((c) => c.toMap(this as SampleResponse));
  }

  SampleResponseCopyWith<SampleResponse, SampleResponse, SampleResponse> get copyWith =>
      _SampleResponseCopyWithImpl(this as SampleResponse, $identity, $identity);
  @override
  String toString() {
    return SampleResponseMapper._guard((c) => c.asString(this));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (runtimeType == other.runtimeType && SampleResponseMapper._guard((c) => c.isEqual(this, other)));
  }

  @override
  int get hashCode {
    return SampleResponseMapper._guard((c) => c.hash(this));
  }
}

extension SampleResponseValueCopy<$R, $Out> on ObjectCopyWith<$R, SampleResponse, $Out> {
  SampleResponseCopyWith<$R, SampleResponse, $Out> get $asSampleResponse =>
      $base.as((v, t, t2) => _SampleResponseCopyWithImpl(v, t, t2));
}

abstract class SampleResponseCopyWith<$R, $In extends SampleResponse, $Out> implements ClassCopyWith<$R, $In, $Out> {
  ProjectDataCopyWith<$R, ProjectData, ProjectData>? get project;
  $R call({ProjectData? project, String? error});
  SampleResponseCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _SampleResponseCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, SampleResponse, $Out>
    implements SampleResponseCopyWith<$R, SampleResponse, $Out> {
  _SampleResponseCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<SampleResponse> $mapper = SampleResponseMapper.ensureInitialized();
  @override
  ProjectDataCopyWith<$R, ProjectData, ProjectData>? get project =>
      $value.project?.copyWith.$chain((v) => call(project: v));
  @override
  $R call({Object? project = $none, Object? error = $none}) =>
      $apply(FieldCopyWithData({if (project != $none) #project: project, if (error != $none) #error: error}));
  @override
  SampleResponse $make(CopyWithData data) =>
      SampleResponse(data.get(#project, or: $value.project), data.get(#error, or: $value.error));

  @override
  SampleResponseCopyWith<$R2, SampleResponse, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _SampleResponseCopyWithImpl($value, $cast, t);
}
