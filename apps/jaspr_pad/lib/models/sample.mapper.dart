// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element

part of 'sample.dart';

class SampleMapper extends MapperBase<Sample> {
  static MapperContainer container = MapperContainer(
    mappers: {SampleMapper()},
  );

  @override
  SampleMapperElement createElement(MapperContainer container) {
    return SampleMapperElement._(this, container);
  }

  @override
  String get id => 'Sample';

  static final fromMap = container.fromMap<Sample>;
  static final fromJson = container.fromJson<Sample>;
}

class SampleMapperElement extends MapperElementBase<Sample> {
  SampleMapperElement._(super.mapper, super.container);

  @override
  Function get decoder => decode;
  Sample decode(dynamic v) =>
      checkedType(v, (Map<String, dynamic> map) => fromMap(map));
  Sample fromMap(Map<String, dynamic> map) => Sample(container.$get(map, 'id'),
      container.$get(map, 'description'), container.$getOpt(map, 'index'));

  @override
  Function get encoder => encode;
  dynamic encode(Sample v) => toMap(v);
  Map<String, dynamic> toMap(Sample s) => {
        'id': container.$enc(s.id, 'id'),
        'description': container.$enc(s.description, 'description'),
        'index': container.$enc(s.index, 'index')
      };

  @override
  String stringify(Sample self) =>
      'Sample(id: ${container.asString(self.id)}, description: ${container.asString(self.description)}, index: ${container.asString(self.index)})';
  @override
  int hash(Sample self) =>
      container.hash(self.id) ^
      container.hash(self.description) ^
      container.hash(self.index);
  @override
  bool equals(Sample self, Sample other) =>
      container.isEqual(self.id, other.id) &&
      container.isEqual(self.description, other.description) &&
      container.isEqual(self.index, other.index);
}

mixin SampleMappable {
  String toJson() => SampleMapper.container.toJson(this as Sample);
  Map<String, dynamic> toMap() => SampleMapper.container.toMap(this as Sample);
  SampleCopyWith<Sample, Sample, Sample> get copyWith =>
      _SampleCopyWithImpl(this as Sample, $identity, $identity);
  @override
  String toString() => SampleMapper.container.asString(this);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (runtimeType == other.runtimeType &&
          SampleMapper.container.isEqual(this, other));
  @override
  int get hashCode => SampleMapper.container.hash(this);
}

extension SampleValueCopy<$R, $Out extends Sample>
    on ObjectCopyWith<$R, Sample, $Out> {
  SampleCopyWith<$R, Sample, $Out> get asSample =>
      base.as((v, t, t2) => _SampleCopyWithImpl(v, t, t2));
}

typedef SampleCopyWithBound = Sample;

abstract class SampleCopyWith<$R, $In extends Sample, $Out extends Sample>
    implements ObjectCopyWith<$R, $In, $Out> {
  SampleCopyWith<$R2, $In, $Out2> chain<$R2, $Out2 extends Sample>(
      Then<Sample, $Out2> t, Then<$Out2, $R2> t2);
  $R call({String? id, String? description, int? index});
}

class _SampleCopyWithImpl<$R, $Out extends Sample>
    extends CopyWithBase<$R, Sample, $Out>
    implements SampleCopyWith<$R, Sample, $Out> {
  _SampleCopyWithImpl(super.value, super.then, super.then2);
  @override
  SampleCopyWith<$R2, Sample, $Out2> chain<$R2, $Out2 extends Sample>(
          Then<Sample, $Out2> t, Then<$Out2, $R2> t2) =>
      _SampleCopyWithImpl($value, t, t2);

  @override
  $R call({String? id, String? description, Object? index = $none}) =>
      $then(Sample(id ?? $value.id, description ?? $value.description,
          or(index, $value.index)));
}

class SampleResponseMapper extends MapperBase<SampleResponse> {
  static MapperContainer container = MapperContainer(
    mappers: {SampleResponseMapper()},
  )..linkAll({ProjectDataMapper.container});

  @override
  SampleResponseMapperElement createElement(MapperContainer container) {
    return SampleResponseMapperElement._(this, container);
  }

  @override
  String get id => 'SampleResponse';

  static final fromMap = container.fromMap<SampleResponse>;
  static final fromJson = container.fromJson<SampleResponse>;
}

class SampleResponseMapperElement extends MapperElementBase<SampleResponse> {
  SampleResponseMapperElement._(super.mapper, super.container);

  @override
  Function get decoder => decode;
  SampleResponse decode(dynamic v) =>
      checkedType(v, (Map<String, dynamic> map) => fromMap(map));
  SampleResponse fromMap(Map<String, dynamic> map) => SampleResponse(
      container.$getOpt(map, 'project'), container.$getOpt(map, 'error'));

  @override
  Function get encoder => encode;
  dynamic encode(SampleResponse v) => toMap(v);
  Map<String, dynamic> toMap(SampleResponse s) => {
        'project': container.$enc(s.project, 'project'),
        'error': container.$enc(s.error, 'error')
      };

  @override
  String stringify(SampleResponse self) =>
      'SampleResponse(project: ${container.asString(self.project)}, error: ${container.asString(self.error)})';
  @override
  int hash(SampleResponse self) =>
      container.hash(self.project) ^ container.hash(self.error);
  @override
  bool equals(SampleResponse self, SampleResponse other) =>
      container.isEqual(self.project, other.project) &&
      container.isEqual(self.error, other.error);
}

mixin SampleResponseMappable {
  String toJson() =>
      SampleResponseMapper.container.toJson(this as SampleResponse);
  Map<String, dynamic> toMap() =>
      SampleResponseMapper.container.toMap(this as SampleResponse);
  SampleResponseCopyWith<SampleResponse, SampleResponse, SampleResponse>
      get copyWith => _SampleResponseCopyWithImpl(
          this as SampleResponse, $identity, $identity);
  @override
  String toString() => SampleResponseMapper.container.asString(this);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (runtimeType == other.runtimeType &&
          SampleResponseMapper.container.isEqual(this, other));
  @override
  int get hashCode => SampleResponseMapper.container.hash(this);
}

extension SampleResponseValueCopy<$R, $Out extends SampleResponse>
    on ObjectCopyWith<$R, SampleResponse, $Out> {
  SampleResponseCopyWith<$R, SampleResponse, $Out> get asSampleResponse =>
      base.as((v, t, t2) => _SampleResponseCopyWithImpl(v, t, t2));
}

typedef SampleResponseCopyWithBound = SampleResponse;

abstract class SampleResponseCopyWith<$R, $In extends SampleResponse,
    $Out extends SampleResponse> implements ObjectCopyWith<$R, $In, $Out> {
  SampleResponseCopyWith<$R2, $In, $Out2>
      chain<$R2, $Out2 extends SampleResponse>(
          Then<SampleResponse, $Out2> t, Then<$Out2, $R2> t2);
  ProjectDataCopyWith<$R, ProjectData, ProjectData>? get project;
  $R call({ProjectData? project, String? error});
}

class _SampleResponseCopyWithImpl<$R, $Out extends SampleResponse>
    extends CopyWithBase<$R, SampleResponse, $Out>
    implements SampleResponseCopyWith<$R, SampleResponse, $Out> {
  _SampleResponseCopyWithImpl(super.value, super.then, super.then2);
  @override
  SampleResponseCopyWith<$R2, SampleResponse, $Out2>
      chain<$R2, $Out2 extends SampleResponse>(
              Then<SampleResponse, $Out2> t, Then<$Out2, $R2> t2) =>
          _SampleResponseCopyWithImpl($value, t, t2);

  @override
  ProjectDataCopyWith<$R, ProjectData, ProjectData>? get project =>
      $value.project?.copyWith.chain($identity, (v) => call(project: v));
  @override
  $R call({Object? project = $none, Object? error = $none}) => $then(
      SampleResponse(or(project, $value.project), or(error, $value.error)));
}
