import 'dart:core';

import 'package:dart_mappable/dart_mappable.dart';
import 'package:dart_mappable/internals.dart';

import 'models/api_models.dart';
import 'models/gist.dart';
import 'models/project.dart';
import 'models/sample.dart';


// === ALL STATICALLY REGISTERED MAPPERS ===

var _mappers = <BaseMapper>{
  // class mappers
  SampleMapper._(),
  ComparableMapper._(),
  SampleResponseMapper._(),
  ProjectDataMapper._(),
  GistDataMapper._(),
  GistFileMapper._(),
  CompileRequestMapper._(),
  CompileResponseMapper._(),
  AnalyzeRequestMapper._(),
  FormatResponseMapper._(),
  FormatRequestMapper._(),
  AnalyzeResponseMapper._(),
  IssueMapper._(),
  IssueLocationMapper._(),
  DocumentResponseMapper._(),
  HoverInfoMapper._(),
  DocumentRequestMapper._(),
  // enum mappers
  IssueKindMapper._(),
  // custom mappers
};


// === GENERATED CLASS MAPPERS AND EXTENSIONS ===

class SampleMapper extends BaseMapper<Sample> {
  SampleMapper._();

  @override Function get decoder => decode;
  Sample decode(dynamic v) => checked(v, (Map<String, dynamic> map) => fromMap(map));
  Sample fromMap(Map<String, dynamic> map) => Sample(Mapper.i.$get(map, 'id'), Mapper.i.$get(map, 'description'), Mapper.i.$getOpt(map, 'index'));

  @override Function get encoder => (Sample v) => encode(v);
  dynamic encode(Sample v) => toMap(v);
  Map<String, dynamic> toMap(Sample s) => {'id': Mapper.i.$enc(s.id, 'id'), 'description': Mapper.i.$enc(s.description, 'description'), 'index': Mapper.i.$enc(s.index, 'index')};

  @override String stringify(Sample self) => 'Sample(id: ${Mapper.asString(self.id)}, description: ${Mapper.asString(self.description)}, index: ${Mapper.asString(self.index)})';
  @override int hash(Sample self) => Mapper.hash(self.id) ^ Mapper.hash(self.description) ^ Mapper.hash(self.index);
  @override bool equals(Sample self, Sample other) => Mapper.isEqual(self.id, other.id) && Mapper.isEqual(self.description, other.description) && Mapper.isEqual(self.index, other.index);

  @override Function get typeFactory => (f) => f<Sample>();
}

extension SampleMapperExtension  on Sample {
  String toJson() => Mapper.toJson(this);
  Map<String, dynamic> toMap() => Mapper.toMap(this);
  SampleCopyWith<Sample> get copyWith => SampleCopyWith(this, $identity);
}

abstract class SampleCopyWith<$R> {
  factory SampleCopyWith(Sample value, Then<Sample, $R> then) = _SampleCopyWithImpl<$R>;
  $R call({String? id, String? description, int? index});
  $R apply(Sample Function(Sample) transform);
}

class _SampleCopyWithImpl<$R> extends BaseCopyWith<Sample, $R> implements SampleCopyWith<$R> {
  _SampleCopyWithImpl(Sample value, Then<Sample, $R> then) : super(value, then);

  @override $R call({String? id, String? description, Object? index = $none}) => $then(Sample(id ?? $value.id, description ?? $value.description, or(index, $value.index)));
}

class ComparableMapper extends BaseMapper<Comparable> {
  ComparableMapper._();

  @override Function get decoder => decode;
  Comparable<T> decode<T>(dynamic v) => checked(v, (Map<String, dynamic> map) => fromMap<T>(map));
  Comparable<T> fromMap<T>(Map<String, dynamic> map) => throw MapperException.missingConstructor('Comparable');

  @override Function get encoder => (Comparable v) => encode(v);
  dynamic encode(Comparable v) {
    if (v is Sample) { return SampleMapper._().encode(v); }
    else { return toMap(v); }
  }
  Map<String, dynamic> toMap(Comparable c) => {};

  @override String stringify(Comparable self) => 'Comparable()';
  @override int hash(Comparable self) => 0;
  @override bool equals(Comparable self, Comparable other) => true;

  @override Function get typeFactory => <T>(f) => f<Comparable<T>>();
}

extension ComparableMapperExtension <T> on Comparable<T> {
  String toJson() => Mapper.toJson(this);
  Map<String, dynamic> toMap() => Mapper.toMap(this);
}

class SampleResponseMapper extends BaseMapper<SampleResponse> {
  SampleResponseMapper._();

  @override Function get decoder => decode;
  SampleResponse decode(dynamic v) => checked(v, (Map<String, dynamic> map) => fromMap(map));
  SampleResponse fromMap(Map<String, dynamic> map) => SampleResponse(Mapper.i.$getOpt(map, 'project'), Mapper.i.$getOpt(map, 'error'));

  @override Function get encoder => (SampleResponse v) => encode(v);
  dynamic encode(SampleResponse v) => toMap(v);
  Map<String, dynamic> toMap(SampleResponse s) => {'project': Mapper.i.$enc(s.project, 'project'), 'error': Mapper.i.$enc(s.error, 'error')};

  @override String stringify(SampleResponse self) => 'SampleResponse(project: ${Mapper.asString(self.project)}, error: ${Mapper.asString(self.error)})';
  @override int hash(SampleResponse self) => Mapper.hash(self.project) ^ Mapper.hash(self.error);
  @override bool equals(SampleResponse self, SampleResponse other) => Mapper.isEqual(self.project, other.project) && Mapper.isEqual(self.error, other.error);

  @override Function get typeFactory => (f) => f<SampleResponse>();
}

extension SampleResponseMapperExtension  on SampleResponse {
  String toJson() => Mapper.toJson(this);
  Map<String, dynamic> toMap() => Mapper.toMap(this);
  SampleResponseCopyWith<SampleResponse> get copyWith => SampleResponseCopyWith(this, $identity);
}

abstract class SampleResponseCopyWith<$R> {
  factory SampleResponseCopyWith(SampleResponse value, Then<SampleResponse, $R> then) = _SampleResponseCopyWithImpl<$R>;
  ProjectDataCopyWith<$R>? get project;
  $R call({ProjectData? project, String? error});
  $R apply(SampleResponse Function(SampleResponse) transform);
}

class _SampleResponseCopyWithImpl<$R> extends BaseCopyWith<SampleResponse, $R> implements SampleResponseCopyWith<$R> {
  _SampleResponseCopyWithImpl(SampleResponse value, Then<SampleResponse, $R> then) : super(value, then);

  @override ProjectDataCopyWith<$R>? get project => $value.project != null ? ProjectDataCopyWith($value.project!, (v) => call(project: v)) : null;
  @override $R call({Object? project = $none, Object? error = $none}) => $then(SampleResponse(or(project, $value.project), or(error, $value.error)));
}

class ProjectDataMapper extends BaseMapper<ProjectData> {
  ProjectDataMapper._();

  @override Function get decoder => decode;
  ProjectData decode(dynamic v) => checked(v, (Map<String, dynamic> map) => fromMap(map));
  ProjectData fromMap(Map<String, dynamic> map) => ProjectData(id: Mapper.i.$getOpt(map, 'id'), description: Mapper.i.$getOpt(map, 'description'), htmlFile: Mapper.i.$getOpt(map, 'htmlFile'), cssFile: Mapper.i.$getOpt(map, 'cssFile'), mainDartFile: Mapper.i.$get(map, 'mainDartFile'), dartFiles: Mapper.i.$getOpt(map, 'dartFiles') ?? const {});

  @override Function get encoder => (ProjectData v) => encode(v);
  dynamic encode(ProjectData v) => toMap(v);
  Map<String, dynamic> toMap(ProjectData p) => {'id': Mapper.i.$enc(p.id, 'id'), 'description': Mapper.i.$enc(p.description, 'description'), 'htmlFile': Mapper.i.$enc(p.htmlFile, 'htmlFile'), 'cssFile': Mapper.i.$enc(p.cssFile, 'cssFile'), 'mainDartFile': Mapper.i.$enc(p.mainDartFile, 'mainDartFile'), 'dartFiles': Mapper.i.$enc(p.dartFiles, 'dartFiles')};

  @override String stringify(ProjectData self) => 'ProjectData(id: ${Mapper.asString(self.id)}, description: ${Mapper.asString(self.description)}, htmlFile: ${Mapper.asString(self.htmlFile)}, cssFile: ${Mapper.asString(self.cssFile)}, mainDartFile: ${Mapper.asString(self.mainDartFile)}, dartFiles: ${Mapper.asString(self.dartFiles)})';
  @override int hash(ProjectData self) => Mapper.hash(self.id) ^ Mapper.hash(self.description) ^ Mapper.hash(self.htmlFile) ^ Mapper.hash(self.cssFile) ^ Mapper.hash(self.mainDartFile) ^ Mapper.hash(self.dartFiles);
  @override bool equals(ProjectData self, ProjectData other) => Mapper.isEqual(self.id, other.id) && Mapper.isEqual(self.description, other.description) && Mapper.isEqual(self.htmlFile, other.htmlFile) && Mapper.isEqual(self.cssFile, other.cssFile) && Mapper.isEqual(self.mainDartFile, other.mainDartFile) && Mapper.isEqual(self.dartFiles, other.dartFiles);

  @override Function get typeFactory => (f) => f<ProjectData>();
}

extension ProjectDataMapperExtension  on ProjectData {
  String toJson() => Mapper.toJson(this);
  Map<String, dynamic> toMap() => Mapper.toMap(this);
  ProjectDataCopyWith<ProjectData> get copyWith => ProjectDataCopyWith(this, $identity);
}

abstract class ProjectDataCopyWith<$R> {
  factory ProjectDataCopyWith(ProjectData value, Then<ProjectData, $R> then) = _ProjectDataCopyWithImpl<$R>;
  $R call({String? id, String? description, String? htmlFile, String? cssFile, String? mainDartFile, Map<String, String>? dartFiles});
  $R apply(ProjectData Function(ProjectData) transform);
}

class _ProjectDataCopyWithImpl<$R> extends BaseCopyWith<ProjectData, $R> implements ProjectDataCopyWith<$R> {
  _ProjectDataCopyWithImpl(ProjectData value, Then<ProjectData, $R> then) : super(value, then);

  @override $R call({Object? id = $none, Object? description = $none, Object? htmlFile = $none, Object? cssFile = $none, String? mainDartFile, Map<String, String>? dartFiles}) => $then(ProjectData(id: or(id, $value.id), description: or(description, $value.description), htmlFile: or(htmlFile, $value.htmlFile), cssFile: or(cssFile, $value.cssFile), mainDartFile: mainDartFile ?? $value.mainDartFile, dartFiles: dartFiles ?? $value.dartFiles));
}

class GistDataMapper extends BaseMapper<GistData> {
  GistDataMapper._();

  @override Function get decoder => decode;
  GistData decode(dynamic v) => checked(v, (Map<String, dynamic> map) => fromMap(map));
  GistData fromMap(Map<String, dynamic> map) => GistData(Mapper.i.$getOpt(map, 'id'), Mapper.i.$getOpt(map, 'description'), Mapper.i.$get(map, 'files'));

  @override Function get encoder => (GistData v) => encode(v);
  dynamic encode(GistData v) => toMap(v);
  Map<String, dynamic> toMap(GistData g) => {'id': Mapper.i.$enc(g.id, 'id'), 'description': Mapper.i.$enc(g.description, 'description'), 'files': Mapper.i.$enc(g.files, 'files')};

  @override String stringify(GistData self) => 'GistData(id: ${Mapper.asString(self.id)}, description: ${Mapper.asString(self.description)}, files: ${Mapper.asString(self.files)})';
  @override int hash(GistData self) => Mapper.hash(self.id) ^ Mapper.hash(self.description) ^ Mapper.hash(self.files);
  @override bool equals(GistData self, GistData other) => Mapper.isEqual(self.id, other.id) && Mapper.isEqual(self.description, other.description) && Mapper.isEqual(self.files, other.files);

  @override Function get typeFactory => (f) => f<GistData>();
}

extension GistDataMapperExtension  on GistData {
  String toJson() => Mapper.toJson(this);
  Map<String, dynamic> toMap() => Mapper.toMap(this);
  GistDataCopyWith<GistData> get copyWith => GistDataCopyWith(this, $identity);
}

abstract class GistDataCopyWith<$R> {
  factory GistDataCopyWith(GistData value, Then<GistData, $R> then) = _GistDataCopyWithImpl<$R>;
  MapCopyWith<$R, String, GistFile, GistFileCopyWith<$R>> get files;
  $R call({String? id, String? description, Map<String, GistFile>? files});
  $R apply(GistData Function(GistData) transform);
}

class _GistDataCopyWithImpl<$R> extends BaseCopyWith<GistData, $R> implements GistDataCopyWith<$R> {
  _GistDataCopyWithImpl(GistData value, Then<GistData, $R> then) : super(value, then);

  @override MapCopyWith<$R, String, GistFile, GistFileCopyWith<$R>> get files => MapCopyWith($value.files, (v, t) => GistFileCopyWith(v, t), (v) => call(files: v));
  @override $R call({Object? id = $none, Object? description = $none, Map<String, GistFile>? files}) => $then(GistData(or(id, $value.id), or(description, $value.description), files ?? $value.files));
}

class GistFileMapper extends BaseMapper<GistFile> {
  GistFileMapper._();

  @override Function get decoder => decode;
  GistFile decode(dynamic v) => checked(v, (Map<String, dynamic> map) => fromMap(map));
  GistFile fromMap(Map<String, dynamic> map) => GistFile(Mapper.i.$get(map, 'filename'), Mapper.i.$get(map, 'content'), Mapper.i.$get(map, 'type'));

  @override Function get encoder => (GistFile v) => encode(v);
  dynamic encode(GistFile v) => toMap(v);
  Map<String, dynamic> toMap(GistFile g) => {'filename': Mapper.i.$enc(g.name, 'name'), 'content': Mapper.i.$enc(g.content, 'content'), 'type': Mapper.i.$enc(g.type, 'type')};

  @override String stringify(GistFile self) => 'GistFile(name: ${Mapper.asString(self.name)}, content: ${Mapper.asString(self.content)}, type: ${Mapper.asString(self.type)})';
  @override int hash(GistFile self) => Mapper.hash(self.name) ^ Mapper.hash(self.content) ^ Mapper.hash(self.type);
  @override bool equals(GistFile self, GistFile other) => Mapper.isEqual(self.name, other.name) && Mapper.isEqual(self.content, other.content) && Mapper.isEqual(self.type, other.type);

  @override Function get typeFactory => (f) => f<GistFile>();
}

extension GistFileMapperExtension  on GistFile {
  String toJson() => Mapper.toJson(this);
  Map<String, dynamic> toMap() => Mapper.toMap(this);
  GistFileCopyWith<GistFile> get copyWith => GistFileCopyWith(this, $identity);
}

abstract class GistFileCopyWith<$R> {
  factory GistFileCopyWith(GistFile value, Then<GistFile, $R> then) = _GistFileCopyWithImpl<$R>;
  $R call({String? name, String? content, String? type});
  $R apply(GistFile Function(GistFile) transform);
}

class _GistFileCopyWithImpl<$R> extends BaseCopyWith<GistFile, $R> implements GistFileCopyWith<$R> {
  _GistFileCopyWithImpl(GistFile value, Then<GistFile, $R> then) : super(value, then);

  @override $R call({String? name, String? content, String? type}) => $then(GistFile(name ?? $value.name, content ?? $value.content, type ?? $value.type));
}

class CompileRequestMapper extends BaseMapper<CompileRequest> {
  CompileRequestMapper._();

  @override Function get decoder => decode;
  CompileRequest decode(dynamic v) => checked(v, (Map<String, dynamic> map) => fromMap(map));
  CompileRequest fromMap(Map<String, dynamic> map) => CompileRequest(Mapper.i.$get(map, 'sources'));

  @override Function get encoder => (CompileRequest v) => encode(v);
  dynamic encode(CompileRequest v) => toMap(v);
  Map<String, dynamic> toMap(CompileRequest c) => {'sources': Mapper.i.$enc(c.sources, 'sources')};

  @override String stringify(CompileRequest self) => 'CompileRequest(sources: ${Mapper.asString(self.sources)})';
  @override int hash(CompileRequest self) => Mapper.hash(self.sources);
  @override bool equals(CompileRequest self, CompileRequest other) => Mapper.isEqual(self.sources, other.sources);

  @override Function get typeFactory => (f) => f<CompileRequest>();
}

extension CompileRequestMapperExtension  on CompileRequest {
  String toJson() => Mapper.toJson(this);
  Map<String, dynamic> toMap() => Mapper.toMap(this);
  CompileRequestCopyWith<CompileRequest> get copyWith => CompileRequestCopyWith(this, $identity);
}

abstract class CompileRequestCopyWith<$R> {
  factory CompileRequestCopyWith(CompileRequest value, Then<CompileRequest, $R> then) = _CompileRequestCopyWithImpl<$R>;
  $R call({Map<String, String>? sources});
  $R apply(CompileRequest Function(CompileRequest) transform);
}

class _CompileRequestCopyWithImpl<$R> extends BaseCopyWith<CompileRequest, $R> implements CompileRequestCopyWith<$R> {
  _CompileRequestCopyWithImpl(CompileRequest value, Then<CompileRequest, $R> then) : super(value, then);

  @override $R call({Map<String, String>? sources}) => $then(CompileRequest(sources ?? $value.sources));
}

class CompileResponseMapper extends BaseMapper<CompileResponse> {
  CompileResponseMapper._();

  @override Function get decoder => decode;
  CompileResponse decode(dynamic v) => checked(v, (Map<String, dynamic> map) => fromMap(map));
  CompileResponse fromMap(Map<String, dynamic> map) => CompileResponse(Mapper.i.$getOpt(map, 'result'), Mapper.i.$getOpt(map, 'error'));

  @override Function get encoder => (CompileResponse v) => encode(v);
  dynamic encode(CompileResponse v) => toMap(v);
  Map<String, dynamic> toMap(CompileResponse c) => {'result': Mapper.i.$enc(c.result, 'result'), 'error': Mapper.i.$enc(c.error, 'error')};

  @override String stringify(CompileResponse self) => 'CompileResponse(result: ${Mapper.asString(self.result)}, error: ${Mapper.asString(self.error)})';
  @override int hash(CompileResponse self) => Mapper.hash(self.result) ^ Mapper.hash(self.error);
  @override bool equals(CompileResponse self, CompileResponse other) => Mapper.isEqual(self.result, other.result) && Mapper.isEqual(self.error, other.error);

  @override Function get typeFactory => (f) => f<CompileResponse>();
}

extension CompileResponseMapperExtension  on CompileResponse {
  String toJson() => Mapper.toJson(this);
  Map<String, dynamic> toMap() => Mapper.toMap(this);
  CompileResponseCopyWith<CompileResponse> get copyWith => CompileResponseCopyWith(this, $identity);
}

abstract class CompileResponseCopyWith<$R> {
  factory CompileResponseCopyWith(CompileResponse value, Then<CompileResponse, $R> then) = _CompileResponseCopyWithImpl<$R>;
  $R call({String? result, String? error});
  $R apply(CompileResponse Function(CompileResponse) transform);
}

class _CompileResponseCopyWithImpl<$R> extends BaseCopyWith<CompileResponse, $R> implements CompileResponseCopyWith<$R> {
  _CompileResponseCopyWithImpl(CompileResponse value, Then<CompileResponse, $R> then) : super(value, then);

  @override $R call({Object? result = $none, Object? error = $none}) => $then(CompileResponse(or(result, $value.result), or(error, $value.error)));
}

class AnalyzeRequestMapper extends BaseMapper<AnalyzeRequest> {
  AnalyzeRequestMapper._();

  @override Function get decoder => decode;
  AnalyzeRequest decode(dynamic v) => checked(v, (Map<String, dynamic> map) => fromMap(map));
  AnalyzeRequest fromMap(Map<String, dynamic> map) => AnalyzeRequest(Mapper.i.$get(map, 'sources'));

  @override Function get encoder => (AnalyzeRequest v) => encode(v);
  dynamic encode(AnalyzeRequest v) => toMap(v);
  Map<String, dynamic> toMap(AnalyzeRequest a) => {'sources': Mapper.i.$enc(a.sources, 'sources')};

  @override String stringify(AnalyzeRequest self) => 'AnalyzeRequest(sources: ${Mapper.asString(self.sources)})';
  @override int hash(AnalyzeRequest self) => Mapper.hash(self.sources);
  @override bool equals(AnalyzeRequest self, AnalyzeRequest other) => Mapper.isEqual(self.sources, other.sources);

  @override Function get typeFactory => (f) => f<AnalyzeRequest>();
}

extension AnalyzeRequestMapperExtension  on AnalyzeRequest {
  String toJson() => Mapper.toJson(this);
  Map<String, dynamic> toMap() => Mapper.toMap(this);
  AnalyzeRequestCopyWith<AnalyzeRequest> get copyWith => AnalyzeRequestCopyWith(this, $identity);
}

abstract class AnalyzeRequestCopyWith<$R> {
  factory AnalyzeRequestCopyWith(AnalyzeRequest value, Then<AnalyzeRequest, $R> then) = _AnalyzeRequestCopyWithImpl<$R>;
  $R call({Map<String, String>? sources});
  $R apply(AnalyzeRequest Function(AnalyzeRequest) transform);
}

class _AnalyzeRequestCopyWithImpl<$R> extends BaseCopyWith<AnalyzeRequest, $R> implements AnalyzeRequestCopyWith<$R> {
  _AnalyzeRequestCopyWithImpl(AnalyzeRequest value, Then<AnalyzeRequest, $R> then) : super(value, then);

  @override $R call({Map<String, String>? sources}) => $then(AnalyzeRequest(sources ?? $value.sources));
}

class FormatResponseMapper extends BaseMapper<FormatResponse> {
  FormatResponseMapper._();

  @override Function get decoder => decode;
  FormatResponse decode(dynamic v) => checked(v, (Map<String, dynamic> map) => fromMap(map));
  FormatResponse fromMap(Map<String, dynamic> map) => FormatResponse(Mapper.i.$get(map, 'newString'), Mapper.i.$get(map, 'newOffset'));

  @override Function get encoder => (FormatResponse v) => encode(v);
  dynamic encode(FormatResponse v) => toMap(v);
  Map<String, dynamic> toMap(FormatResponse f) => {'newString': Mapper.i.$enc(f.newString, 'newString'), 'newOffset': Mapper.i.$enc(f.newOffset, 'newOffset')};

  @override String stringify(FormatResponse self) => 'FormatResponse(newString: ${Mapper.asString(self.newString)}, newOffset: ${Mapper.asString(self.newOffset)})';
  @override int hash(FormatResponse self) => Mapper.hash(self.newString) ^ Mapper.hash(self.newOffset);
  @override bool equals(FormatResponse self, FormatResponse other) => Mapper.isEqual(self.newString, other.newString) && Mapper.isEqual(self.newOffset, other.newOffset);

  @override Function get typeFactory => (f) => f<FormatResponse>();
}

extension FormatResponseMapperExtension  on FormatResponse {
  String toJson() => Mapper.toJson(this);
  Map<String, dynamic> toMap() => Mapper.toMap(this);
  FormatResponseCopyWith<FormatResponse> get copyWith => FormatResponseCopyWith(this, $identity);
}

abstract class FormatResponseCopyWith<$R> {
  factory FormatResponseCopyWith(FormatResponse value, Then<FormatResponse, $R> then) = _FormatResponseCopyWithImpl<$R>;
  $R call({String? newString, int? newOffset});
  $R apply(FormatResponse Function(FormatResponse) transform);
}

class _FormatResponseCopyWithImpl<$R> extends BaseCopyWith<FormatResponse, $R> implements FormatResponseCopyWith<$R> {
  _FormatResponseCopyWithImpl(FormatResponse value, Then<FormatResponse, $R> then) : super(value, then);

  @override $R call({String? newString, int? newOffset}) => $then(FormatResponse(newString ?? $value.newString, newOffset ?? $value.newOffset));
}

class FormatRequestMapper extends BaseMapper<FormatRequest> {
  FormatRequestMapper._();

  @override Function get decoder => decode;
  FormatRequest decode(dynamic v) => checked(v, (Map<String, dynamic> map) => fromMap(map));
  FormatRequest fromMap(Map<String, dynamic> map) => FormatRequest(Mapper.i.$get(map, 'source'), Mapper.i.$get(map, 'offset'));

  @override Function get encoder => (FormatRequest v) => encode(v);
  dynamic encode(FormatRequest v) => toMap(v);
  Map<String, dynamic> toMap(FormatRequest f) => {'source': Mapper.i.$enc(f.source, 'source'), 'offset': Mapper.i.$enc(f.offset, 'offset')};

  @override String stringify(FormatRequest self) => 'FormatRequest(source: ${Mapper.asString(self.source)}, offset: ${Mapper.asString(self.offset)})';
  @override int hash(FormatRequest self) => Mapper.hash(self.source) ^ Mapper.hash(self.offset);
  @override bool equals(FormatRequest self, FormatRequest other) => Mapper.isEqual(self.source, other.source) && Mapper.isEqual(self.offset, other.offset);

  @override Function get typeFactory => (f) => f<FormatRequest>();
}

extension FormatRequestMapperExtension  on FormatRequest {
  String toJson() => Mapper.toJson(this);
  Map<String, dynamic> toMap() => Mapper.toMap(this);
  FormatRequestCopyWith<FormatRequest> get copyWith => FormatRequestCopyWith(this, $identity);
}

abstract class FormatRequestCopyWith<$R> {
  factory FormatRequestCopyWith(FormatRequest value, Then<FormatRequest, $R> then) = _FormatRequestCopyWithImpl<$R>;
  $R call({String? source, int? offset});
  $R apply(FormatRequest Function(FormatRequest) transform);
}

class _FormatRequestCopyWithImpl<$R> extends BaseCopyWith<FormatRequest, $R> implements FormatRequestCopyWith<$R> {
  _FormatRequestCopyWithImpl(FormatRequest value, Then<FormatRequest, $R> then) : super(value, then);

  @override $R call({String? source, int? offset}) => $then(FormatRequest(source ?? $value.source, offset ?? $value.offset));
}

class AnalyzeResponseMapper extends BaseMapper<AnalyzeResponse> {
  AnalyzeResponseMapper._();

  @override Function get decoder => decode;
  AnalyzeResponse decode(dynamic v) => checked(v, (Map<String, dynamic> map) => fromMap(map));
  AnalyzeResponse fromMap(Map<String, dynamic> map) => AnalyzeResponse(Mapper.i.$getOpt(map, 'issues') ?? const []);

  @override Function get encoder => (AnalyzeResponse v) => encode(v);
  dynamic encode(AnalyzeResponse v) => toMap(v);
  Map<String, dynamic> toMap(AnalyzeResponse a) => {'issues': Mapper.i.$enc(a.issues, 'issues')};

  @override String stringify(AnalyzeResponse self) => 'AnalyzeResponse(issues: ${Mapper.asString(self.issues)})';
  @override int hash(AnalyzeResponse self) => Mapper.hash(self.issues);
  @override bool equals(AnalyzeResponse self, AnalyzeResponse other) => Mapper.isEqual(self.issues, other.issues);

  @override Function get typeFactory => (f) => f<AnalyzeResponse>();
}

extension AnalyzeResponseMapperExtension  on AnalyzeResponse {
  String toJson() => Mapper.toJson(this);
  Map<String, dynamic> toMap() => Mapper.toMap(this);
  AnalyzeResponseCopyWith<AnalyzeResponse> get copyWith => AnalyzeResponseCopyWith(this, $identity);
}

abstract class AnalyzeResponseCopyWith<$R> {
  factory AnalyzeResponseCopyWith(AnalyzeResponse value, Then<AnalyzeResponse, $R> then) = _AnalyzeResponseCopyWithImpl<$R>;
  ListCopyWith<$R, Issue, IssueCopyWith<$R>> get issues;
  $R call({List<Issue>? issues});
  $R apply(AnalyzeResponse Function(AnalyzeResponse) transform);
}

class _AnalyzeResponseCopyWithImpl<$R> extends BaseCopyWith<AnalyzeResponse, $R> implements AnalyzeResponseCopyWith<$R> {
  _AnalyzeResponseCopyWithImpl(AnalyzeResponse value, Then<AnalyzeResponse, $R> then) : super(value, then);

  @override ListCopyWith<$R, Issue, IssueCopyWith<$R>> get issues => ListCopyWith($value.issues, (v, t) => IssueCopyWith(v, t), (v) => call(issues: v));
  @override $R call({List<Issue>? issues}) => $then(AnalyzeResponse(issues ?? $value.issues));
}

class IssueMapper extends BaseMapper<Issue> {
  IssueMapper._();

  @override Function get decoder => decode;
  Issue decode(dynamic v) => checked(v, (Map<String, dynamic> map) => fromMap(map));
  Issue fromMap(Map<String, dynamic> map) => Issue(kind: Mapper.i.$get(map, 'kind'), location: Mapper.i.$get(map, 'location'), message: Mapper.i.$get(map, 'message'), hasFixes: Mapper.i.$get(map, 'hasFixes'), sourceName: Mapper.i.$get(map, 'sourceName'), correction: Mapper.i.$getOpt(map, 'correction'), url: Mapper.i.$getOpt(map, 'url'));

  @override Function get encoder => (Issue v) => encode(v);
  dynamic encode(Issue v) => toMap(v);
  Map<String, dynamic> toMap(Issue i) => {'kind': Mapper.i.$enc(i.kind, 'kind'), 'location': Mapper.i.$enc(i.location, 'location'), 'message': Mapper.i.$enc(i.message, 'message'), 'hasFixes': Mapper.i.$enc(i.hasFixes, 'hasFixes'), 'sourceName': Mapper.i.$enc(i.sourceName, 'sourceName'), 'correction': Mapper.i.$enc(i.correction, 'correction'), 'url': Mapper.i.$enc(i.url, 'url')};

  @override String stringify(Issue self) => 'Issue(kind: ${Mapper.asString(self.kind)}, location: ${Mapper.asString(self.location)}, message: ${Mapper.asString(self.message)}, hasFixes: ${Mapper.asString(self.hasFixes)}, sourceName: ${Mapper.asString(self.sourceName)}, correction: ${Mapper.asString(self.correction)}, url: ${Mapper.asString(self.url)})';
  @override int hash(Issue self) => Mapper.hash(self.kind) ^ Mapper.hash(self.location) ^ Mapper.hash(self.message) ^ Mapper.hash(self.hasFixes) ^ Mapper.hash(self.sourceName) ^ Mapper.hash(self.correction) ^ Mapper.hash(self.url);
  @override bool equals(Issue self, Issue other) => Mapper.isEqual(self.kind, other.kind) && Mapper.isEqual(self.location, other.location) && Mapper.isEqual(self.message, other.message) && Mapper.isEqual(self.hasFixes, other.hasFixes) && Mapper.isEqual(self.sourceName, other.sourceName) && Mapper.isEqual(self.correction, other.correction) && Mapper.isEqual(self.url, other.url);

  @override Function get typeFactory => (f) => f<Issue>();
}

extension IssueMapperExtension  on Issue {
  String toJson() => Mapper.toJson(this);
  Map<String, dynamic> toMap() => Mapper.toMap(this);
  IssueCopyWith<Issue> get copyWith => IssueCopyWith(this, $identity);
}

abstract class IssueCopyWith<$R> {
  factory IssueCopyWith(Issue value, Then<Issue, $R> then) = _IssueCopyWithImpl<$R>;
  IssueLocationCopyWith<$R> get location;
  $R call({IssueKind? kind, IssueLocation? location, String? message, bool? hasFixes, String? sourceName, String? correction, String? url});
  $R apply(Issue Function(Issue) transform);
}

class _IssueCopyWithImpl<$R> extends BaseCopyWith<Issue, $R> implements IssueCopyWith<$R> {
  _IssueCopyWithImpl(Issue value, Then<Issue, $R> then) : super(value, then);

  @override IssueLocationCopyWith<$R> get location => IssueLocationCopyWith($value.location, (v) => call(location: v));
  @override $R call({IssueKind? kind, IssueLocation? location, String? message, bool? hasFixes, String? sourceName, Object? correction = $none, Object? url = $none}) => $then(Issue(kind: kind ?? $value.kind, location: location ?? $value.location, message: message ?? $value.message, hasFixes: hasFixes ?? $value.hasFixes, sourceName: sourceName ?? $value.sourceName, correction: or(correction, $value.correction), url: or(url, $value.url)));
}

class IssueLocationMapper extends BaseMapper<IssueLocation> {
  IssueLocationMapper._();

  @override Function get decoder => decode;
  IssueLocation decode(dynamic v) => checked(v, (Map<String, dynamic> map) => fromMap(map));
  IssueLocation fromMap(Map<String, dynamic> map) => IssueLocation(startLine: Mapper.i.$get(map, 'startLine'), endLine: Mapper.i.$get(map, 'endLine'), startColumn: Mapper.i.$get(map, 'startColumn'), endColumn: Mapper.i.$get(map, 'endColumn'));

  @override Function get encoder => (IssueLocation v) => encode(v);
  dynamic encode(IssueLocation v) => toMap(v);
  Map<String, dynamic> toMap(IssueLocation i) => {'startLine': Mapper.i.$enc(i.startLine, 'startLine'), 'endLine': Mapper.i.$enc(i.endLine, 'endLine'), 'startColumn': Mapper.i.$enc(i.startColumn, 'startColumn'), 'endColumn': Mapper.i.$enc(i.endColumn, 'endColumn')};

  @override String stringify(IssueLocation self) => 'IssueLocation(startLine: ${Mapper.asString(self.startLine)}, endLine: ${Mapper.asString(self.endLine)}, startColumn: ${Mapper.asString(self.startColumn)}, endColumn: ${Mapper.asString(self.endColumn)})';
  @override int hash(IssueLocation self) => Mapper.hash(self.startLine) ^ Mapper.hash(self.endLine) ^ Mapper.hash(self.startColumn) ^ Mapper.hash(self.endColumn);
  @override bool equals(IssueLocation self, IssueLocation other) => Mapper.isEqual(self.startLine, other.startLine) && Mapper.isEqual(self.endLine, other.endLine) && Mapper.isEqual(self.startColumn, other.startColumn) && Mapper.isEqual(self.endColumn, other.endColumn);

  @override Function get typeFactory => (f) => f<IssueLocation>();
}

extension IssueLocationMapperExtension  on IssueLocation {
  String toJson() => Mapper.toJson(this);
  Map<String, dynamic> toMap() => Mapper.toMap(this);
  IssueLocationCopyWith<IssueLocation> get copyWith => IssueLocationCopyWith(this, $identity);
}

abstract class IssueLocationCopyWith<$R> {
  factory IssueLocationCopyWith(IssueLocation value, Then<IssueLocation, $R> then) = _IssueLocationCopyWithImpl<$R>;
  $R call({int? startLine, int? endLine, int? startColumn, int? endColumn});
  $R apply(IssueLocation Function(IssueLocation) transform);
}

class _IssueLocationCopyWithImpl<$R> extends BaseCopyWith<IssueLocation, $R> implements IssueLocationCopyWith<$R> {
  _IssueLocationCopyWithImpl(IssueLocation value, Then<IssueLocation, $R> then) : super(value, then);

  @override $R call({int? startLine, int? endLine, int? startColumn, int? endColumn}) => $then(IssueLocation(startLine: startLine ?? $value.startLine, endLine: endLine ?? $value.endLine, startColumn: startColumn ?? $value.startColumn, endColumn: endColumn ?? $value.endColumn));
}

class DocumentResponseMapper extends BaseMapper<DocumentResponse> {
  DocumentResponseMapper._();

  @override Function get decoder => decode;
  DocumentResponse decode(dynamic v) => checked(v, (Map<String, dynamic> map) => fromMap(map));
  DocumentResponse fromMap(Map<String, dynamic> map) => DocumentResponse(Mapper.i.$get(map, 'info'), Mapper.i.$getOpt(map, 'error'));

  @override Function get encoder => (DocumentResponse v) => encode(v);
  dynamic encode(DocumentResponse v) => toMap(v);
  Map<String, dynamic> toMap(DocumentResponse d) => {'info': Mapper.i.$enc(d.info, 'info'), 'error': Mapper.i.$enc(d.error, 'error')};

  @override String stringify(DocumentResponse self) => 'DocumentResponse(info: ${Mapper.asString(self.info)}, error: ${Mapper.asString(self.error)})';
  @override int hash(DocumentResponse self) => Mapper.hash(self.info) ^ Mapper.hash(self.error);
  @override bool equals(DocumentResponse self, DocumentResponse other) => Mapper.isEqual(self.info, other.info) && Mapper.isEqual(self.error, other.error);

  @override Function get typeFactory => (f) => f<DocumentResponse>();
}

extension DocumentResponseMapperExtension  on DocumentResponse {
  String toJson() => Mapper.toJson(this);
  Map<String, dynamic> toMap() => Mapper.toMap(this);
  DocumentResponseCopyWith<DocumentResponse> get copyWith => DocumentResponseCopyWith(this, $identity);
}

abstract class DocumentResponseCopyWith<$R> {
  factory DocumentResponseCopyWith(DocumentResponse value, Then<DocumentResponse, $R> then) = _DocumentResponseCopyWithImpl<$R>;
  HoverInfoCopyWith<$R> get info;
  $R call({HoverInfo? info, String? error});
  $R apply(DocumentResponse Function(DocumentResponse) transform);
}

class _DocumentResponseCopyWithImpl<$R> extends BaseCopyWith<DocumentResponse, $R> implements DocumentResponseCopyWith<$R> {
  _DocumentResponseCopyWithImpl(DocumentResponse value, Then<DocumentResponse, $R> then) : super(value, then);

  @override HoverInfoCopyWith<$R> get info => HoverInfoCopyWith($value.info, (v) => call(info: v));
  @override $R call({HoverInfo? info, Object? error = $none}) => $then(DocumentResponse(info ?? $value.info, or(error, $value.error)));
}

class HoverInfoMapper extends BaseMapper<HoverInfo> {
  HoverInfoMapper._();

  @override Function get decoder => decode;
  HoverInfo decode(dynamic v) => checked(v, (Map<String, dynamic> map) => fromMap(map));
  HoverInfo fromMap(Map<String, dynamic> map) => HoverInfo(description: Mapper.i.$getOpt(map, 'description'), kind: Mapper.i.$getOpt(map, 'kind'), dartdoc: Mapper.i.$getOpt(map, 'dartdoc'), enclosingClassName: Mapper.i.$getOpt(map, 'enclosingClassName'), libraryName: Mapper.i.$getOpt(map, 'libraryName'), parameter: Mapper.i.$getOpt(map, 'parameter'), deprecated: Mapper.i.$getOpt(map, 'deprecated'), staticType: Mapper.i.$getOpt(map, 'staticType'), propagatedType: Mapper.i.$getOpt(map, 'propagatedType'));

  @override Function get encoder => (HoverInfo v) => encode(v);
  dynamic encode(HoverInfo v) => toMap(v);
  Map<String, dynamic> toMap(HoverInfo h) => {'description': Mapper.i.$enc(h.description, 'description'), 'kind': Mapper.i.$enc(h.kind, 'kind'), 'dartdoc': Mapper.i.$enc(h.dartdoc, 'dartdoc'), 'enclosingClassName': Mapper.i.$enc(h.enclosingClassName, 'enclosingClassName'), 'libraryName': Mapper.i.$enc(h.libraryName, 'libraryName'), 'parameter': Mapper.i.$enc(h.parameter, 'parameter'), 'deprecated': Mapper.i.$enc(h.deprecated, 'deprecated'), 'staticType': Mapper.i.$enc(h.staticType, 'staticType'), 'propagatedType': Mapper.i.$enc(h.propagatedType, 'propagatedType')};

  @override String stringify(HoverInfo self) => 'HoverInfo(description: ${Mapper.asString(self.description)}, kind: ${Mapper.asString(self.kind)}, dartdoc: ${Mapper.asString(self.dartdoc)}, enclosingClassName: ${Mapper.asString(self.enclosingClassName)}, libraryName: ${Mapper.asString(self.libraryName)}, parameter: ${Mapper.asString(self.parameter)}, deprecated: ${Mapper.asString(self.deprecated)}, staticType: ${Mapper.asString(self.staticType)}, propagatedType: ${Mapper.asString(self.propagatedType)})';
  @override int hash(HoverInfo self) => Mapper.hash(self.description) ^ Mapper.hash(self.kind) ^ Mapper.hash(self.dartdoc) ^ Mapper.hash(self.enclosingClassName) ^ Mapper.hash(self.libraryName) ^ Mapper.hash(self.parameter) ^ Mapper.hash(self.deprecated) ^ Mapper.hash(self.staticType) ^ Mapper.hash(self.propagatedType);
  @override bool equals(HoverInfo self, HoverInfo other) => Mapper.isEqual(self.description, other.description) && Mapper.isEqual(self.kind, other.kind) && Mapper.isEqual(self.dartdoc, other.dartdoc) && Mapper.isEqual(self.enclosingClassName, other.enclosingClassName) && Mapper.isEqual(self.libraryName, other.libraryName) && Mapper.isEqual(self.parameter, other.parameter) && Mapper.isEqual(self.deprecated, other.deprecated) && Mapper.isEqual(self.staticType, other.staticType) && Mapper.isEqual(self.propagatedType, other.propagatedType);

  @override Function get typeFactory => (f) => f<HoverInfo>();
}

extension HoverInfoMapperExtension  on HoverInfo {
  String toJson() => Mapper.toJson(this);
  Map<String, dynamic> toMap() => Mapper.toMap(this);
  HoverInfoCopyWith<HoverInfo> get copyWith => HoverInfoCopyWith(this, $identity);
}

abstract class HoverInfoCopyWith<$R> {
  factory HoverInfoCopyWith(HoverInfo value, Then<HoverInfo, $R> then) = _HoverInfoCopyWithImpl<$R>;
  $R call({String? description, String? kind, String? dartdoc, String? enclosingClassName, String? libraryName, String? parameter, bool? deprecated, String? staticType, String? propagatedType});
  $R apply(HoverInfo Function(HoverInfo) transform);
}

class _HoverInfoCopyWithImpl<$R> extends BaseCopyWith<HoverInfo, $R> implements HoverInfoCopyWith<$R> {
  _HoverInfoCopyWithImpl(HoverInfo value, Then<HoverInfo, $R> then) : super(value, then);

  @override $R call({Object? description = $none, Object? kind = $none, Object? dartdoc = $none, Object? enclosingClassName = $none, Object? libraryName = $none, Object? parameter = $none, Object? deprecated = $none, Object? staticType = $none, Object? propagatedType = $none}) => $then(HoverInfo(description: or(description, $value.description), kind: or(kind, $value.kind), dartdoc: or(dartdoc, $value.dartdoc), enclosingClassName: or(enclosingClassName, $value.enclosingClassName), libraryName: or(libraryName, $value.libraryName), parameter: or(parameter, $value.parameter), deprecated: or(deprecated, $value.deprecated), staticType: or(staticType, $value.staticType), propagatedType: or(propagatedType, $value.propagatedType)));
}

class DocumentRequestMapper extends BaseMapper<DocumentRequest> {
  DocumentRequestMapper._();

  @override Function get decoder => decode;
  DocumentRequest decode(dynamic v) => checked(v, (Map<String, dynamic> map) => fromMap(map));
  DocumentRequest fromMap(Map<String, dynamic> map) => DocumentRequest(Mapper.i.$get(map, 'sources'), Mapper.i.$get(map, 'name'), Mapper.i.$get(map, 'offset'));

  @override Function get encoder => (DocumentRequest v) => encode(v);
  dynamic encode(DocumentRequest v) => toMap(v);
  Map<String, dynamic> toMap(DocumentRequest d) => {'sources': Mapper.i.$enc(d.sources, 'sources'), 'name': Mapper.i.$enc(d.name, 'name'), 'offset': Mapper.i.$enc(d.offset, 'offset')};

  @override String stringify(DocumentRequest self) => 'DocumentRequest(sources: ${Mapper.asString(self.sources)}, name: ${Mapper.asString(self.name)}, offset: ${Mapper.asString(self.offset)})';
  @override int hash(DocumentRequest self) => Mapper.hash(self.sources) ^ Mapper.hash(self.name) ^ Mapper.hash(self.offset);
  @override bool equals(DocumentRequest self, DocumentRequest other) => Mapper.isEqual(self.sources, other.sources) && Mapper.isEqual(self.name, other.name) && Mapper.isEqual(self.offset, other.offset);

  @override Function get typeFactory => (f) => f<DocumentRequest>();
}

extension DocumentRequestMapperExtension  on DocumentRequest {
  String toJson() => Mapper.toJson(this);
  Map<String, dynamic> toMap() => Mapper.toMap(this);
  DocumentRequestCopyWith<DocumentRequest> get copyWith => DocumentRequestCopyWith(this, $identity);
}

abstract class DocumentRequestCopyWith<$R> {
  factory DocumentRequestCopyWith(DocumentRequest value, Then<DocumentRequest, $R> then) = _DocumentRequestCopyWithImpl<$R>;
  $R call({Map<String, String>? sources, String? name, int? offset});
  $R apply(DocumentRequest Function(DocumentRequest) transform);
}

class _DocumentRequestCopyWithImpl<$R> extends BaseCopyWith<DocumentRequest, $R> implements DocumentRequestCopyWith<$R> {
  _DocumentRequestCopyWithImpl(DocumentRequest value, Then<DocumentRequest, $R> then) : super(value, then);

  @override $R call({Map<String, String>? sources, String? name, int? offset}) => $then(DocumentRequest(sources ?? $value.sources, name ?? $value.name, offset ?? $value.offset));
}


// === GENERATED ENUM MAPPERS AND EXTENSIONS ===

class IssueKindMapper extends EnumMapper<IssueKind> {
  IssueKindMapper._();

  @override  IssueKind decode(dynamic value) {
    switch (value) {
      case 'error': return IssueKind.error;
      case 'warning': return IssueKind.warning;
      case 'info': return IssueKind.info;
      default: throw MapperException.unknownEnumValue(value);
    }
  }

  @override  dynamic encode(IssueKind value) {
    switch (value) {
      case IssueKind.error: return 'error';
      case IssueKind.warning: return 'warning';
      case IssueKind.info: return 'info';
    }
  }
}

extension IssueKindMapperExtension on IssueKind {
  dynamic toValue() => Mapper.toValue(this);
  @Deprecated('Use \'toValue\' instead')
  String toStringValue() => Mapper.toValue(this) as String;
}


// === GENERATED UTILITY CODE ===

class Mapper {
  Mapper._();

  static late MapperContainer i = MapperContainer(_mappers);

  static T fromValue<T>(dynamic value) => i.fromValue<T>(value);
  static T fromMap<T>(Map<String, dynamic> map) => i.fromMap<T>(map);
  static T fromIterable<T>(Iterable<dynamic> iterable) => i.fromIterable<T>(iterable);
  static T fromJson<T>(String json) => i.fromJson<T>(json);

  static dynamic toValue(dynamic value) => i.toValue(value);
  static Map<String, dynamic> toMap(dynamic object) => i.toMap(object);
  static Iterable<dynamic> toIterable(dynamic object) => i.toIterable(object);
  static String toJson(dynamic object) => i.toJson(object);

  static bool isEqual(dynamic value, Object? other) => i.isEqual(value, other);
  static int hash(dynamic value) => i.hash(value);
  static String asString(dynamic value) => i.asString(value);

  static void use<T>(BaseMapper<T> mapper) => i.use<T>(mapper);
  static BaseMapper<T>? unuse<T>() => i.unuse<T>();
  static void useAll(List<BaseMapper> mappers) => i.useAll(mappers);

  static BaseMapper<T>? get<T>([Type? type]) => i.get<T>(type);
  static List<BaseMapper> getAll() => i.getAll();
}

mixin Mappable implements MappableMixin {
  String toJson() => Mapper.toJson(this);
  Map<String, dynamic> toMap() => Mapper.toMap(this);

  @override
  String toString() {
    return _guard(() => Mapper.asString(this), super.toString);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (runtimeType == other.runtimeType &&
            _guard(() => Mapper.isEqual(this, other), () => super == other));
  }

  @override
  int get hashCode {
    return _guard(() => Mapper.hash(this), () => super.hashCode);
  }

  T _guard<T>(T Function() fn, T Function() fallback) {
    try {
      return fn();
    } on MapperException catch (e) {
      if (e.isUnsupportedOrUnallowed()) {
        return fallback();
      } else {
        rethrow;
      }
    }
  }
}
