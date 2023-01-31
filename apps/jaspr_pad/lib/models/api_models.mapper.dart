// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element

part of 'api_models.dart';

class CompileRequestMapper extends MapperBase<CompileRequest> {
  static MapperContainer container = MapperContainer(
    mappers: {CompileRequestMapper()},
  );

  @override
  CompileRequestMapperElement createElement(MapperContainer container) {
    return CompileRequestMapperElement._(this, container);
  }

  @override
  String get id => 'CompileRequest';

  static final fromMap = container.fromMap<CompileRequest>;
  static final fromJson = container.fromJson<CompileRequest>;
}

class CompileRequestMapperElement extends MapperElementBase<CompileRequest> {
  CompileRequestMapperElement._(super.mapper, super.container);

  @override
  Function get decoder => decode;
  CompileRequest decode(dynamic v) => checkedType(v, (Map<String, dynamic> map) => fromMap(map));
  CompileRequest fromMap(Map<String, dynamic> map) => CompileRequest(container.$get(map, 'sources'));

  @override
  Function get encoder => encode;
  dynamic encode(CompileRequest v) => toMap(v);
  Map<String, dynamic> toMap(CompileRequest c) => {'sources': container.$enc(c.sources, 'sources')};

  @override
  String stringify(CompileRequest self) => 'CompileRequest(sources: ${container.asString(self.sources)})';
  @override
  int hash(CompileRequest self) => container.hash(self.sources);
  @override
  bool equals(CompileRequest self, CompileRequest other) => container.isEqual(self.sources, other.sources);
}

mixin CompileRequestMappable {
  String toJson() => CompileRequestMapper.container.toJson(this as CompileRequest);
  Map<String, dynamic> toMap() => CompileRequestMapper.container.toMap(this as CompileRequest);
  CompileRequestCopyWith<CompileRequest, CompileRequest, CompileRequest> get copyWith =>
      _CompileRequestCopyWithImpl(this as CompileRequest, $identity, $identity);
  @override
  String toString() => CompileRequestMapper.container.asString(this);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (runtimeType == other.runtimeType && CompileRequestMapper.container.isEqual(this, other));
  @override
  int get hashCode => CompileRequestMapper.container.hash(this);
}

extension CompileRequestValueCopy<$R, $Out extends CompileRequest> on ObjectCopyWith<$R, CompileRequest, $Out> {
  CompileRequestCopyWith<$R, CompileRequest, $Out> get asCompileRequest =>
      base.as((v, t, t2) => _CompileRequestCopyWithImpl(v, t, t2));
}

typedef CompileRequestCopyWithBound = CompileRequest;

abstract class CompileRequestCopyWith<$R, $In extends CompileRequest, $Out extends CompileRequest>
    implements ObjectCopyWith<$R, $In, $Out> {
  CompileRequestCopyWith<$R2, $In, $Out2> chain<$R2, $Out2 extends CompileRequest>(
      Then<CompileRequest, $Out2> t, Then<$Out2, $R2> t2);
  MapCopyWith<$R, String, String, ObjectCopyWith<$R, String, String>> get sources;
  $R call({Map<String, String>? sources});
}

class _CompileRequestCopyWithImpl<$R, $Out extends CompileRequest> extends CopyWithBase<$R, CompileRequest, $Out>
    implements CompileRequestCopyWith<$R, CompileRequest, $Out> {
  _CompileRequestCopyWithImpl(super.value, super.then, super.then2);
  @override
  CompileRequestCopyWith<$R2, CompileRequest, $Out2> chain<$R2, $Out2 extends CompileRequest>(
          Then<CompileRequest, $Out2> t, Then<$Out2, $R2> t2) =>
      _CompileRequestCopyWithImpl($value, t, t2);

  @override
  MapCopyWith<$R, String, String, ObjectCopyWith<$R, String, String>> get sources =>
      MapCopyWith($value.sources, (v, t) => ObjectCopyWith(v, $identity, t), (v) => call(sources: v));
  @override
  $R call({Map<String, String>? sources}) => $then(CompileRequest(sources ?? $value.sources));
}

class CompileResponseMapper extends MapperBase<CompileResponse> {
  static MapperContainer container = MapperContainer(
    mappers: {CompileResponseMapper()},
  );

  @override
  CompileResponseMapperElement createElement(MapperContainer container) {
    return CompileResponseMapperElement._(this, container);
  }

  @override
  String get id => 'CompileResponse';

  static final fromMap = container.fromMap<CompileResponse>;
  static final fromJson = container.fromJson<CompileResponse>;
}

class CompileResponseMapperElement extends MapperElementBase<CompileResponse> {
  CompileResponseMapperElement._(super.mapper, super.container);

  @override
  Function get decoder => decode;
  CompileResponse decode(dynamic v) => checkedType(v, (Map<String, dynamic> map) => fromMap(map));
  CompileResponse fromMap(Map<String, dynamic> map) =>
      CompileResponse(container.$getOpt(map, 'result'), container.$getOpt(map, 'error'));

  @override
  Function get encoder => encode;
  dynamic encode(CompileResponse v) => toMap(v);
  Map<String, dynamic> toMap(CompileResponse c) =>
      {'result': container.$enc(c.result, 'result'), 'error': container.$enc(c.error, 'error')};

  @override
  String stringify(CompileResponse self) =>
      'CompileResponse(result: ${container.asString(self.result)}, error: ${container.asString(self.error)})';
  @override
  int hash(CompileResponse self) => container.hash(self.result) ^ container.hash(self.error);
  @override
  bool equals(CompileResponse self, CompileResponse other) =>
      container.isEqual(self.result, other.result) && container.isEqual(self.error, other.error);
}

mixin CompileResponseMappable {
  String toJson() => CompileResponseMapper.container.toJson(this as CompileResponse);
  Map<String, dynamic> toMap() => CompileResponseMapper.container.toMap(this as CompileResponse);
  CompileResponseCopyWith<CompileResponse, CompileResponse, CompileResponse> get copyWith =>
      _CompileResponseCopyWithImpl(this as CompileResponse, $identity, $identity);
  @override
  String toString() => CompileResponseMapper.container.asString(this);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (runtimeType == other.runtimeType && CompileResponseMapper.container.isEqual(this, other));
  @override
  int get hashCode => CompileResponseMapper.container.hash(this);
}

extension CompileResponseValueCopy<$R, $Out extends CompileResponse> on ObjectCopyWith<$R, CompileResponse, $Out> {
  CompileResponseCopyWith<$R, CompileResponse, $Out> get asCompileResponse =>
      base.as((v, t, t2) => _CompileResponseCopyWithImpl(v, t, t2));
}

typedef CompileResponseCopyWithBound = CompileResponse;

abstract class CompileResponseCopyWith<$R, $In extends CompileResponse, $Out extends CompileResponse>
    implements ObjectCopyWith<$R, $In, $Out> {
  CompileResponseCopyWith<$R2, $In, $Out2> chain<$R2, $Out2 extends CompileResponse>(
      Then<CompileResponse, $Out2> t, Then<$Out2, $R2> t2);
  $R call({String? result, String? error});
}

class _CompileResponseCopyWithImpl<$R, $Out extends CompileResponse> extends CopyWithBase<$R, CompileResponse, $Out>
    implements CompileResponseCopyWith<$R, CompileResponse, $Out> {
  _CompileResponseCopyWithImpl(super.value, super.then, super.then2);
  @override
  CompileResponseCopyWith<$R2, CompileResponse, $Out2> chain<$R2, $Out2 extends CompileResponse>(
          Then<CompileResponse, $Out2> t, Then<$Out2, $R2> t2) =>
      _CompileResponseCopyWithImpl($value, t, t2);

  @override
  $R call({Object? result = $none, Object? error = $none}) =>
      $then(CompileResponse(or(result, $value.result), or(error, $value.error)));
}

class AnalyzeRequestMapper extends MapperBase<AnalyzeRequest> {
  static MapperContainer container = MapperContainer(
    mappers: {AnalyzeRequestMapper()},
  );

  @override
  AnalyzeRequestMapperElement createElement(MapperContainer container) {
    return AnalyzeRequestMapperElement._(this, container);
  }

  @override
  String get id => 'AnalyzeRequest';

  static final fromMap = container.fromMap<AnalyzeRequest>;
  static final fromJson = container.fromJson<AnalyzeRequest>;
}

class AnalyzeRequestMapperElement extends MapperElementBase<AnalyzeRequest> {
  AnalyzeRequestMapperElement._(super.mapper, super.container);

  @override
  Function get decoder => decode;
  AnalyzeRequest decode(dynamic v) => checkedType(v, (Map<String, dynamic> map) => fromMap(map));
  AnalyzeRequest fromMap(Map<String, dynamic> map) => AnalyzeRequest(container.$get(map, 'sources'));

  @override
  Function get encoder => encode;
  dynamic encode(AnalyzeRequest v) => toMap(v);
  Map<String, dynamic> toMap(AnalyzeRequest a) => {'sources': container.$enc(a.sources, 'sources')};

  @override
  String stringify(AnalyzeRequest self) => 'AnalyzeRequest(sources: ${container.asString(self.sources)})';
  @override
  int hash(AnalyzeRequest self) => container.hash(self.sources);
  @override
  bool equals(AnalyzeRequest self, AnalyzeRequest other) => container.isEqual(self.sources, other.sources);
}

mixin AnalyzeRequestMappable {
  String toJson() => AnalyzeRequestMapper.container.toJson(this as AnalyzeRequest);
  Map<String, dynamic> toMap() => AnalyzeRequestMapper.container.toMap(this as AnalyzeRequest);
  AnalyzeRequestCopyWith<AnalyzeRequest, AnalyzeRequest, AnalyzeRequest> get copyWith =>
      _AnalyzeRequestCopyWithImpl(this as AnalyzeRequest, $identity, $identity);
  @override
  String toString() => AnalyzeRequestMapper.container.asString(this);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (runtimeType == other.runtimeType && AnalyzeRequestMapper.container.isEqual(this, other));
  @override
  int get hashCode => AnalyzeRequestMapper.container.hash(this);
}

extension AnalyzeRequestValueCopy<$R, $Out extends AnalyzeRequest> on ObjectCopyWith<$R, AnalyzeRequest, $Out> {
  AnalyzeRequestCopyWith<$R, AnalyzeRequest, $Out> get asAnalyzeRequest =>
      base.as((v, t, t2) => _AnalyzeRequestCopyWithImpl(v, t, t2));
}

typedef AnalyzeRequestCopyWithBound = AnalyzeRequest;

abstract class AnalyzeRequestCopyWith<$R, $In extends AnalyzeRequest, $Out extends AnalyzeRequest>
    implements ObjectCopyWith<$R, $In, $Out> {
  AnalyzeRequestCopyWith<$R2, $In, $Out2> chain<$R2, $Out2 extends AnalyzeRequest>(
      Then<AnalyzeRequest, $Out2> t, Then<$Out2, $R2> t2);
  MapCopyWith<$R, String, String, ObjectCopyWith<$R, String, String>> get sources;
  $R call({Map<String, String>? sources});
}

class _AnalyzeRequestCopyWithImpl<$R, $Out extends AnalyzeRequest> extends CopyWithBase<$R, AnalyzeRequest, $Out>
    implements AnalyzeRequestCopyWith<$R, AnalyzeRequest, $Out> {
  _AnalyzeRequestCopyWithImpl(super.value, super.then, super.then2);
  @override
  AnalyzeRequestCopyWith<$R2, AnalyzeRequest, $Out2> chain<$R2, $Out2 extends AnalyzeRequest>(
          Then<AnalyzeRequest, $Out2> t, Then<$Out2, $R2> t2) =>
      _AnalyzeRequestCopyWithImpl($value, t, t2);

  @override
  MapCopyWith<$R, String, String, ObjectCopyWith<$R, String, String>> get sources =>
      MapCopyWith($value.sources, (v, t) => ObjectCopyWith(v, $identity, t), (v) => call(sources: v));
  @override
  $R call({Map<String, String>? sources}) => $then(AnalyzeRequest(sources ?? $value.sources));
}

class FormatResponseMapper extends MapperBase<FormatResponse> {
  static MapperContainer container = MapperContainer(
    mappers: {FormatResponseMapper()},
  );

  @override
  FormatResponseMapperElement createElement(MapperContainer container) {
    return FormatResponseMapperElement._(this, container);
  }

  @override
  String get id => 'FormatResponse';

  static final fromMap = container.fromMap<FormatResponse>;
  static final fromJson = container.fromJson<FormatResponse>;
}

class FormatResponseMapperElement extends MapperElementBase<FormatResponse> {
  FormatResponseMapperElement._(super.mapper, super.container);

  @override
  Function get decoder => decode;
  FormatResponse decode(dynamic v) => checkedType(v, (Map<String, dynamic> map) => fromMap(map));
  FormatResponse fromMap(Map<String, dynamic> map) =>
      FormatResponse(container.$get(map, 'newString'), container.$get(map, 'newOffset'));

  @override
  Function get encoder => encode;
  dynamic encode(FormatResponse v) => toMap(v);
  Map<String, dynamic> toMap(FormatResponse f) =>
      {'newString': container.$enc(f.newString, 'newString'), 'newOffset': container.$enc(f.newOffset, 'newOffset')};

  @override
  String stringify(FormatResponse self) =>
      'FormatResponse(newString: ${container.asString(self.newString)}, newOffset: ${container.asString(self.newOffset)})';
  @override
  int hash(FormatResponse self) => container.hash(self.newString) ^ container.hash(self.newOffset);
  @override
  bool equals(FormatResponse self, FormatResponse other) =>
      container.isEqual(self.newString, other.newString) && container.isEqual(self.newOffset, other.newOffset);
}

mixin FormatResponseMappable {
  String toJson() => FormatResponseMapper.container.toJson(this as FormatResponse);
  Map<String, dynamic> toMap() => FormatResponseMapper.container.toMap(this as FormatResponse);
  FormatResponseCopyWith<FormatResponse, FormatResponse, FormatResponse> get copyWith =>
      _FormatResponseCopyWithImpl(this as FormatResponse, $identity, $identity);
  @override
  String toString() => FormatResponseMapper.container.asString(this);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (runtimeType == other.runtimeType && FormatResponseMapper.container.isEqual(this, other));
  @override
  int get hashCode => FormatResponseMapper.container.hash(this);
}

extension FormatResponseValueCopy<$R, $Out extends FormatResponse> on ObjectCopyWith<$R, FormatResponse, $Out> {
  FormatResponseCopyWith<$R, FormatResponse, $Out> get asFormatResponse =>
      base.as((v, t, t2) => _FormatResponseCopyWithImpl(v, t, t2));
}

typedef FormatResponseCopyWithBound = FormatResponse;

abstract class FormatResponseCopyWith<$R, $In extends FormatResponse, $Out extends FormatResponse>
    implements ObjectCopyWith<$R, $In, $Out> {
  FormatResponseCopyWith<$R2, $In, $Out2> chain<$R2, $Out2 extends FormatResponse>(
      Then<FormatResponse, $Out2> t, Then<$Out2, $R2> t2);
  $R call({String? newString, int? newOffset});
}

class _FormatResponseCopyWithImpl<$R, $Out extends FormatResponse> extends CopyWithBase<$R, FormatResponse, $Out>
    implements FormatResponseCopyWith<$R, FormatResponse, $Out> {
  _FormatResponseCopyWithImpl(super.value, super.then, super.then2);
  @override
  FormatResponseCopyWith<$R2, FormatResponse, $Out2> chain<$R2, $Out2 extends FormatResponse>(
          Then<FormatResponse, $Out2> t, Then<$Out2, $R2> t2) =>
      _FormatResponseCopyWithImpl($value, t, t2);

  @override
  $R call({String? newString, int? newOffset}) =>
      $then(FormatResponse(newString ?? $value.newString, newOffset ?? $value.newOffset));
}

class FormatRequestMapper extends MapperBase<FormatRequest> {
  static MapperContainer container = MapperContainer(
    mappers: {FormatRequestMapper()},
  );

  @override
  FormatRequestMapperElement createElement(MapperContainer container) {
    return FormatRequestMapperElement._(this, container);
  }

  @override
  String get id => 'FormatRequest';

  static final fromMap = container.fromMap<FormatRequest>;
  static final fromJson = container.fromJson<FormatRequest>;
}

class FormatRequestMapperElement extends MapperElementBase<FormatRequest> {
  FormatRequestMapperElement._(super.mapper, super.container);

  @override
  Function get decoder => decode;
  FormatRequest decode(dynamic v) => checkedType(v, (Map<String, dynamic> map) => fromMap(map));
  FormatRequest fromMap(Map<String, dynamic> map) =>
      FormatRequest(container.$get(map, 'source'), container.$get(map, 'offset'));

  @override
  Function get encoder => encode;
  dynamic encode(FormatRequest v) => toMap(v);
  Map<String, dynamic> toMap(FormatRequest f) =>
      {'source': container.$enc(f.source, 'source'), 'offset': container.$enc(f.offset, 'offset')};

  @override
  String stringify(FormatRequest self) =>
      'FormatRequest(source: ${container.asString(self.source)}, offset: ${container.asString(self.offset)})';
  @override
  int hash(FormatRequest self) => container.hash(self.source) ^ container.hash(self.offset);
  @override
  bool equals(FormatRequest self, FormatRequest other) =>
      container.isEqual(self.source, other.source) && container.isEqual(self.offset, other.offset);
}

mixin FormatRequestMappable {
  String toJson() => FormatRequestMapper.container.toJson(this as FormatRequest);
  Map<String, dynamic> toMap() => FormatRequestMapper.container.toMap(this as FormatRequest);
  FormatRequestCopyWith<FormatRequest, FormatRequest, FormatRequest> get copyWith =>
      _FormatRequestCopyWithImpl(this as FormatRequest, $identity, $identity);
  @override
  String toString() => FormatRequestMapper.container.asString(this);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (runtimeType == other.runtimeType && FormatRequestMapper.container.isEqual(this, other));
  @override
  int get hashCode => FormatRequestMapper.container.hash(this);
}

extension FormatRequestValueCopy<$R, $Out extends FormatRequest> on ObjectCopyWith<$R, FormatRequest, $Out> {
  FormatRequestCopyWith<$R, FormatRequest, $Out> get asFormatRequest =>
      base.as((v, t, t2) => _FormatRequestCopyWithImpl(v, t, t2));
}

typedef FormatRequestCopyWithBound = FormatRequest;

abstract class FormatRequestCopyWith<$R, $In extends FormatRequest, $Out extends FormatRequest>
    implements ObjectCopyWith<$R, $In, $Out> {
  FormatRequestCopyWith<$R2, $In, $Out2> chain<$R2, $Out2 extends FormatRequest>(
      Then<FormatRequest, $Out2> t, Then<$Out2, $R2> t2);
  $R call({String? source, int? offset});
}

class _FormatRequestCopyWithImpl<$R, $Out extends FormatRequest> extends CopyWithBase<$R, FormatRequest, $Out>
    implements FormatRequestCopyWith<$R, FormatRequest, $Out> {
  _FormatRequestCopyWithImpl(super.value, super.then, super.then2);
  @override
  FormatRequestCopyWith<$R2, FormatRequest, $Out2> chain<$R2, $Out2 extends FormatRequest>(
          Then<FormatRequest, $Out2> t, Then<$Out2, $R2> t2) =>
      _FormatRequestCopyWithImpl($value, t, t2);

  @override
  $R call({String? source, int? offset}) => $then(FormatRequest(source ?? $value.source, offset ?? $value.offset));
}

class AnalyzeResponseMapper extends MapperBase<AnalyzeResponse> {
  static MapperContainer container = MapperContainer(
    mappers: {AnalyzeResponseMapper()},
  )..linkAll({IssueMapper.container});

  @override
  AnalyzeResponseMapperElement createElement(MapperContainer container) {
    return AnalyzeResponseMapperElement._(this, container);
  }

  @override
  String get id => 'AnalyzeResponse';

  static final fromMap = container.fromMap<AnalyzeResponse>;
  static final fromJson = container.fromJson<AnalyzeResponse>;
}

class AnalyzeResponseMapperElement extends MapperElementBase<AnalyzeResponse> {
  AnalyzeResponseMapperElement._(super.mapper, super.container);

  @override
  Function get decoder => decode;
  AnalyzeResponse decode(dynamic v) => checkedType(v, (Map<String, dynamic> map) => fromMap(map));
  AnalyzeResponse fromMap(Map<String, dynamic> map) => AnalyzeResponse(container.$getOpt(map, 'issues') ?? const []);

  @override
  Function get encoder => encode;
  dynamic encode(AnalyzeResponse v) => toMap(v);
  Map<String, dynamic> toMap(AnalyzeResponse a) => {'issues': container.$enc(a.issues, 'issues')};

  @override
  String stringify(AnalyzeResponse self) => 'AnalyzeResponse(issues: ${container.asString(self.issues)})';
  @override
  int hash(AnalyzeResponse self) => container.hash(self.issues);
  @override
  bool equals(AnalyzeResponse self, AnalyzeResponse other) => container.isEqual(self.issues, other.issues);
}

mixin AnalyzeResponseMappable {
  String toJson() => AnalyzeResponseMapper.container.toJson(this as AnalyzeResponse);
  Map<String, dynamic> toMap() => AnalyzeResponseMapper.container.toMap(this as AnalyzeResponse);
  AnalyzeResponseCopyWith<AnalyzeResponse, AnalyzeResponse, AnalyzeResponse> get copyWith =>
      _AnalyzeResponseCopyWithImpl(this as AnalyzeResponse, $identity, $identity);
  @override
  String toString() => AnalyzeResponseMapper.container.asString(this);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (runtimeType == other.runtimeType && AnalyzeResponseMapper.container.isEqual(this, other));
  @override
  int get hashCode => AnalyzeResponseMapper.container.hash(this);
}

extension AnalyzeResponseValueCopy<$R, $Out extends AnalyzeResponse> on ObjectCopyWith<$R, AnalyzeResponse, $Out> {
  AnalyzeResponseCopyWith<$R, AnalyzeResponse, $Out> get asAnalyzeResponse =>
      base.as((v, t, t2) => _AnalyzeResponseCopyWithImpl(v, t, t2));
}

typedef AnalyzeResponseCopyWithBound = AnalyzeResponse;

abstract class AnalyzeResponseCopyWith<$R, $In extends AnalyzeResponse, $Out extends AnalyzeResponse>
    implements ObjectCopyWith<$R, $In, $Out> {
  AnalyzeResponseCopyWith<$R2, $In, $Out2> chain<$R2, $Out2 extends AnalyzeResponse>(
      Then<AnalyzeResponse, $Out2> t, Then<$Out2, $R2> t2);
  ListCopyWith<$R, Issue, IssueCopyWith<$R, Issue, Issue>> get issues;
  $R call({List<Issue>? issues});
}

class _AnalyzeResponseCopyWithImpl<$R, $Out extends AnalyzeResponse> extends CopyWithBase<$R, AnalyzeResponse, $Out>
    implements AnalyzeResponseCopyWith<$R, AnalyzeResponse, $Out> {
  _AnalyzeResponseCopyWithImpl(super.value, super.then, super.then2);
  @override
  AnalyzeResponseCopyWith<$R2, AnalyzeResponse, $Out2> chain<$R2, $Out2 extends AnalyzeResponse>(
          Then<AnalyzeResponse, $Out2> t, Then<$Out2, $R2> t2) =>
      _AnalyzeResponseCopyWithImpl($value, t, t2);

  @override
  ListCopyWith<$R, Issue, IssueCopyWith<$R, Issue, Issue>> get issues =>
      ListCopyWith($value.issues, (v, t) => v.copyWith.chain<$R, Issue>($identity, t), (v) => call(issues: v));
  @override
  $R call({List<Issue>? issues}) => $then(AnalyzeResponse(issues ?? $value.issues));
}

class IssueMapper extends MapperBase<Issue> {
  static MapperContainer container = MapperContainer(
    mappers: {IssueMapper()},
  )..linkAll({IssueKindMapper.container, IssueLocationMapper.container});

  @override
  IssueMapperElement createElement(MapperContainer container) {
    return IssueMapperElement._(this, container);
  }

  @override
  String get id => 'Issue';

  static final fromMap = container.fromMap<Issue>;
  static final fromJson = container.fromJson<Issue>;
}

class IssueMapperElement extends MapperElementBase<Issue> {
  IssueMapperElement._(super.mapper, super.container);

  @override
  Function get decoder => decode;
  Issue decode(dynamic v) => checkedType(v, (Map<String, dynamic> map) => fromMap(map));
  Issue fromMap(Map<String, dynamic> map) => Issue(
      kind: container.$get(map, 'kind'),
      location: container.$get(map, 'location'),
      message: container.$get(map, 'message'),
      hasFixes: container.$get(map, 'hasFixes'),
      sourceName: container.$get(map, 'sourceName'),
      correction: container.$getOpt(map, 'correction'),
      url: container.$getOpt(map, 'url'));

  @override
  Function get encoder => encode;
  dynamic encode(Issue v) => toMap(v);
  Map<String, dynamic> toMap(Issue i) => {
        'kind': container.$enc(i.kind, 'kind'),
        'location': container.$enc(i.location, 'location'),
        'message': container.$enc(i.message, 'message'),
        'hasFixes': container.$enc(i.hasFixes, 'hasFixes'),
        'sourceName': container.$enc(i.sourceName, 'sourceName'),
        'correction': container.$enc(i.correction, 'correction'),
        'url': container.$enc(i.url, 'url')
      };

  @override
  String stringify(Issue self) =>
      'Issue(kind: ${container.asString(self.kind)}, location: ${container.asString(self.location)}, message: ${container.asString(self.message)}, hasFixes: ${container.asString(self.hasFixes)}, sourceName: ${container.asString(self.sourceName)}, correction: ${container.asString(self.correction)}, url: ${container.asString(self.url)})';
  @override
  int hash(Issue self) =>
      container.hash(self.kind) ^
      container.hash(self.location) ^
      container.hash(self.message) ^
      container.hash(self.hasFixes) ^
      container.hash(self.sourceName) ^
      container.hash(self.correction) ^
      container.hash(self.url);
  @override
  bool equals(Issue self, Issue other) =>
      container.isEqual(self.kind, other.kind) &&
      container.isEqual(self.location, other.location) &&
      container.isEqual(self.message, other.message) &&
      container.isEqual(self.hasFixes, other.hasFixes) &&
      container.isEqual(self.sourceName, other.sourceName) &&
      container.isEqual(self.correction, other.correction) &&
      container.isEqual(self.url, other.url);
}

mixin IssueMappable {
  String toJson() => IssueMapper.container.toJson(this as Issue);
  Map<String, dynamic> toMap() => IssueMapper.container.toMap(this as Issue);
  IssueCopyWith<Issue, Issue, Issue> get copyWith => _IssueCopyWithImpl(this as Issue, $identity, $identity);
  @override
  String toString() => IssueMapper.container.asString(this);
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (runtimeType == other.runtimeType && IssueMapper.container.isEqual(this, other));
  @override
  int get hashCode => IssueMapper.container.hash(this);
}

extension IssueValueCopy<$R, $Out extends Issue> on ObjectCopyWith<$R, Issue, $Out> {
  IssueCopyWith<$R, Issue, $Out> get asIssue => base.as((v, t, t2) => _IssueCopyWithImpl(v, t, t2));
}

typedef IssueCopyWithBound = Issue;

abstract class IssueCopyWith<$R, $In extends Issue, $Out extends Issue> implements ObjectCopyWith<$R, $In, $Out> {
  IssueCopyWith<$R2, $In, $Out2> chain<$R2, $Out2 extends Issue>(Then<Issue, $Out2> t, Then<$Out2, $R2> t2);
  IssueLocationCopyWith<$R, IssueLocation, IssueLocation> get location;
  $R call(
      {IssueKind? kind,
      IssueLocation? location,
      String? message,
      bool? hasFixes,
      String? sourceName,
      String? correction,
      String? url});
}

class _IssueCopyWithImpl<$R, $Out extends Issue> extends CopyWithBase<$R, Issue, $Out>
    implements IssueCopyWith<$R, Issue, $Out> {
  _IssueCopyWithImpl(super.value, super.then, super.then2);
  @override
  IssueCopyWith<$R2, Issue, $Out2> chain<$R2, $Out2 extends Issue>(Then<Issue, $Out2> t, Then<$Out2, $R2> t2) =>
      _IssueCopyWithImpl($value, t, t2);

  @override
  IssueLocationCopyWith<$R, IssueLocation, IssueLocation> get location =>
      $value.location.copyWith.chain($identity, (v) => call(location: v));
  @override
  $R call(
          {IssueKind? kind,
          IssueLocation? location,
          String? message,
          bool? hasFixes,
          String? sourceName,
          Object? correction = $none,
          Object? url = $none}) =>
      $then(Issue(
          kind: kind ?? $value.kind,
          location: location ?? $value.location,
          message: message ?? $value.message,
          hasFixes: hasFixes ?? $value.hasFixes,
          sourceName: sourceName ?? $value.sourceName,
          correction: or(correction, $value.correction),
          url: or(url, $value.url)));
}

class IssueLocationMapper extends MapperBase<IssueLocation> {
  static MapperContainer container = MapperContainer(
    mappers: {IssueLocationMapper()},
  );

  @override
  IssueLocationMapperElement createElement(MapperContainer container) {
    return IssueLocationMapperElement._(this, container);
  }

  @override
  String get id => 'IssueLocation';

  static final fromMap = container.fromMap<IssueLocation>;
  static final fromJson = container.fromJson<IssueLocation>;
}

class IssueLocationMapperElement extends MapperElementBase<IssueLocation> {
  IssueLocationMapperElement._(super.mapper, super.container);

  @override
  Function get decoder => decode;
  IssueLocation decode(dynamic v) => checkedType(v, (Map<String, dynamic> map) => fromMap(map));
  IssueLocation fromMap(Map<String, dynamic> map) => IssueLocation(
      startLine: container.$get(map, 'startLine'),
      endLine: container.$get(map, 'endLine'),
      startColumn: container.$get(map, 'startColumn'),
      endColumn: container.$get(map, 'endColumn'));

  @override
  Function get encoder => encode;
  dynamic encode(IssueLocation v) => toMap(v);
  Map<String, dynamic> toMap(IssueLocation i) => {
        'startLine': container.$enc(i.startLine, 'startLine'),
        'endLine': container.$enc(i.endLine, 'endLine'),
        'startColumn': container.$enc(i.startColumn, 'startColumn'),
        'endColumn': container.$enc(i.endColumn, 'endColumn')
      };

  @override
  String stringify(IssueLocation self) =>
      'IssueLocation(startLine: ${container.asString(self.startLine)}, endLine: ${container.asString(self.endLine)}, startColumn: ${container.asString(self.startColumn)}, endColumn: ${container.asString(self.endColumn)})';
  @override
  int hash(IssueLocation self) =>
      container.hash(self.startLine) ^
      container.hash(self.endLine) ^
      container.hash(self.startColumn) ^
      container.hash(self.endColumn);
  @override
  bool equals(IssueLocation self, IssueLocation other) =>
      container.isEqual(self.startLine, other.startLine) &&
      container.isEqual(self.endLine, other.endLine) &&
      container.isEqual(self.startColumn, other.startColumn) &&
      container.isEqual(self.endColumn, other.endColumn);
}

mixin IssueLocationMappable {
  String toJson() => IssueLocationMapper.container.toJson(this as IssueLocation);
  Map<String, dynamic> toMap() => IssueLocationMapper.container.toMap(this as IssueLocation);
  IssueLocationCopyWith<IssueLocation, IssueLocation, IssueLocation> get copyWith =>
      _IssueLocationCopyWithImpl(this as IssueLocation, $identity, $identity);
  @override
  String toString() => IssueLocationMapper.container.asString(this);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (runtimeType == other.runtimeType && IssueLocationMapper.container.isEqual(this, other));
  @override
  int get hashCode => IssueLocationMapper.container.hash(this);
}

extension IssueLocationValueCopy<$R, $Out extends IssueLocation> on ObjectCopyWith<$R, IssueLocation, $Out> {
  IssueLocationCopyWith<$R, IssueLocation, $Out> get asIssueLocation =>
      base.as((v, t, t2) => _IssueLocationCopyWithImpl(v, t, t2));
}

typedef IssueLocationCopyWithBound = IssueLocation;

abstract class IssueLocationCopyWith<$R, $In extends IssueLocation, $Out extends IssueLocation>
    implements ObjectCopyWith<$R, $In, $Out> {
  IssueLocationCopyWith<$R2, $In, $Out2> chain<$R2, $Out2 extends IssueLocation>(
      Then<IssueLocation, $Out2> t, Then<$Out2, $R2> t2);
  $R call({int? startLine, int? endLine, int? startColumn, int? endColumn});
}

class _IssueLocationCopyWithImpl<$R, $Out extends IssueLocation> extends CopyWithBase<$R, IssueLocation, $Out>
    implements IssueLocationCopyWith<$R, IssueLocation, $Out> {
  _IssueLocationCopyWithImpl(super.value, super.then, super.then2);
  @override
  IssueLocationCopyWith<$R2, IssueLocation, $Out2> chain<$R2, $Out2 extends IssueLocation>(
          Then<IssueLocation, $Out2> t, Then<$Out2, $R2> t2) =>
      _IssueLocationCopyWithImpl($value, t, t2);

  @override
  $R call({int? startLine, int? endLine, int? startColumn, int? endColumn}) => $then(IssueLocation(
      startLine: startLine ?? $value.startLine,
      endLine: endLine ?? $value.endLine,
      startColumn: startColumn ?? $value.startColumn,
      endColumn: endColumn ?? $value.endColumn));
}

class DocumentResponseMapper extends MapperBase<DocumentResponse> {
  static MapperContainer container = MapperContainer(
    mappers: {DocumentResponseMapper()},
  )..linkAll({HoverInfoMapper.container});

  @override
  DocumentResponseMapperElement createElement(MapperContainer container) {
    return DocumentResponseMapperElement._(this, container);
  }

  @override
  String get id => 'DocumentResponse';

  static final fromMap = container.fromMap<DocumentResponse>;
  static final fromJson = container.fromJson<DocumentResponse>;
}

class DocumentResponseMapperElement extends MapperElementBase<DocumentResponse> {
  DocumentResponseMapperElement._(super.mapper, super.container);

  @override
  Function get decoder => decode;
  DocumentResponse decode(dynamic v) => checkedType(v, (Map<String, dynamic> map) => fromMap(map));
  DocumentResponse fromMap(Map<String, dynamic> map) =>
      DocumentResponse(container.$get(map, 'info'), container.$getOpt(map, 'error'));

  @override
  Function get encoder => encode;
  dynamic encode(DocumentResponse v) => toMap(v);
  Map<String, dynamic> toMap(DocumentResponse d) =>
      {'info': container.$enc(d.info, 'info'), 'error': container.$enc(d.error, 'error')};

  @override
  String stringify(DocumentResponse self) =>
      'DocumentResponse(info: ${container.asString(self.info)}, error: ${container.asString(self.error)})';
  @override
  int hash(DocumentResponse self) => container.hash(self.info) ^ container.hash(self.error);
  @override
  bool equals(DocumentResponse self, DocumentResponse other) =>
      container.isEqual(self.info, other.info) && container.isEqual(self.error, other.error);
}

mixin DocumentResponseMappable {
  String toJson() => DocumentResponseMapper.container.toJson(this as DocumentResponse);
  Map<String, dynamic> toMap() => DocumentResponseMapper.container.toMap(this as DocumentResponse);
  DocumentResponseCopyWith<DocumentResponse, DocumentResponse, DocumentResponse> get copyWith =>
      _DocumentResponseCopyWithImpl(this as DocumentResponse, $identity, $identity);
  @override
  String toString() => DocumentResponseMapper.container.asString(this);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (runtimeType == other.runtimeType && DocumentResponseMapper.container.isEqual(this, other));
  @override
  int get hashCode => DocumentResponseMapper.container.hash(this);
}

extension DocumentResponseValueCopy<$R, $Out extends DocumentResponse> on ObjectCopyWith<$R, DocumentResponse, $Out> {
  DocumentResponseCopyWith<$R, DocumentResponse, $Out> get asDocumentResponse =>
      base.as((v, t, t2) => _DocumentResponseCopyWithImpl(v, t, t2));
}

typedef DocumentResponseCopyWithBound = DocumentResponse;

abstract class DocumentResponseCopyWith<$R, $In extends DocumentResponse, $Out extends DocumentResponse>
    implements ObjectCopyWith<$R, $In, $Out> {
  DocumentResponseCopyWith<$R2, $In, $Out2> chain<$R2, $Out2 extends DocumentResponse>(
      Then<DocumentResponse, $Out2> t, Then<$Out2, $R2> t2);
  HoverInfoCopyWith<$R, HoverInfo, HoverInfo> get info;
  $R call({HoverInfo? info, String? error});
}

class _DocumentResponseCopyWithImpl<$R, $Out extends DocumentResponse> extends CopyWithBase<$R, DocumentResponse, $Out>
    implements DocumentResponseCopyWith<$R, DocumentResponse, $Out> {
  _DocumentResponseCopyWithImpl(super.value, super.then, super.then2);
  @override
  DocumentResponseCopyWith<$R2, DocumentResponse, $Out2> chain<$R2, $Out2 extends DocumentResponse>(
          Then<DocumentResponse, $Out2> t, Then<$Out2, $R2> t2) =>
      _DocumentResponseCopyWithImpl($value, t, t2);

  @override
  HoverInfoCopyWith<$R, HoverInfo, HoverInfo> get info => $value.info.copyWith.chain($identity, (v) => call(info: v));
  @override
  $R call({HoverInfo? info, Object? error = $none}) =>
      $then(DocumentResponse(info ?? $value.info, or(error, $value.error)));
}

class HoverInfoMapper extends MapperBase<HoverInfo> {
  static MapperContainer container = MapperContainer(
    mappers: {HoverInfoMapper()},
  );

  @override
  HoverInfoMapperElement createElement(MapperContainer container) {
    return HoverInfoMapperElement._(this, container);
  }

  @override
  String get id => 'HoverInfo';

  static final fromMap = container.fromMap<HoverInfo>;
  static final fromJson = container.fromJson<HoverInfo>;
}

class HoverInfoMapperElement extends MapperElementBase<HoverInfo> {
  HoverInfoMapperElement._(super.mapper, super.container);

  @override
  Function get decoder => decode;
  HoverInfo decode(dynamic v) => checkedType(v, (Map<String, dynamic> map) => fromMap(map));
  HoverInfo fromMap(Map<String, dynamic> map) => HoverInfo(
      description: container.$getOpt(map, 'description'),
      kind: container.$getOpt(map, 'kind'),
      dartdoc: container.$getOpt(map, 'dartdoc'),
      enclosingClassName: container.$getOpt(map, 'enclosingClassName'),
      libraryName: container.$getOpt(map, 'libraryName'),
      parameter: container.$getOpt(map, 'parameter'),
      deprecated: container.$getOpt(map, 'deprecated'),
      staticType: container.$getOpt(map, 'staticType'),
      propagatedType: container.$getOpt(map, 'propagatedType'));

  @override
  Function get encoder => encode;
  dynamic encode(HoverInfo v) => toMap(v);
  Map<String, dynamic> toMap(HoverInfo h) => {
        'description': container.$enc(h.description, 'description'),
        'kind': container.$enc(h.kind, 'kind'),
        'dartdoc': container.$enc(h.dartdoc, 'dartdoc'),
        'enclosingClassName': container.$enc(h.enclosingClassName, 'enclosingClassName'),
        'libraryName': container.$enc(h.libraryName, 'libraryName'),
        'parameter': container.$enc(h.parameter, 'parameter'),
        'deprecated': container.$enc(h.deprecated, 'deprecated'),
        'staticType': container.$enc(h.staticType, 'staticType'),
        'propagatedType': container.$enc(h.propagatedType, 'propagatedType')
      };

  @override
  String stringify(HoverInfo self) =>
      'HoverInfo(description: ${container.asString(self.description)}, kind: ${container.asString(self.kind)}, dartdoc: ${container.asString(self.dartdoc)}, enclosingClassName: ${container.asString(self.enclosingClassName)}, libraryName: ${container.asString(self.libraryName)}, parameter: ${container.asString(self.parameter)}, deprecated: ${container.asString(self.deprecated)}, staticType: ${container.asString(self.staticType)}, propagatedType: ${container.asString(self.propagatedType)})';
  @override
  int hash(HoverInfo self) =>
      container.hash(self.description) ^
      container.hash(self.kind) ^
      container.hash(self.dartdoc) ^
      container.hash(self.enclosingClassName) ^
      container.hash(self.libraryName) ^
      container.hash(self.parameter) ^
      container.hash(self.deprecated) ^
      container.hash(self.staticType) ^
      container.hash(self.propagatedType);
  @override
  bool equals(HoverInfo self, HoverInfo other) =>
      container.isEqual(self.description, other.description) &&
      container.isEqual(self.kind, other.kind) &&
      container.isEqual(self.dartdoc, other.dartdoc) &&
      container.isEqual(self.enclosingClassName, other.enclosingClassName) &&
      container.isEqual(self.libraryName, other.libraryName) &&
      container.isEqual(self.parameter, other.parameter) &&
      container.isEqual(self.deprecated, other.deprecated) &&
      container.isEqual(self.staticType, other.staticType) &&
      container.isEqual(self.propagatedType, other.propagatedType);
}

mixin HoverInfoMappable {
  String toJson() => HoverInfoMapper.container.toJson(this as HoverInfo);
  Map<String, dynamic> toMap() => HoverInfoMapper.container.toMap(this as HoverInfo);
  HoverInfoCopyWith<HoverInfo, HoverInfo, HoverInfo> get copyWith =>
      _HoverInfoCopyWithImpl(this as HoverInfo, $identity, $identity);
  @override
  String toString() => HoverInfoMapper.container.asString(this);
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (runtimeType == other.runtimeType && HoverInfoMapper.container.isEqual(this, other));
  @override
  int get hashCode => HoverInfoMapper.container.hash(this);
}

extension HoverInfoValueCopy<$R, $Out extends HoverInfo> on ObjectCopyWith<$R, HoverInfo, $Out> {
  HoverInfoCopyWith<$R, HoverInfo, $Out> get asHoverInfo => base.as((v, t, t2) => _HoverInfoCopyWithImpl(v, t, t2));
}

typedef HoverInfoCopyWithBound = HoverInfo;

abstract class HoverInfoCopyWith<$R, $In extends HoverInfo, $Out extends HoverInfo>
    implements ObjectCopyWith<$R, $In, $Out> {
  HoverInfoCopyWith<$R2, $In, $Out2> chain<$R2, $Out2 extends HoverInfo>(Then<HoverInfo, $Out2> t, Then<$Out2, $R2> t2);
  $R call(
      {String? description,
      String? kind,
      String? dartdoc,
      String? enclosingClassName,
      String? libraryName,
      String? parameter,
      bool? deprecated,
      String? staticType,
      String? propagatedType});
}

class _HoverInfoCopyWithImpl<$R, $Out extends HoverInfo> extends CopyWithBase<$R, HoverInfo, $Out>
    implements HoverInfoCopyWith<$R, HoverInfo, $Out> {
  _HoverInfoCopyWithImpl(super.value, super.then, super.then2);
  @override
  HoverInfoCopyWith<$R2, HoverInfo, $Out2> chain<$R2, $Out2 extends HoverInfo>(
          Then<HoverInfo, $Out2> t, Then<$Out2, $R2> t2) =>
      _HoverInfoCopyWithImpl($value, t, t2);

  @override
  $R call(
          {Object? description = $none,
          Object? kind = $none,
          Object? dartdoc = $none,
          Object? enclosingClassName = $none,
          Object? libraryName = $none,
          Object? parameter = $none,
          Object? deprecated = $none,
          Object? staticType = $none,
          Object? propagatedType = $none}) =>
      $then(HoverInfo(
          description: or(description, $value.description),
          kind: or(kind, $value.kind),
          dartdoc: or(dartdoc, $value.dartdoc),
          enclosingClassName: or(enclosingClassName, $value.enclosingClassName),
          libraryName: or(libraryName, $value.libraryName),
          parameter: or(parameter, $value.parameter),
          deprecated: or(deprecated, $value.deprecated),
          staticType: or(staticType, $value.staticType),
          propagatedType: or(propagatedType, $value.propagatedType)));
}

class DocumentRequestMapper extends MapperBase<DocumentRequest> {
  static MapperContainer container = MapperContainer(
    mappers: {DocumentRequestMapper()},
  );

  @override
  DocumentRequestMapperElement createElement(MapperContainer container) {
    return DocumentRequestMapperElement._(this, container);
  }

  @override
  String get id => 'DocumentRequest';

  static final fromMap = container.fromMap<DocumentRequest>;
  static final fromJson = container.fromJson<DocumentRequest>;
}

class DocumentRequestMapperElement extends MapperElementBase<DocumentRequest> {
  DocumentRequestMapperElement._(super.mapper, super.container);

  @override
  Function get decoder => decode;
  DocumentRequest decode(dynamic v) => checkedType(v, (Map<String, dynamic> map) => fromMap(map));
  DocumentRequest fromMap(Map<String, dynamic> map) =>
      DocumentRequest(container.$get(map, 'sources'), container.$get(map, 'name'), container.$get(map, 'offset'));

  @override
  Function get encoder => encode;
  dynamic encode(DocumentRequest v) => toMap(v);
  Map<String, dynamic> toMap(DocumentRequest d) => {
        'sources': container.$enc(d.sources, 'sources'),
        'name': container.$enc(d.name, 'name'),
        'offset': container.$enc(d.offset, 'offset')
      };

  @override
  String stringify(DocumentRequest self) =>
      'DocumentRequest(sources: ${container.asString(self.sources)}, name: ${container.asString(self.name)}, offset: ${container.asString(self.offset)})';
  @override
  int hash(DocumentRequest self) =>
      container.hash(self.sources) ^ container.hash(self.name) ^ container.hash(self.offset);
  @override
  bool equals(DocumentRequest self, DocumentRequest other) =>
      container.isEqual(self.sources, other.sources) &&
      container.isEqual(self.name, other.name) &&
      container.isEqual(self.offset, other.offset);
}

mixin DocumentRequestMappable {
  String toJson() => DocumentRequestMapper.container.toJson(this as DocumentRequest);
  Map<String, dynamic> toMap() => DocumentRequestMapper.container.toMap(this as DocumentRequest);
  DocumentRequestCopyWith<DocumentRequest, DocumentRequest, DocumentRequest> get copyWith =>
      _DocumentRequestCopyWithImpl(this as DocumentRequest, $identity, $identity);
  @override
  String toString() => DocumentRequestMapper.container.asString(this);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (runtimeType == other.runtimeType && DocumentRequestMapper.container.isEqual(this, other));
  @override
  int get hashCode => DocumentRequestMapper.container.hash(this);
}

extension DocumentRequestValueCopy<$R, $Out extends DocumentRequest> on ObjectCopyWith<$R, DocumentRequest, $Out> {
  DocumentRequestCopyWith<$R, DocumentRequest, $Out> get asDocumentRequest =>
      base.as((v, t, t2) => _DocumentRequestCopyWithImpl(v, t, t2));
}

typedef DocumentRequestCopyWithBound = DocumentRequest;

abstract class DocumentRequestCopyWith<$R, $In extends DocumentRequest, $Out extends DocumentRequest>
    implements ObjectCopyWith<$R, $In, $Out> {
  DocumentRequestCopyWith<$R2, $In, $Out2> chain<$R2, $Out2 extends DocumentRequest>(
      Then<DocumentRequest, $Out2> t, Then<$Out2, $R2> t2);
  MapCopyWith<$R, String, String, ObjectCopyWith<$R, String, String>> get sources;
  $R call({Map<String, String>? sources, String? name, int? offset});
}

class _DocumentRequestCopyWithImpl<$R, $Out extends DocumentRequest> extends CopyWithBase<$R, DocumentRequest, $Out>
    implements DocumentRequestCopyWith<$R, DocumentRequest, $Out> {
  _DocumentRequestCopyWithImpl(super.value, super.then, super.then2);
  @override
  DocumentRequestCopyWith<$R2, DocumentRequest, $Out2> chain<$R2, $Out2 extends DocumentRequest>(
          Then<DocumentRequest, $Out2> t, Then<$Out2, $R2> t2) =>
      _DocumentRequestCopyWithImpl($value, t, t2);

  @override
  MapCopyWith<$R, String, String, ObjectCopyWith<$R, String, String>> get sources =>
      MapCopyWith($value.sources, (v, t) => ObjectCopyWith(v, $identity, t), (v) => call(sources: v));
  @override
  $R call({Map<String, String>? sources, String? name, int? offset}) =>
      $then(DocumentRequest(sources ?? $value.sources, name ?? $value.name, offset ?? $value.offset));
}

class IssueKindMapper extends EnumMapper<IssueKind> {
  static MapperContainer container = MapperContainer(
    mappers: {IssueKindMapper()},
  );

  static final fromValue = container.fromValue<IssueKind>;

  @override
  IssueKind decode(dynamic value) {
    switch (value) {
      case 'error':
        return IssueKind.error;
      case 'warning':
        return IssueKind.warning;
      case 'info':
        return IssueKind.info;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(IssueKind self) {
    switch (self) {
      case IssueKind.error:
        return 'error';
      case IssueKind.warning:
        return 'warning';
      case IssueKind.info:
        return 'info';
    }
  }
}

extension IssueKindMapperExtension on IssueKind {
  String toValue() => IssueKindMapper.container.toValue(this) as String;
}
